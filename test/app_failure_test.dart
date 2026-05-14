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
  group('AppFailure', () {
    test(
      'constructor stores fields and notifies handler with same instance',
      () {
        final handler = _RecordingFailureHandler();
        final stackTrace = StackTrace.current;
        final failure = AppFailure(
          kind: AppFailureKind.network,
          message: 'Offline',
          stackTrace: stackTrace,
          handler: handler,
          code: 'NET-1',
          cause: const FormatException('bad payload'),
          data: const {'retryable': true},
        );

        expect(failure.kind, AppFailureKind.network);
        expect(failure.message, 'Offline');
        expect(failure.stackTrace, same(stackTrace));
        expect(failure.code, 'NET-1');
        expect(failure.cause, isA<FormatException>());
        expect(failure.data, const {'retryable': true});
        expect(handler.failures, [same(failure)]);
      },
    );

    group('factories', () {
      final notFoundStackTrace = StackTrace.current;
      final validationStackTrace = StackTrace.current;
      final cases =
          <
            ({
              String name,
              AppFailure failure,
              AppFailureKind expectedKind,
              String expectedMessage,
              String? expectedCode,
              Matcher expectedCause,
              Map<String, Object?> expectedData,
              StackTrace expectedStackTrace,
            })
          >[
            (
              name: 'unexpected maps to unknown kind with defaults',
              failure: AppFailure.unexpected(
                StateError('boom'),
                StackTrace.empty,
                handler: noopAppFailureHandler,
              ),
              expectedKind: AppFailureKind.unknown,
              expectedMessage: 'Something went wrong.',
              expectedCode: null,
              expectedCause: isA<StateError>(),
              expectedData: const {},
              expectedStackTrace: StackTrace.empty,
            ),
            (
              name: 'notFound maps to notFound kind with defaults',
              failure: AppFailure.notFound(
                stackTrace: notFoundStackTrace,
                handler: noopAppFailureHandler,
              ),
              expectedKind: AppFailureKind.notFound,
              expectedMessage: 'Item not found.',
              expectedCode: null,
              expectedCause: isNull,
              expectedData: const {},
              expectedStackTrace: notFoundStackTrace,
            ),
            (
              name: 'validation maps to validation kind',
              failure: AppFailure.validation(
                message: 'Name is required',
                stackTrace: validationStackTrace,
                handler: noopAppFailureHandler,
                code: 'VAL-1',
                data: const {'field': 'name'},
              ),
              expectedKind: AppFailureKind.validation,
              expectedMessage: 'Name is required',
              expectedCode: 'VAL-1',
              expectedCause: isNull,
              expectedData: const {'field': 'name'},
              expectedStackTrace: validationStackTrace,
            ),
          ];

      for (final testCase in cases) {
        test(testCase.name, () {
          expect(testCase.failure.kind, testCase.expectedKind);
          expect(testCase.failure.message, testCase.expectedMessage);
          expect(testCase.failure.code, testCase.expectedCode);
          expect(testCase.failure.cause, testCase.expectedCause);
          expect(testCase.failure.data, testCase.expectedData);
          expect(
            testCase.failure.stackTrace,
            same(testCase.expectedStackTrace),
          );
        });
      }

      test('factories notify handler once with created failure', () {
        final handler = _RecordingFailureHandler();
        final unexpectedFailure = AppFailure.unexpected(
          ArgumentError('oops'),
          StackTrace.current,
          handler: handler,
        );
        final notFoundFailure = AppFailure.notFound(
          stackTrace: StackTrace.current,
          handler: handler,
        );
        final validationFailure = AppFailure.validation(
          message: 'Invalid',
          stackTrace: StackTrace.current,
          handler: handler,
        );

        expect(handler.failures, [
          same(unexpectedFailure),
          same(notFoundFailure),
          same(validationFailure),
        ]);
      });
    });

    group('derived flags', () {
      final cases =
          <
            ({
              String name,
              AppFailure failure,
              bool expectedIsNotFound,
              bool expectedIsValidation,
            })
          >[
            (
              name: 'notFound kind sets isNotFound only',
              failure: AppFailure.notFound(
                stackTrace: StackTrace.current,
                handler: noopAppFailureHandler,
              ),
              expectedIsNotFound: true,
              expectedIsValidation: false,
            ),
            (
              name: 'validation kind sets isValidation only',
              failure: AppFailure.validation(
                message: 'Invalid',
                stackTrace: StackTrace.current,
                handler: noopAppFailureHandler,
              ),
              expectedIsNotFound: false,
              expectedIsValidation: true,
            ),
            (
              name: 'other kinds set both derived flags false',
              failure: AppFailure(
                kind: AppFailureKind.timeout,
                message: 'Timed out',
                stackTrace: StackTrace.current,
                handler: noopAppFailureHandler,
              ),
              expectedIsNotFound: false,
              expectedIsValidation: false,
            ),
          ];

      for (final testCase in cases) {
        test(testCase.name, () {
          expect(testCase.failure.isNotFound, testCase.expectedIsNotFound);
          expect(testCase.failure.isValidation, testCase.expectedIsValidation);
        });
      }
    });

    group('copyWith', () {
      test('overrides provided fields and notifies provided handler', () {
        final originalHandler = _RecordingFailureHandler();
        final replacementHandler = _RecordingFailureHandler();
        final originalFailure = AppFailure(
          kind: AppFailureKind.persistence,
          message: 'Cannot save',
          stackTrace: StackTrace.current,
          handler: originalHandler,
          code: 'DB-1',
          cause: const FormatException('bad'),
          data: const {'attempt': 1},
        );
        final replacementStackTrace = StackTrace.current;
        final copy = originalFailure.copyWith(
          handler: replacementHandler,
          kind: AppFailureKind.conflict,
          message: 'Conflict',
          code: 'CONFLICT-1',
          cause: StateError('new cause'),
          stackTrace: replacementStackTrace,
          data: const {'attempt': 2},
        );

        expect(copy.kind, AppFailureKind.conflict);
        expect(copy.message, 'Conflict');
        expect(copy.code, 'CONFLICT-1');
        expect(copy.cause, isA<StateError>());
        expect(copy.stackTrace, same(replacementStackTrace));
        expect(copy.data, const {'attempt': 2});
        expect(originalHandler.failures, [same(originalFailure)]);
        expect(replacementHandler.failures, [same(copy)]);
      });

      test('preserves original values when overrides are omitted', () {
        final handler = _RecordingFailureHandler();
        final originalFailure = AppFailure(
          kind: AppFailureKind.unauthorized,
          message: 'Denied',
          stackTrace: StackTrace.current,
          handler: handler,
          code: 'AUTH-1',
          cause: ArgumentError('bad token'),
          data: const {'path': '/secure'},
        );
        final copyHandler = _RecordingFailureHandler();
        final copy = originalFailure.copyWith(handler: copyHandler);

        expect(copy.kind, originalFailure.kind);
        expect(copy.message, originalFailure.message);
        expect(copy.code, originalFailure.code);
        expect(copy.cause, same(originalFailure.cause));
        expect(copy.stackTrace, same(originalFailure.stackTrace));
        expect(copy.data, same(originalFailure.data));
      });
    });

    group('toString', () {
      final cases =
          <({String name, AppFailure failure, String expectedString})>[
            (
              name: 'without code',
              failure: AppFailure(
                kind: AppFailureKind.validation,
                message: 'Bad value',
                stackTrace: StackTrace.current,
                handler: noopAppFailureHandler,
              ),
              expectedString: 'AppFailure.validation: Bad value',
            ),
            (
              name: 'with code',
              failure: AppFailure(
                kind: AppFailureKind.forbidden,
                message: 'Forbidden',
                stackTrace: StackTrace.current,
                handler: noopAppFailureHandler,
                code: 'AUTH-403',
              ),
              expectedString: 'AppFailure.forbidden: Forbidden (AUTH-403)',
            ),
          ];

      for (final testCase in cases) {
        test(testCase.name, () {
          expect(testCase.failure.toString(), testCase.expectedString);
        });
      }
    });
  });
}
