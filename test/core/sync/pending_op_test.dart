import 'package:budgetiq/core/sync/pending_op.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips through JSON for each op type', () {
    for (final type in SyncOpType.values) {
      final op = PendingOp(
        id: 'op-${type.name}',
        table: 'income_transactions',
        type: type,
        recordId: 'rec-1',
        data: {'amount': 10, 'note': null},
        createdAt: DateTime.parse('2026-06-13T10:00:00.000Z'),
        baseUpdatedAt: type == SyncOpType.update
            ? DateTime.parse('2026-06-01T00:00:00.000Z')
            : null,
      );

      final restored = PendingOp.fromJson(op.toJson());

      expect(restored, op);
      expect(restored.type, type);
      expect(restored.data['amount'], 10);
      expect(restored.baseUpdatedAt, op.baseUpdatedAt);
    }
  });

  test('value equality ignores object identity', () {
    final a = PendingOp(
      id: '1',
      table: 't',
      type: SyncOpType.insert,
      recordId: 'r',
      data: const {'x': 1},
      createdAt: DateTime(2026, 6, 1),
    );
    final b = PendingOp(
      id: '1',
      table: 't',
      type: SyncOpType.insert,
      recordId: 'r',
      data: const {'x': 1},
      createdAt: DateTime(2026, 6, 1),
    );
    expect(a, b);
  });
}
