import 'package:budgetiq/core/error/failure.dart';
import 'package:budgetiq/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:budgetiq/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:budgetiq/features/profile/data/models/profile_model.dart';
import 'package:budgetiq/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemote implements ProfileRemoteDataSource {
  _FakeRemote({this.row, this.throwOnFetch = false});
  Map<String, dynamic>? row;
  bool throwOnFetch;
  Map<String, dynamic>? lastUpdate;

  @override
  Future<Map<String, dynamic>?> fetch() async {
    if (throwOnFetch) throw Exception('offline');
    return row;
  }

  @override
  Future<Map<String, dynamic>> update(Map<String, dynamic> values) async {
    lastUpdate = values;
    row = {...?row, ...values};
    return row!;
  }
}

class _FakeLocal implements ProfileLocalDataSource {
  Map<String, dynamic>? stored;
  @override
  Map<String, dynamic>? read() => stored;
  @override
  Future<void> write(Map<String, dynamic>? profile) async => stored = profile;
}

ProfileRepositoryImpl _repo(
  _FakeRemote r,
  _FakeLocal l, {
  required bool online,
}) => ProfileRepositoryImpl(remote: r, local: l, isOnline: () => online);

Map<String, dynamic> _row(String currency) => {
  'id': 'u1',
  'currency_code': currency,
  'display_name': 'Sam',
  'locale': 'en_US',
  'theme_mode': 'system',
  'large_text': false,
};

void main() {
  test('online getProfile maps and caches', () async {
    final local = _FakeLocal();
    final repo = _repo(_FakeRemote(row: _row('GHS')), local, online: true);

    final profile = await repo.getProfile();

    expect(profile.currencyCode, 'GHS');
    expect(profile.displayName, 'Sam');
    expect(local.stored, isNotNull);
  });

  test('offline getProfile reads cache', () async {
    final local = _FakeLocal()..stored = _row('EUR');
    final repo = _repo(_FakeRemote(throwOnFetch: true), local, online: false);

    final profile = await repo.getProfile();
    expect(profile.currencyCode, 'EUR');
  });

  test('offline getProfile without cache throws', () async {
    final repo = _repo(_FakeRemote(), _FakeLocal(), online: false);
    expect(() => repo.getProfile(), throwsA(isA<NetworkFailure>()));
  });

  test('updateCurrency persists and refreshes cache', () async {
    final remote = _FakeRemote(row: _row('USD'));
    final local = _FakeLocal();
    final repo = _repo(remote, local, online: true);

    final updated = await repo.updateCurrency('GBP');

    expect(updated.currencyCode, 'GBP');
    expect(remote.lastUpdate!['currency_code'], 'GBP');
    expect(local.stored!['currency_code'], 'GBP');
  });

  test('updateCurrency offline throws', () async {
    final repo = _repo(
      _FakeRemote(row: _row('USD')),
      _FakeLocal(),
      online: false,
    );
    expect(() => repo.updateCurrency('GBP'), throwsA(isA<NetworkFailure>()));
  });

  test('ProfileModel round-trips through JSON', () {
    final profile = ProfileModel.fromJson(_row('GHS'));
    final json = ProfileModel.toJson(profile);
    expect(json['currency_code'], 'GHS');
    expect(json['display_name'], 'Sam');
    expect(ProfileModel.fromJson(json), profile);
  });
}
