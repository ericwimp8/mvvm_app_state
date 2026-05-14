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
  group('AppLoadController', () {
    test('starts in initial state by default', () {
      final controller = AppLoadController<List<int>>(
        failureHandler: noopAppFailureHandler,
      );
      addTearDown(controller.dispose);

      expect(controller.state.value, isA<AppLoadInitial<List<int>>>());
      expect(controller.state.value.isInitial, isTrue);
      expect(controller.state.value.dataOrNull, isNull);
      expect(controller.state.value.failureOrNull, isNull);
    });

    test('supports a custom initial state', () {
      final initialState = AppLoadState<List<int>>.data(<int>[1, 2]);
      final controller = AppLoadController<List<int>>(
        failureHandler: noopAppFailureHandler,
        initialState: initialState,
      );
      addTearDown(controller.dispose);

      expect(controller.state.value, isA<AppLoadData<List<int>>>());
      expect(controller.state.value.dataOrNull, <int>[1, 2]);
    });

    group('run', () {
      test('moves to loading immediately and then data on success', () async {
        final controller = AppLoadController<List<int>>(
          failureHandler: noopAppFailureHandler,
        );
        addTearDown(controller.dispose);
        final completer = Completer<AppResult<List<int>>>();

        final runFuture = controller.run(() => completer.future);

        expect(controller.state.value, isA<AppLoadLoading<List<int>>>());
        expect(controller.state.value.dataOrNull, isNull);

        completer.complete(const AppResult.success(<int>[5, 6]));
        final result = await runFuture;

        expect(result, isA<AppSuccess<List<int>>>());
        expect(result.valueOrNull, <int>[5, 6]);
        expect(controller.state.value, isA<AppLoadData<List<int>>>());
        expect(controller.state.value.dataOrNull, <int>[5, 6]);
      });

      test(
        'keeps previous data while loading and on failure when requested',
        () async {
          final failure = AppFailure.validation(
            message: 'No internet',
            stackTrace: StackTrace.current,
            handler: noopAppFailureHandler,
          );
          final controller = AppLoadController<List<int>>(
            failureHandler: noopAppFailureHandler,
          );
          addTearDown(controller.dispose);
          controller.setData(<int>[9]);
          final completer = Completer<AppResult<List<int>>>();

          final runFuture = controller.run(
            () => completer.future,
            preserveData: true,
          );

          expect(controller.state.value, isA<AppLoadLoading<List<int>>>());
          expect(controller.state.value.dataOrNull, <int>[9]);

          completer.complete(AppResult.failure(failure));
          final result = await runFuture;

          expect(result.failureOrNull, same(failure));
          expect(controller.state.value, isA<AppLoadFailure<List<int>>>());
          expect(controller.state.value.failureOrNull, same(failure));
          expect(controller.state.value.dataOrNull, <int>[9]);
        },
      );

      test(
        'clears previous data while loading and on failure by default',
        () async {
          final failure = AppFailure.validation(
            message: 'No internet',
            stackTrace: StackTrace.current,
            handler: noopAppFailureHandler,
          );
          final controller = AppLoadController<List<int>>(
            failureHandler: noopAppFailureHandler,
          );
          addTearDown(controller.dispose);
          controller.setData(<int>[9]);
          final completer = Completer<AppResult<List<int>>>();

          final runFuture = controller.run(() => completer.future);

          expect(controller.state.value, isA<AppLoadLoading<List<int>>>());
          expect(controller.state.value.dataOrNull, isNull);

          completer.complete(AppResult.failure(failure));
          final result = await runFuture;

          expect(result.failureOrNull, same(failure));
          expect(controller.state.value, isA<AppLoadFailure<List<int>>>());
          expect(controller.state.value.failureOrNull, same(failure));
          expect(controller.state.value.dataOrNull, isNull);
        },
      );

      test('maps thrown errors to unexpected failures by default', () async {
        final handler = _RecordingFailureHandler();
        final error = StateError('boom');
        final controller = AppLoadController<List<int>>(
          failureHandler: handler,
        );
        addTearDown(controller.dispose);

        final result = await controller.run(() async => throw error);

        expect(result, isA<AppError<List<int>>>());
        final failure = result.failureOrNull;
        expect(failure?.kind, AppFailureKind.unknown);
        expect(failure?.message, 'Something went wrong.');
        expect(failure?.cause, same(error));
        expect(controller.state.value, isA<AppLoadFailure<List<int>>>());
        expect(controller.state.value.failureOrNull, same(failure));
        expect(handler.failures, [same(failure)]);
      });

      test('uses custom error mapper for thrown task errors', () async {
        final handler = _RecordingFailureHandler();
        final error = ArgumentError('bad argument');
        final stackTrace = StackTrace.current;
        late Object capturedError;
        late StackTrace capturedStackTrace;
        final controller = AppLoadController<List<int>>(
          failureHandler: handler,
        );
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
        expect(controller.state.value, isA<AppLoadFailure<List<int>>>());
        expect(
          controller.state.value.failureOrNull?.kind,
          AppFailureKind.validation,
        );
        expect(handler.failures, [same(result.failureOrNull)]);
      });

      group('empty predicates', () {
        final cases =
            <
              ({
                String name,
                List<int> value,
                AppEmptyPredicate<List<int>>? controllerIsEmpty,
                AppEmptyPredicate<List<int>>? runIsEmpty,
                bool expectEmpty,
              })
            >[
              (
                name: 'uses default iterable predicate for empty list',
                value: <int>[],
                controllerIsEmpty: null,
                runIsEmpty: null,
                expectEmpty: true,
              ),
              (
                name: 'uses default iterable predicate for non-empty list',
                value: <int>[1],
                controllerIsEmpty: null,
                runIsEmpty: null,
                expectEmpty: false,
              ),
              (
                name: 'uses constructor predicate when run predicate is absent',
                value: <int>[1],
                controllerIsEmpty: (_) => true,
                runIsEmpty: null,
                expectEmpty: true,
              ),
              (
                name: 'run predicate overrides constructor predicate',
                value: <int>[1],
                controllerIsEmpty: (_) => true,
                runIsEmpty: (_) => false,
                expectEmpty: false,
              ),
            ];

        for (final testCase in cases) {
          test(testCase.name, () async {
            final controller = AppLoadController<List<int>>(
              failureHandler: noopAppFailureHandler,
              isEmpty: testCase.controllerIsEmpty,
            );
            addTearDown(controller.dispose);

            final result = await controller.run(
              () async => AppResult.success(testCase.value),
              isEmpty: testCase.runIsEmpty,
            );

            expect(result.valueOrNull, testCase.value);
            expect(controller.state.value.dataOrNull, testCase.value);
            expect(controller.state.value.isEmpty, testCase.expectEmpty);
            expect(
              controller.state.value is AppLoadData<List<int>>,
              !testCase.expectEmpty,
            );
          });
        }
      });
    });

    group('setData', () {
      final cases =
          <
            ({
              String name,
              List<int> value,
              AppEmptyPredicate<List<int>>? controllerIsEmpty,
              AppEmptyPredicate<List<int>>? setDataIsEmpty,
              bool expectEmpty,
            })
          >[
            (
              name: 'uses default iterable predicate for empty list',
              value: <int>[],
              controllerIsEmpty: null,
              setDataIsEmpty: null,
              expectEmpty: true,
            ),
            (
              name: 'uses default iterable predicate for non-empty list',
              value: <int>[1],
              controllerIsEmpty: null,
              setDataIsEmpty: null,
              expectEmpty: false,
            ),
            (
              name:
                  'uses constructor predicate when setData predicate is absent',
              value: <int>[1],
              controllerIsEmpty: (_) => true,
              setDataIsEmpty: null,
              expectEmpty: true,
            ),
            (
              name: 'setData predicate overrides constructor predicate',
              value: <int>[1],
              controllerIsEmpty: (_) => true,
              setDataIsEmpty: (_) => false,
              expectEmpty: false,
            ),
          ];

      for (final testCase in cases) {
        test(testCase.name, () {
          final controller = AppLoadController<List<int>>(
            failureHandler: noopAppFailureHandler,
            isEmpty: testCase.controllerIsEmpty,
          );
          addTearDown(controller.dispose);

          controller.setData(testCase.value, isEmpty: testCase.setDataIsEmpty);

          expect(controller.state.value.dataOrNull, testCase.value);
          expect(controller.state.value.isEmpty, testCase.expectEmpty);
          expect(
            controller.state.value is AppLoadData<List<int>>,
            !testCase.expectEmpty,
          );
        });
      }
    });

    group('setFailure', () {
      final failure = AppFailure.validation(
        message: 'Bad request',
        stackTrace: StackTrace.current,
        handler: noopAppFailureHandler,
      );
      final cases =
          <({String name, bool? preserveData, List<int>? expectedData})>[
            (
              name: 'preserves previous data by default',
              preserveData: null,
              expectedData: <int>[7],
            ),
            (
              name: 'preserves previous data when preserveData is true',
              preserveData: true,
              expectedData: <int>[7],
            ),
            (
              name: 'clears previous data when preserveData is false',
              preserveData: false,
              expectedData: null,
            ),
          ];

      for (final testCase in cases) {
        test(testCase.name, () {
          final controller = AppLoadController<List<int>>(
            failureHandler: noopAppFailureHandler,
          );
          addTearDown(controller.dispose);
          controller.setData(<int>[7]);

          if (testCase.preserveData == null) {
            controller.setFailure(failure);
          } else {
            controller.setFailure(
              failure,
              preserveData: testCase.preserveData!,
            );
          }

          expect(controller.state.value, isA<AppLoadFailure<List<int>>>());
          expect(controller.state.value.failureOrNull, same(failure));
          expect(controller.state.value.dataOrNull, testCase.expectedData);
        });
      }
    });

    test('reset returns state to initial', () {
      final controller = AppLoadController<List<int>>(
        failureHandler: noopAppFailureHandler,
      );
      addTearDown(controller.dispose);
      controller.setData(<int>[1]);

      controller.reset();

      expect(controller.state.value, isA<AppLoadInitial<List<int>>>());
      expect(controller.state.value.dataOrNull, isNull);
      expect(controller.state.value.failureOrNull, isNull);
    });

    test('dispose is callable', () {
      final controller = AppLoadController<List<int>>(
        failureHandler: noopAppFailureHandler,
      );

      expect(controller.dispose, returnsNormally);
    });
  });
}
