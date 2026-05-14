import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_app_state/mvvm_app_state.dart';

void main() {
  group('AppActionState', () {
    final failure = AppFailure(
      kind: AppFailureKind.validation,
      message: 'Invalid value',
      stackTrace: StackTrace.current,
      handler: noopAppFailureHandler,
    );
    final cases =
        <
          ({
            String name,
            AppActionState<int> state,
            Matcher stateType,
            bool isIdle,
            bool isRunning,
            bool isSuccess,
            bool isFailure,
            Matcher valueMatcher,
            Matcher failureMatcher,
          })
        >[
          (
            name: 'idle state exposes idle flags and null accessors',
            state: const AppActionState<int>.idle(),
            stateType: isA<AppActionIdle<int>>(),
            isIdle: true,
            isRunning: false,
            isSuccess: false,
            isFailure: false,
            valueMatcher: isNull,
            failureMatcher: isNull,
          ),
          (
            name: 'running state exposes running flags and null accessors',
            state: const AppActionState<int>.running(),
            stateType: isA<AppActionRunning<int>>(),
            isIdle: false,
            isRunning: true,
            isSuccess: false,
            isFailure: false,
            valueMatcher: isNull,
            failureMatcher: isNull,
          ),
          (
            name: 'success state exposes success flags and value',
            state: const AppActionState<int>.success(42),
            stateType: isA<AppActionSuccess<int>>(),
            isIdle: false,
            isRunning: false,
            isSuccess: true,
            isFailure: false,
            valueMatcher: equals(42),
            failureMatcher: isNull,
          ),
          (
            name: 'failure state exposes failure flags and failure',
            state: AppActionState<int>.failure(failure),
            stateType: isA<AppActionFailure<int>>(),
            isIdle: false,
            isRunning: false,
            isSuccess: false,
            isFailure: true,
            valueMatcher: isNull,
            failureMatcher: same(failure),
          ),
        ];

    for (final testCase in cases) {
      test(testCase.name, () {
        expect(testCase.state, testCase.stateType);
        expect(testCase.state.isIdle, testCase.isIdle);
        expect(testCase.state.isRunning, testCase.isRunning);
        expect(testCase.state.isSuccess, testCase.isSuccess);
        expect(testCase.state.isFailure, testCase.isFailure);
        expect(testCase.state.valueOrNull, testCase.valueMatcher);
        expect(testCase.state.failureOrNull, testCase.failureMatcher);
      });
    }
  });
}
