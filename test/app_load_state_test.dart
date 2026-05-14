import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_app_state/mvvm_app_state.dart';

void main() {
  group('AppLoadState', () {
    final failure = AppFailure.validation(
      message: 'Invalid value',
      stackTrace: StackTrace.current,
      handler: noopAppFailureHandler,
    );
    final cases =
        <
          ({
            String name,
            AppLoadState<int> state,
            Matcher stateType,
            bool isInitial,
            bool isLoading,
            bool hasData,
            bool isEmpty,
            bool isFailure,
            Matcher dataMatcher,
            Matcher failureMatcher,
          })
        >[
          (
            name: 'initial state exposes initial flags and null accessors',
            state: const AppLoadState<int>.initial(),
            stateType: isA<AppLoadInitial<int>>(),
            isInitial: true,
            isLoading: false,
            hasData: false,
            isEmpty: false,
            isFailure: false,
            dataMatcher: isNull,
            failureMatcher: isNull,
          ),
          (
            name: 'loading state without previous data exposes null data',
            state: const AppLoadState<int>.loading(),
            stateType: isA<AppLoadLoading<int>>(),
            isInitial: false,
            isLoading: true,
            hasData: false,
            isEmpty: false,
            isFailure: false,
            dataMatcher: isNull,
            failureMatcher: isNull,
          ),
          (
            name: 'loading state with previous data exposes data',
            state: const AppLoadState<int>.loading(previousData: 7),
            stateType: isA<AppLoadLoading<int>>(),
            isInitial: false,
            isLoading: true,
            hasData: true,
            isEmpty: false,
            isFailure: false,
            dataMatcher: equals(7),
            failureMatcher: isNull,
          ),
          (
            name: 'data state exposes data',
            state: const AppLoadState<int>.data(42),
            stateType: isA<AppLoadData<int>>(),
            isInitial: false,
            isLoading: false,
            hasData: true,
            isEmpty: false,
            isFailure: false,
            dataMatcher: equals(42),
            failureMatcher: isNull,
          ),
          (
            name: 'empty state without payload exposes empty flags',
            state: const AppLoadState<int>.empty(),
            stateType: isA<AppLoadEmpty<int>>(),
            isInitial: false,
            isLoading: false,
            hasData: false,
            isEmpty: true,
            isFailure: false,
            dataMatcher: isNull,
            failureMatcher: isNull,
          ),
          (
            name: 'empty state with payload still reports empty',
            state: const AppLoadState<int>.empty(data: 0),
            stateType: isA<AppLoadEmpty<int>>(),
            isInitial: false,
            isLoading: false,
            hasData: true,
            isEmpty: true,
            isFailure: false,
            dataMatcher: equals(0),
            failureMatcher: isNull,
          ),
          (
            name:
                'failure state without previous data exposes failure and null data',
            state: AppLoadState<int>.failure(failure),
            stateType: isA<AppLoadFailure<int>>(),
            isInitial: false,
            isLoading: false,
            hasData: false,
            isEmpty: false,
            isFailure: true,
            dataMatcher: isNull,
            failureMatcher: same(failure),
          ),
          (
            name: 'failure state with previous data exposes failure and data',
            state: AppLoadState<int>.failure(failure, previousData: 9),
            stateType: isA<AppLoadFailure<int>>(),
            isInitial: false,
            isLoading: false,
            hasData: true,
            isEmpty: false,
            isFailure: true,
            dataMatcher: equals(9),
            failureMatcher: same(failure),
          ),
        ];

    for (final testCase in cases) {
      test(testCase.name, () {
        expect(testCase.state, testCase.stateType);
        expect(testCase.state.isInitial, testCase.isInitial);
        expect(testCase.state.isLoading, testCase.isLoading);
        expect(testCase.state.hasData, testCase.hasData);
        expect(testCase.state.isEmpty, testCase.isEmpty);
        expect(testCase.state.isFailure, testCase.isFailure);
        expect(testCase.state.dataOrNull, testCase.dataMatcher);
        expect(testCase.state.failureOrNull, testCase.failureMatcher);
      });
    }
  });
}
