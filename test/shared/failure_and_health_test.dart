import 'package:budgetiq/core/error/failure.dart';
import 'package:budgetiq/features/insights/domain/entities/health_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('messageFromError', () {
    test('uses Failure.message when available', () {
      expect(messageFromError(const AuthFailure('bad creds')), 'bad creds');
      expect(messageFromError(const NetworkFailure('offline')), 'offline');
    });

    test('falls back for non-Failure errors', () {
      expect(messageFromError(Exception('x')), 'Something went wrong.');
    });
  });

  group('HealthScore band', () {
    HealthScore s(int v) => HealthScore(score: v, factors: const []);
    test('maps score to band label', () {
      expect(s(85).band, 'Excellent');
      expect(s(65).band, 'Good');
      expect(s(45).band, 'Fair');
      expect(s(20).band, 'Needs attention');
    });
  });
}
