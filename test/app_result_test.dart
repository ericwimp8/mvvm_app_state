import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_app_state/mvvm_app_state.dart';

class _RecordingFailureHandler implements AppFailureHandler {
  final List<AppFailure> failures = <AppFailure>[];

  @override
  void handle(AppFailure failure) {
    failures.add(failure);
  }
}

void main() {
  group('AppResult', () {
    test('exposes success state and value accessors', () {
      const result = AppResult<int>.success(7);

      expect(result, isA<AppSuccess<int>>());
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 7);
      expect(result.failureOrNull, isNull);
    });

    test('exposes failure state and failure accessors', () {
      final handler = _RecordingFailureHandler();
      final failure = AppFailure.notFound(
        stackTrace: StackTrace.current,
        handler: handler,
        message: 'Missing',
      );
      final result = AppResult<int>.failure(failure);

      expect(result, isA<AppError<int>>());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, same(failure));
    });

    group('fold', () {
      final failure = AppFailure.validation(
        message: 'Bad value',
        stackTrace: StackTrace.current,
        handler: noopAppFailureHandler,
      );
      final cases =
          <({String name, AppResult<int> result, String expectedValue})>[
            (
              name: 'calls success mapper for success result',
              result: const AppResult<int>.success(3),
              expectedValue: 'ok:3',
            ),
            (
              name: 'calls failure mapper for failure result',
              result: AppResult<int>.failure(failure),
              expectedValue: 'error:Bad value',
            ),
          ];

      for (final testCase in cases) {
        test(testCase.name, () {
          final value = testCase.result.fold(
            onSuccess: (value) => 'ok:$value',
            onFailure: (failure) => 'error:${failure.message}',
          );

          expect(value, testCase.expectedValue);
        });
      }
    });

    group('map', () {
      final failure = AppFailure(
        kind: AppFailureKind.persistence,
        message: 'Cannot save',
        stackTrace: StackTrace.current,
        handler: noopAppFailureHandler,
      );
      final cases = <({String name, AppResult<int> source, Matcher expected})>[
        (
          name: 'transforms success values',
          source: const AppResult<int>.success(4),
          expected: isA<AppSuccess<String>>().having(
            (value) => value.valueOrNull,
            'value',
            'mapped:4',
          ),
        ),
        (
          name: 'keeps failure kind',
          source: AppResult<int>.failure(failure),
          expected: isA<AppError<String>>().having(
            (value) => value.failureOrNull?.kind,
            'kind',
            AppFailureKind.persistence,
          ),
        ),
        (
          name: 'keeps same failure instance',
          source: AppResult<int>.failure(failure),
          expected: predicate<AppResult<String>>(
            (result) => identical(result.failureOrNull, failure),
            'contains the same AppFailure instance',
          ),
        ),
      ];

      for (final testCase in cases) {
        test(testCase.name, () {
          final mapped = testCase.source.map((value) => 'mapped:$value');

          expect(mapped, testCase.expected);
        });
      }
    });

    group('flatMap', () {
      final failure = AppFailure(
        kind: AppFailureKind.network,
        message: 'Offline',
        stackTrace: StackTrace.current,
        handler: noopAppFailureHandler,
      );

      test('runs transform for success values', () {
        const source = AppResult<int>.success(8);

        final result = source.flatMap<String>(
          (value) => AppResult<String>.success('value:$value'),
        );

        expect(result, isA<AppSuccess<String>>());
        expect(result.valueOrNull, 'value:8');
      });

      test('propagates failure without calling transform', () {
        final source = AppResult<int>.failure(failure);
        var called = false;

        final result = source.flatMap<String>((value) {
          called = true;
          return AppResult<String>.success('value:$value');
        });

        expect(called, isFalse);
        expect(result, isA<AppError<String>>());
        expect(identical(result.failureOrNull, failure), isTrue);
      });
    });

    group('guard', () {
      test('returns success when action completes', () async {
        final handler = _RecordingFailureHandler();

        final result = await AppResult.guard<int>(
          () async => 42,
          failureHandler: handler,
        );

        expect(result, isA<AppSuccess<int>>());
        expect(result.valueOrNull, 42);
        expect(handler.failures, isEmpty);
      });

      test('maps thrown errors to unexpected failures by default', () async {
        final handler = _RecordingFailureHandler();
        final error = StateError('boom');

        final result = await AppResult.guard<int>(
          () async => throw error,
          failureHandler: handler,
        );

        expect(result, isA<AppError<int>>());
        final failure = result.failureOrNull;
        expect(failure?.kind, AppFailureKind.unknown);
        expect(failure?.message, 'Something went wrong.');
        expect(failure?.cause, same(error));
        expect(failure?.stackTrace, isNotNull);
        expect(handler.failures, [same(failure)]);
      });

      test('uses custom error mapper when provided', () async {
        final handler = _RecordingFailureHandler();
        final error = ArgumentError('bad argument');
        final stackTrace = StackTrace.current;
        late Object capturedError;
        late StackTrace capturedStackTrace;

        final result = await AppResult.guard<int>(
          () async => Error.throwWithStackTrace(error, stackTrace),
          failureHandler: handler,
          mapError: (receivedError, receivedStackTrace) {
            capturedError = receivedError;
            capturedStackTrace = receivedStackTrace;
            return AppFailure.validation(
              message: 'Mapped',
              stackTrace: receivedStackTrace,
              handler: handler,
            );
          },
        );

        expect(capturedError, same(error));
        expect(capturedStackTrace, same(stackTrace));
        expect(result.failureOrNull?.kind, AppFailureKind.validation);
        expect(result.failureOrNull?.message, 'Mapped');
        expect(handler.failures, [same(result.failureOrNull)]);
      });
    });

    group('toString', () {
      test('formats success values', () {
        const result = AppResult<int>.success(3);

        expect(result.toString(), 'AppResult<int>.success(3)');
      });

      test('formats failures', () {
        final failure = AppFailure(
          kind: AppFailureKind.unauthorized,
          message: 'Denied',
          stackTrace: StackTrace.current,
          handler: noopAppFailureHandler,
          code: 'AUTH-1',
        );
        final result = AppResult<int>.failure(failure);

        expect(
          result.toString(),
          'AppResult<int>.failure(AppFailure.unauthorized: Denied (AUTH-1))',
        );
      });
    });
  });
}
