import 'dart:async';

import 'package:mvvm_app_state/mvvm_app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppActionController', () {
    test('emits success state and optional success message', () async {
      final controller = AppActionController<String>(
        reportFailure: noopAppFailureReporter,
      );
      addTearDown(controller.dispose);

      await controller.run(
        () async => const AppResult.success('saved'),
        successMessage: (value) => UiMessage.success(value),
      );

      expect(controller.state.value, isA<AppActionSuccess<String>>());
      expect(controller.state.value.valueOrNull, 'saved');
      expect(controller.message.value?.severity, UiMessageSeverity.success);
      expect(controller.message.value?.message, 'saved');
    });

    test('emits failure state and default error message', () async {
      final controller = AppActionController<void>(
        reportFailure: noopAppFailureReporter,
      );
      addTearDown(controller.dispose);

      await controller.run(
        () async => AppResult.failure(
          AppFailure(
            kind: AppFailureKind.persistence,
            message: 'Save failed',
            report: noopAppFailureReporter,
          ),
        ),
      );

      expect(controller.state.value, isA<AppActionFailure<void>>());
      expect(
        controller.state.value.failureOrNull?.kind,
        AppFailureKind.persistence,
      );
      expect(controller.message.value?.severity, UiMessageSeverity.error);
      expect(controller.message.value?.message, 'Save failed');
    });

    test('does not run the same action twice concurrently', () async {
      final controller = AppActionController<void>(
        reportFailure: noopAppFailureReporter,
      );
      final completer = Completer<AppResult<void>>();
      var calls = 0;
      addTearDown(controller.dispose);

      final first = controller.run(() {
        calls += 1;
        return completer.future;
      });
      final second = await controller.run(() async {
        calls += 1;
        return const AppResult.success(null);
      });

      completer.complete(const AppResult.success(null));
      await first;

      expect(calls, 1);
      expect(second.failureOrNull?.kind, AppFailureKind.conflict);
    });

    test(
      'converts thrown task errors into failure state and message',
      () async {
        final controller = AppActionController<void>(
          reportFailure: noopAppFailureReporter,
        );
        addTearDown(controller.dispose);

        final result = await controller.run(
          () async => throw StateError('broken'),
        );

        expect(result.isFailure, isTrue);
        expect(controller.state.value, isA<AppActionFailure<void>>());
        expect(controller.state.value.failureOrNull?.cause, isA<StateError>());
        expect(controller.message.value?.severity, UiMessageSeverity.error);
      },
    );

    test('clears result and message independently', () async {
      final controller = AppActionController<void>(
        reportFailure: noopAppFailureReporter,
      );
      addTearDown(controller.dispose);

      await controller.run(
        () async => const AppResult.success(null),
        successMessage: (_) => const UiMessage.success('Done'),
      );
      controller.clearMessage();
      controller.clearResult();

      expect(controller.message.value, isNull);
      expect(controller.state.value, isA<AppActionIdle<void>>());
    });
  });
}
