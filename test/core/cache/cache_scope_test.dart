import 'package:budgetiq/core/cache/cache_box.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

/// Minimal in-memory [Box] stand-in — enough for key-scoping assertions
/// without needing a Hive directory on disk.
class _MemoryBox extends Fake implements Box<dynamic> {
  final Map<dynamic, dynamic> store = {};

  @override
  Iterable<dynamic> get keys => store.keys;

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) =>
      store.containsKey(key) ? store[key] : defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) async => store[key] = value;

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final key in keys) {
      store.remove(key);
    }
  }
}

void main() {
  group('JsonListCache user scoping', () {
    test("one user cannot read another user's cached rows", () async {
      final box = _MemoryBox();
      final alice = JsonListCache(box, userId: 'alice');
      final bob = JsonListCache(box, userId: 'bob');

      await alice.write('transactions_expense', [
        {'id': 't1', 'amount': 42},
      ]);

      expect(alice.read('transactions_expense'), hasLength(1));
      expect(bob.read('transactions_expense'), isEmpty);
    });

    test("a signed-out cache is its own scope, not the last user's", () async {
      final box = _MemoryBox();
      await JsonListCache(box, userId: 'alice').write('goals', [
        {'id': 'g1'},
      ]);

      expect(JsonListCache(box).read('goals'), isEmpty);
    });

    test('writes are namespaced by user id', () async {
      final box = _MemoryBox();
      await JsonListCache(box, userId: 'alice').write('profile', [
        {'id': 'alice'},
      ]);

      expect(box.keys.single, 'u:alice:profile');
    });
  });

  group('CacheMaintenance', () {
    test(
      "clearing a scope removes that user's data and nothing else",
      () async {
        final box = _MemoryBox();
        await JsonListCache(box, userId: 'alice').write('goals', [
          {'id': 'g1'},
        ]);
        await JsonListCache(box, userId: 'bob').write('goals', [
          {'id': 'g2'},
        ]);
        await box.put('theme_mode', 'dark');

        await CacheMaintenance(box).clearUserScope('alice');

        expect(JsonListCache(box, userId: 'alice').read('goals'), isEmpty);
        expect(JsonListCache(box, userId: 'bob').read('goals'), hasLength(1));
        expect(
          box.get('theme_mode'),
          'dark',
          reason: 'device preferences are not per-user',
        );
      },
    );

    test('clearing an empty scope is a no-op', () async {
      final box = _MemoryBox();
      await box.put('theme_mode', 'light');

      await CacheMaintenance(box).clearUserScope('nobody');

      expect(box.keys, contains('theme_mode'));
    });

    test('preserved keys survive the purge', () async {
      final box = _MemoryBox();
      final cache = JsonListCache(box, userId: 'alice');
      await cache.write('goals', [
        {'id': 'g1'},
      ]);
      await cache.write('sync_queue', [
        {'id': 'op1'},
      ]);

      await CacheMaintenance(
        box,
      ).clearUserScope('alice', preserve: const {'sync_queue'});

      expect(cache.read('goals'), isEmpty);
      expect(
        cache.read('sync_queue'),
        hasLength(1),
        reason: 'unsent writes must not be destroyed by signing out',
      );
    });
  });
}
