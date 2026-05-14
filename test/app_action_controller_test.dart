import 'dart:async';

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
  group('AppActionController', () {
    test('moves to success and sets the success message', () async {
      final controller = AppActionController<String>(
        failureHandler: noopAppFailureHandler,
      );
      addTearDown(controller.dispose);

      final result = await controller.run(
        () async => const AppResult.success('done'),
        successMessage: (_) => const UiMessage.success('Saved'),
      );

      expect(result, isA<AppSuccess<String>>());
      expect(controller.state.value, isA<AppActionSuccess<String>>());
      expect(controller.state.value.valueOrNull, 'done');
      expect(controller.message.value?.message, 'Saved');
      expect(controller.message.value?.severity, UiMessageSeverity.success);
    });

    test(
      'clears stale message at the start of run when no success message',
      () async {
        final controller = AppActionController<String>(
          failureHandler: noopAppFailureHandler,
        );
        addTearDown(controller.dispose);

        controller.message.value = const UiMessage.info('Old');

        await controller.run(() async => const AppResult.success('done'));

        expect(controller.state.value, isA<AppActionSuccess<String>>());
        expect(controller.message.value, isNull);
      },
    );

    test(
      'moves to failure and builds default error message for failure result',
      () async {
        final failure = AppFailure(
          kind: AppFailureKind.network,
          message: 'Offline',
          stackTrace: StackTrace.current,
          handler: noopAppFailureHandler,
        );
        final controller = AppActionController<String>(
          failureHandler: noopAppFailureHandler,
        );
        addTearDown(controller.dispose);

        final result = await controller.run(
          () async => AppResult.failure(failure),
        );

        expect(result, isA<AppError<String>>());
        expect(controller.state.value, isA<AppActionFailure<String>>());
        expect(
          identical(controller.state.value.failureOrNull, failure),
          isTrue,
        );
        expect(controller.message.value?.message, 'Offline');
        expect(controller.message.value?.severity, UiMessageSeverity.error);
        expect(identical(controller.message.value?.failure, failure), isTrue);
      },
    );

    test('uses custom failure message builder when provided', () async {
      final failure = AppFailure(
        kind: AppFailureKind.network,
        message: 'Offline',
        stackTrace: StackTrace.current,
        handler: noopAppFailureHandler,
      );
      final controller = AppActionController<String>(
        failureHandler: noopAppFailureHandler,
      );
      addTearDown(controller.dispose);

      await controller.run(
        () async => AppResult.failure(failure),
        failureMessage: (_) => const UiMessage.warning('Retry'),
      );

      expect(controller.state.value, isA<AppActionFailure<String>>());
      expect(controller.message.value?.message, 'Retry');
      expect(controller.message.value?.severity, UiMessageSeverity.warning);
    });

    test('maps thrown errors to unexpected failures by default', () async {
      final handler = _RecordingFailureHandler();
      final error = StateError('boom');
      final controller = AppActionController<String>(failureHandler: handler);
      addTearDown(controller.dispose);

      final result = await controller.run(() async => throw error);

      expect(result, isA<AppError<String>>());
      expect(controller.state.value, isA<AppActionFailure<String>>());
      final failure = result.failureOrNull;
      expect(failure?.kind, AppFailureKind.unknown);
      expect(failure?.message, 'Something went wrong.');
      expect(failure?.cause, same(error));
      expect(controller.message.value?.message, 'Something went wrong.');
      expect(controller.message.value?.severity, UiMessageSeverity.error);
      expect(handler.failures, [same(failure)]);
    });

    test('uses custom error mapper for thrown task errors', () async {
      final handler = _RecordingFailureHandler();
      final error = ArgumentError('bad argument');
      final stackTrace = StackTrace.current;
      late Object capturedError;
      late StackTrace capturedStackTrace;
      final controller = AppActionController<String>(failureHandler: handler);
      addTearDown(controller.dispose);

      final result = await controller.run(
        () async => Error.throwWithStackTrace(error, stackTrace),
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
      expect(
        controller.state.value.failureOrNull?.kind,
        AppFailureKind.validation,
      );
      expect(controller.message.value?.message, 'Mapped');
      expect(controller.message.value?.severity, UiMessageSeverity.error);
      expect(handler.failures, [same(result.failureOrNull)]);
    });

    test(
      'returns conflict failure when run is called while already running',
      () async {
        final handler = _RecordingFailureHandler();
        final completer = Completer<AppResult<String>>();
        final controller = AppActionController<String>(failureHandler: handler);
        addTearDown(controller.dispose);

        final firstRun = controller.run(
          () => completer.future,
          successMessage: (value) => UiMessage.success(value),
        );

        expect(controller.state.value, isA<AppActionRunning<String>>());

        final secondResult = await controller.run(
          () async => const AppResult.success('second'),
        );

        expect(secondResult.failureOrNull?.kind, AppFailureKind.conflict);
        expect(
          secondResult.failureOrNull?.message,
          'Action is already running.',
        );
        expect(controller.state.value, isA<AppActionRunning<String>>());
        expect(handler.failures, hasLength(1));
        expect(handler.failures.single.kind, AppFailureKind.conflict);

        completer.complete(const AppResult.success('first'));
        await firstRun;

        expect(controller.state.value, isA<AppActionSuccess<String>>());
        expect(controller.state.value.valueOrNull, 'first');
        expect(controller.message.value?.message, 'first');
        expect(controller.message.value?.severity, UiMessageSeverity.success);
      },
    );

    group('state and message clearing', () {
      final cases =
          <
            ({
              String name,
              void Function(AppActionController<String>) action,
              bool expectIdle,
              String? expectedValue,
              String? expectedMessage,
            })
          >[
            (
              name: 'clearResult resets state only',
              action: (controller) => controller.clearResult(),
              expectIdle: true,
              expectedValue: null,
              expectedMessage: 'Saved',
            ),
            (
              name: 'clearMessage resets message only',
              action: (controller) => controller.clearMessage(),
              expectIdle: false,
              expectedValue: 'done',
              expectedMessage: null,
            ),
            (
              name: 'reset clears both state and message',
              action: (controller) => controller.reset(),
              expectIdle: true,
              expectedValue: null,
              expectedMessage: null,
            ),
          ];

      for (final testCase in cases) {
        test(testCase.name, () async {
          final controller = AppActionController<String>(
            failureHandler: noopAppFailureHandler,
          );
          addTearDown(controller.dispose);
          await controller.run(
            () async => const AppResult.success('done'),
            successMessage: (_) => const UiMessage.success('Saved'),
          );

          testCase.action(controller);

          expect(controller.state.value.isIdle, testCase.expectIdle);
          expect(controller.state.value.valueOrNull, testCase.expectedValue);
          expect(controller.message.value?.message, testCase.expectedMessage);
        });
      }
    });
  });
}
