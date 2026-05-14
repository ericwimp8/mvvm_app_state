import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_app_state/mvvm_app_state.dart';

void main() {
  group('AppLoadContent', () {
    final failure = AppFailure.validation(
      message: 'Unable to load data',
      stackTrace: StackTrace.empty,
      handler: noopAppFailureHandler,
    );

    final defaultCases =
        <
          ({
            String name,
            AppLoadState<String> state,
            Finder Function() expectedFinder,
          })
        >[
          (
            name: 'initial state shows default loading indicator',
            state: const AppLoadState<String>.initial(),
            expectedFinder: () => find.byType(CircularProgressIndicator),
          ),
          (
            name: 'loading state shows default loading indicator',
            state: const AppLoadState<String>.loading(),
            expectedFinder: () => find.byType(CircularProgressIndicator),
          ),
          (
            name: 'empty state shows default empty text',
            state: const AppLoadState<String>.empty(),
            expectedFinder: () => find.text('No results.'),
          ),
          (
            name: 'failure state shows default error indicator title',
            state: AppLoadState<String>.failure(failure),
            expectedFinder: () => find.text('Unable to load data'),
          ),
        ];

    for (final testCase in defaultCases) {
      testWidgets(testCase.name, (tester) async {
        await _pumpLoadContent(tester, state: testCase.state, onRetry: _noop);

        expect(testCase.expectedFinder(), findsOneWidget);
        expect(find.text('Data: value'), findsNothing);
      });
    }

    testWidgets('data state renders using builder payload', (tester) async {
      await _pumpLoadContent(
        tester,
        state: const AppLoadState<String>.data('A'),
      );

      expect(find.text('Data: A'), findsOneWidget);
    });

    testWidgets(
      'loading and failure states render previous data when enabled',
      (tester) async {
        final cases =
            <
              ({
                String name,
                AppLoadState<String> state,
                bool showPreviousDataWhileLoading,
                bool showPreviousDataOnFailure,
                Finder Function() expectedFinder,
              })
            >[
              (
                name: 'loading uses previous data',
                state: const AppLoadState<String>.loading(previousData: 'prev'),
                showPreviousDataWhileLoading: true,
                showPreviousDataOnFailure: false,
                expectedFinder: () => find.text('Data: prev'),
              ),
              (
                name: 'failure uses previous data',
                state: AppLoadState<String>.failure(
                  failure,
                  previousData: 'prev',
                ),
                showPreviousDataWhileLoading: false,
                showPreviousDataOnFailure: true,
                expectedFinder: () => find.text('Data: prev'),
              ),
            ];

        for (final testCase in cases) {
          await _pumpLoadContent(
            tester,
            state: testCase.state,
            showPreviousDataWhileLoading: testCase.showPreviousDataWhileLoading,
            showPreviousDataOnFailure: testCase.showPreviousDataOnFailure,
            loadingBuilder: (_) => const Text('Loading...'),
          );

          expect(
            testCase.expectedFinder(),
            findsOneWidget,
            reason: testCase.name,
          );
        }
      },
    );

    testWidgets(
      'loading and failure states ignore previous data when disabled',
      (tester) async {
        final cases =
            <
              ({
                String name,
                AppLoadState<String> state,
                bool showPreviousDataWhileLoading,
                bool showPreviousDataOnFailure,
                Finder Function() expectedFinder,
              })
            >[
              (
                name: 'loading falls back to loading builder',
                state: const AppLoadState<String>.loading(previousData: 'prev'),
                showPreviousDataWhileLoading: false,
                showPreviousDataOnFailure: false,
                expectedFinder: () => find.text('Loading...'),
              ),
              (
                name: 'failure falls back to error indicator',
                state: AppLoadState<String>.failure(
                  failure,
                  previousData: 'prev',
                ),
                showPreviousDataWhileLoading: false,
                showPreviousDataOnFailure: false,
                expectedFinder: () => find.text('Unable to load data'),
              ),
            ];

        for (final testCase in cases) {
          await _pumpLoadContent(
            tester,
            state: testCase.state,
            showPreviousDataWhileLoading: testCase.showPreviousDataWhileLoading,
            showPreviousDataOnFailure: testCase.showPreviousDataOnFailure,
            loadingBuilder: (_) => const Text('Loading...'),
          );

          expect(
            testCase.expectedFinder(),
            findsOneWidget,
            reason: testCase.name,
          );
        }
      },
    );

    testWidgets('initial state prefers initial builder over loading builder', (
      tester,
    ) async {
      await _pumpLoadContent(
        tester,
        state: const AppLoadState<String>.initial(),
        initialBuilder: (_) => const Text('Initial...'),
        loadingBuilder: (_) => const Text('Loading...'),
      );

      expect(find.text('Initial...'), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('empty state uses custom empty builder when provided', (
      tester,
    ) async {
      await _pumpLoadContent(
        tester,
        state: const AppLoadState<String>.empty(),
        emptyBuilder: (_) => const Text('No items here'),
      );

      expect(find.text('No items here'), findsOneWidget);
      expect(find.text('No results.'), findsNothing);
    });

    testWidgets('error builder receives failure and retry callback', (
      tester,
    ) async {
      var retryTapped = false;
      AppFailure? receivedFailure;
      VoidCallback? receivedRetry;

      await _pumpLoadContent(
        tester,
        state: AppLoadState<String>.failure(failure),
        onRetry: () => retryTapped = true,
        errorBuilder: (context, currentFailure, retry) {
          receivedFailure = currentFailure;
          receivedRetry = retry;
          return FilledButton(
            onPressed: retry,
            child: const Text('Custom retry'),
          );
        },
      );

      expect(receivedFailure, same(failure));
      expect(receivedRetry, isNotNull);
      expect(find.byType(AppErrorIndicator), findsNothing);

      await tester.tap(find.text('Custom retry'));
      expect(retryTapped, isTrue);
    });

    testWidgets('default error indicator triggers retry callback', (
      tester,
    ) async {
      var retryTapped = false;

      await _pumpLoadContent(
        tester,
        state: AppLoadState<String>.failure(failure),
        onRetry: () => retryTapped = true,
      );

      await tester.tap(find.text('Try again'));
      expect(retryTapped, isTrue);
    });
  });
}

Future<void> _pumpLoadContent(
  WidgetTester tester, {
  required AppLoadState<String> state,
  VoidCallback? onRetry,
  WidgetBuilder? initialBuilder,
  WidgetBuilder? loadingBuilder,
  WidgetBuilder? emptyBuilder,
  AppFailureWidgetBuilder? errorBuilder,
  bool showPreviousDataWhileLoading = false,
  bool showPreviousDataOnFailure = false,
}) async {
  await tester.pumpWidget(
    _TestApp(
      child: AppLoadContent<String>(
        state: state,
        builder: (context, data) => Text('Data: $data'),
        onRetry: onRetry,
        initialBuilder: initialBuilder,
        loadingBuilder: loadingBuilder,
        emptyBuilder: emptyBuilder,
        errorBuilder: errorBuilder,
        showPreviousDataWhileLoading: showPreviousDataWhileLoading,
        showPreviousDataOnFailure: showPreviousDataOnFailure,
      ),
    ),
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}

void _noop() {}
