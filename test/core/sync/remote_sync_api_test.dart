import 'dart:async';
import 'dart:io';

import 'package:budgetiq/core/sync/remote_sync_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('isTransientSyncError', () {
    test('network errors are transient (retryable)', () {
      expect(isTransientSyncError(const SocketException('no route')), isTrue);
      expect(isTransientSyncError(TimeoutException('slow')), isTrue);
    });

    test('5xx / unknown Postgrest codes are transient', () {
      expect(
        isTransientSyncError(
          const PostgrestException(message: 'x', code: '500'),
        ),
        isTrue,
      );
      expect(
        isTransientSyncError(
          const PostgrestException(message: 'x', code: '503'),
        ),
        isTrue,
      );
      expect(
        isTransientSyncError(const PostgrestException(message: 'x')),
        isTrue, // no code → treat as transient
      );
    });

    test('4xx Postgrest codes are permanent', () {
      expect(
        isTransientSyncError(
          const PostgrestException(message: 'x', code: '400'),
        ),
        isFalse,
      );
      expect(
        isTransientSyncError(
          const PostgrestException(message: 'x', code: '409'),
        ),
        isFalse,
      );
    });

    test('arbitrary errors are permanent', () {
      expect(isTransientSyncError(Exception('boom')), isFalse);
      expect(isTransientSyncError(ArgumentError('bad')), isFalse);
    });
  });
}
