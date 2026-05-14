import 'package:mvvm_app_state/mvvm_app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppResult', () {
    test('folds success and failure paths', () {
      const success = AppResult<int>.success(7);
      final failure = AppResult<int>.failure(
        AppFailure(
          kind: AppFailureKind.network,
          message: 'Offline',
          report: noopAppFailureReporter,
        ),
      );

      expect(
        success.fold(onSuccess: (value) => value * 2, onFailure: (_) => 0),
        14,
      );
      expect(
        failure.fold(
          onSuccess: (value) => value,
          onFailure: (failure) => failure.message.length,
        ),
        7,
      );
    });

    test('maps and flat maps success values without losing failures', () {
      const success = AppResult<int>.success(3);
      final failure = AppResult<int>.failure(
        AppFailure(
          kind: AppFailureKind.persistence,
          message: 'Write failed',
          report: noopAppFailureReporter,
        ),
      );

      expect(success.map((value) => '$value').valueOrNull, '3');
      expect(
        success.flatMap((value) => AppResult.success(value + 1)).valueOrNull,
        4,
      );
      expect(
        failure.map((value) => '$value').failureOrNull?.kind,
        AppFailureKind.persistence,
      );
    });

    test('guard converts thrown errors into failures', () async {
      final result = await AppResult.guard<int>(
        () async => throw StateError('broken'),
        reportFailure: noopAppFailureReporter,
      );

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.kind, AppFailureKind.unknown);
      expect(result.failureOrNull?.cause, isA<StateError>());
    });
  });
}
