// ignore_for_file: prefer_initializing_formals — private DI fields cannot use
// initializing formals with named constructor params.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/sync/pending_op.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_page.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_data_source.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

/// Months of history loaded when the app opens.
///
/// Deliberately wider than anything the analytics need (a 6-month trend plus
/// the previous month for deltas) while keeping the initial payload and the
/// on-device cache bounded no matter how long the user has been recording.
const int kTransactionWindowMonths = 13;

/// Hard cap on the opening window, so an unusually heavy month cannot blow up
/// the first load.
const int kTransactionWindowMaxRows = 2000;

/// Rows fetched per "load older" page.
const int kTransactionPageSize = 200;

/// Offline-first [TransactionRepository].
///
/// The Hive cache is the source of truth the UI reads from. Every write is
/// applied to the cache optimistically and enqueued in the offline [SyncQueue];
/// the sync engine pushes queued ops to Supabase when online. Reads prefer the
/// server (refreshing the cache) but fall back to cache when offline, so locally
/// created/edited rows remain visible until they reconcile.
///
/// Reads are bounded: the opening window spans [kTransactionWindowMonths], and
/// older history is paged in through `getTransactions(olderThan:)`.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required TransactionRemoteDataSource remote,
    required TransactionLocalDataSource local,
    required SyncQueue queue,
    required bool Function() isOnline,
    required String? Function() currentUserId,
    required Map<String, dynamic>? Function(
      TransactionKind kind,
      String? categoryId,
    )
    resolveCategory,
    required String currencyCode,
    void Function()? onEnqueued,
  }) : _remote = remote,
       _local = local,
       _queue = queue,
       _isOnline = isOnline,
       _currentUserId = currentUserId,
       _resolveCategory = resolveCategory,
       _currency = currencyCode,
       _onEnqueued = onEnqueued;

  final TransactionRemoteDataSource _remote;
  final TransactionLocalDataSource _local;
  final SyncQueue _queue;
  final bool Function() _isOnline;
  final String? Function() _currentUserId;
  final Map<String, dynamic>? Function(TransactionKind, String?)
  _resolveCategory;
  final String _currency;
  final void Function()? _onEnqueued;

  static const _uuid = Uuid();

  @override
  Future<TransactionPage> getTransactions(
    TransactionKind kind, {
    DateTime? olderThan,
  }) async {
    if (!_isOnline()) {
      // Offline: serve what is cached. Older pages can't be fetched, and the
      // cache already holds everything previously loaded.
      return TransactionPage(
        items: olderThan == null ? _mapRows(_local.read(kind), kind) : const [],
        hasMore: false,
      );
    }
    try {
      return olderThan == null
          ? await _fetchWindow(kind)
          : await _fetchOlder(kind, olderThan);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      if (olderThan != null) {
        throw const NetworkFailure('Could not load older transactions.');
      }
      final cached = _local.read(kind);
      if (cached.isNotEmpty) {
        return TransactionPage(items: _mapRows(cached, kind), hasMore: false);
      }
      throw const NetworkFailure('Could not load transactions.');
    }
  }

  /// Loads the opening window and replaces the cache with it.
  Future<TransactionPage> _fetchWindow(TransactionKind kind) async {
    final start = _windowStart();
    final rows = await _remote.fetch(
      kind,
      from: start,
      limit: kTransactionWindowMaxRows,
    );
    await _local.write(kind, rows);
    return TransactionPage(
      items: _mapRows(rows, kind),
      hasMore: await _remote.hasBefore(kind, start),
    );
  }

  /// Loads the next page of history at or before [olderThan], appending it to
  /// the cache so it stays available offline.
  ///
  /// The bound is inclusive and results are de-duplicated by id: a page
  /// boundary can fall in the middle of a date, and an exclusive bound would
  /// skip the rest of that day.
  Future<TransactionPage> _fetchOlder(
    TransactionKind kind,
    DateTime olderThan,
  ) async {
    final rows = await _remote.fetch(
      kind,
      to: olderThan,
      limit: kTransactionPageSize,
    );
    final cached = _local.read(kind);
    final known = cached.map((r) => r['id']).toSet();
    final fresh = rows.where((r) => !known.contains(r['id'])).toList();
    if (fresh.isNotEmpty) {
      await _local.write(kind, [...cached, ...fresh]);
    }
    return TransactionPage(
      items: _mapRows(fresh, kind),
      hasMore: rows.length == kTransactionPageSize,
    );
  }

  /// First day of the month [kTransactionWindowMonths] back.
  static DateTime _windowStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month - (kTransactionWindowMonths - 1), 1);
  }

  @override
  Future<Transaction> createTransaction({
    required TransactionKind kind,
    required Money amount,
    required DateTime occurredOn,
    String? categoryId,
    String? note,
  }) async {
    final id = _uuid.v4();
    final row = _row(
      id: id,
      kind: kind,
      amount: amount,
      occurredOn: occurredOn,
      categoryId: categoryId,
      note: note,
    );

    await _local.write(kind, [row, ..._local.read(kind)]);
    await _enqueue(
      SyncOpType.insert,
      kind: kind,
      recordId: id,
      data: {'id': id, 'user_id': _requireUser(), ..._writeData(row)},
    );
    return TransactionModel.fromJson(row, kind, _currency);
  }

  @override
  Future<Transaction> updateTransaction({
    required Transaction original,
    required Money amount,
    required DateTime occurredOn,
    String? categoryId,
    String? note,
  }) async {
    final rows = _local.read(original.kind);
    final index = rows.indexWhere((r) => r['id'] == original.id);
    final existing = index >= 0 ? rows[index] : null;

    // The server version this edit is based on — the sync engine drops the op
    // if the row changed on the server since, so the newer write wins.
    final base = baseUpdatedAtOf(existing);

    final updated = _row(
      id: original.id,
      kind: original.kind,
      amount: amount,
      occurredOn: occurredOn,
      categoryId: categoryId,
      note: note,
      updatedAt: existing?['updated_at'] as String?,
    );

    await _local.write(
      original.kind,
      rows.map((r) => r['id'] == original.id ? updated : r).toList(),
    );
    await _enqueue(
      SyncOpType.update,
      kind: original.kind,
      recordId: original.id,
      data: _writeData(updated),
      baseUpdatedAt: base,
    );
    return TransactionModel.fromJson(updated, original.kind, _currency);
  }

  @override
  Future<void> deleteTransaction(Transaction transaction) async {
    final rows = _local
        .read(transaction.kind)
        .where((r) => r['id'] != transaction.id)
        .toList();
    await _local.write(transaction.kind, rows);
    await _enqueue(
      SyncOpType.delete,
      kind: transaction.kind,
      recordId: transaction.id,
      data: const {},
    );
  }

  // --- helpers -------------------------------------------------------------

  /// Cache/display row shape (matches the embedded-category select).
  Map<String, dynamic> _row({
    required String id,
    required TransactionKind kind,
    required Money amount,
    required DateTime occurredOn,
    String? categoryId,
    String? note,
    String? updatedAt,
  }) {
    final cleanNote = (note?.trim().isEmpty ?? true) ? null : note!.trim();
    return {
      'id': id,
      'amount': amount.major,
      'currency_code': amount.currencyCode,
      'occurred_on': _dateOnly(occurredOn),
      'note': cleanNote,
      'category_id': categoryId,
      // Carried through so a second offline edit still knows which server
      // version it is based on. Never written back — Postgres owns it.
      'updated_at': ?updatedAt,
      if (categoryId != null)
        kind.categoryTable: _resolveCategory(kind, categoryId),
    };
  }

  /// Columns valid to write to the table (drops the embedded category).
  Map<String, dynamic> _writeData(Map<String, dynamic> row) => {
    'amount': row['amount'],
    'currency_code': row['currency_code'],
    'occurred_on': row['occurred_on'],
    'note': row['note'],
    'category_id': row['category_id'],
  };

  Future<void> _enqueue(
    SyncOpType type, {
    required TransactionKind kind,
    required String recordId,
    required Map<String, dynamic> data,
    DateTime? baseUpdatedAt,
  }) async {
    await _queue.enqueue(
      PendingOp(
        id: _uuid.v4(),
        table: kind.transactionTable,
        type: type,
        recordId: recordId,
        data: data,
        createdAt: DateTime.now(),
        baseUpdatedAt: baseUpdatedAt,
      ),
    );
    _onEnqueued?.call();
  }

  String _requireUser() {
    final id = _currentUserId();
    if (id == null) throw const AuthFailure('Not authenticated.');
    return id;
  }

  List<Transaction> _mapRows(
    List<Map<String, dynamic>> rows,
    TransactionKind kind,
  ) => rows.map((r) => TransactionModel.fromJson(r, kind, _currency)).toList();

  static String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
