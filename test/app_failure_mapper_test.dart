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
  group('AppFailureMapper', () {
    group('function contract', () {
      final cases = <({String name, Object error})>[
        (name: 'accepts Exception values', error: Exception('boom')),
        (name: 'accepts Error values', error: StateError('boom')),
        (name: 'accepts arbitrary Object values', error: 'boom'),
      ];

      for (final testCase in cases) {
        test(testCase.name, () {
          late Object capturedError;
          late StackTrace capturedStackTrace;
          final stackTrace = StackTrace.current;
          final expectedFailure = AppFailure.validation(
            message: 'Mapped',
            stackTrace: stackTrace,
            handler: noopAppFailureHandler,
          );
          AppFailure mapper(Object error, StackTrace receivedStackTrace) {
            capturedError = error;
            capturedStackTrace = receivedStackTrace;
            return expectedFailure;
          }

          final mappedFailure = mapper(testCase.error, stackTrace);

          expect(capturedError, same(testCase.error));
          expect(capturedStackTrace, same(stackTrace));
          expect(mappedFailure, same(expectedFailure));
        });
      }
    });

    test('is used by AppActionController for thrown task errors', () async {
      final controller = AppActionController<String>(
        failureHandler: noopAppFailureHandler,
      );
      addTearDown(controller.dispose);
      final failureHandler = _RecordingFailureHandler();
      final error = ArgumentError('bad action');
      final stackTrace = StackTrace.current;
      late Object capturedError;
      late StackTrace capturedStackTrace;
      late AppFailure mappedFailure;
      AppFailure mapper(Object receivedError, StackTrace receivedStackTrace) {
        capturedError = receivedError;
        capturedStackTrace = receivedStackTrace;
        mappedFailure = AppFailure.validation(
          message: 'Action mapped',
          stackTrace: receivedStackTrace,
          handler: failureHandler,
        );
        return mappedFailure;
      }

      final result = await controller.run(
        () async => Error.throwWithStackTrace(error, stackTrace),
        mapError: mapper,
      );

      expect(capturedError, same(error));
      expect(capturedStackTrace, same(stackTrace));
      expect(result.failureOrNull, same(mappedFailure));
      expect(controller.state.value.failureOrNull, same(mappedFailure));
    });

    test('is used by AppLoadController for thrown task errors', () async {
      final controller = AppLoadController<String>(
        failureHandler: noopAppFailureHandler,
      );
      addTearDown(controller.dispose);
      final failureHandler = _RecordingFailureHandler();
      final error = StateError('bad load');
      final stackTrace = StackTrace.current;
      late Object capturedError;
      late StackTrace capturedStackTrace;
      late AppFailure mappedFailure;
      AppFailure mapper(Object receivedError, StackTrace receivedStackTrace) {
        capturedError = receivedError;
        capturedStackTrace = receivedStackTrace;
        mappedFailure = AppFailure.notFound(
          stackTrace: receivedStackTrace,
          handler: failureHandler,
          message: 'Load mapped',
        );
        return mappedFailure;
      }

      final result = await controller.run(
        () async => Error.throwWithStackTrace(error, stackTrace),
        mapError: mapper,
      );

      expect(capturedError, same(error));
      expect(capturedStackTrace, same(stackTrace));
      expect(result.failureOrNull, same(mappedFailure));
      expect(controller.state.value.failureOrNull, same(mappedFailure));
    });
  });
}
