import 'package:mvvm_app_state/mvvm_app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLoadController', () {
    test('moves from initial to data after a successful load', () async {
      final controller = AppLoadController<List<String>>(
        reportFailure: noopAppFailureReporter,
      );
      addTearDown(controller.dispose);

      await controller.run(() async => const AppResult.success(['a']));

      expect(controller.state.value, isA<AppLoadData<List<String>>>());
      expect(controller.state.value.dataOrNull, ['a']);
    });

    test('uses empty state for empty iterables by default', () async {
      final controller = AppLoadController<List<String>>(
        reportFailure: noopAppFailureReporter,
      );
      addTearDown(controller.dispose);

      await controller.run(() async => const AppResult.success([]));

      expect(controller.state.value, isA<AppLoadEmpty<List<String>>>());
      expect(controller.state.value.dataOrNull, isEmpty);
    });

    test('preserves previous data when a refresh fails', () async {
      final controller = AppLoadController<List<String>>(
        reportFailure: noopAppFailureReporter,
      );
      addTearDown(controller.dispose);

      controller.setData(['current']);
      await controller.run(
        () async => AppResult.failure(
          AppFailure(
            kind: AppFailureKind.network,
            message: 'Offline',
            report: noopAppFailureReporter,
          ),
        ),
        preserveData: true,
      );

      final state = controller.state.value;
      expect(state, isA<AppLoadFailure<List<String>>>());
      expect(state.dataOrNull, ['current']);
      expect(state.failureOrNull?.message, 'Offline');
    });

    test('converts thrown task errors into failure state', () async {
      final controller = AppLoadController<String>(
        reportFailure: noopAppFailureReporter,
      );
      addTearDown(controller.dispose);

      final result = await controller.run(
        () async => throw StateError('broken'),
      );

      expect(result.isFailure, isTrue);
      expect(controller.state.value, isA<AppLoadFailure<String>>());
      expect(controller.state.value.failureOrNull?.cause, isA<StateError>());
    });

    test('can reset to initial state', () {
      final controller = AppLoadController<String>(
        reportFailure: noopAppFailureReporter,
      );
      addTearDown(controller.dispose);

      controller.setData('loaded');
      controller.reset();

      expect(controller.state.value, isA<AppLoadInitial<String>>());
    });
  });
}
