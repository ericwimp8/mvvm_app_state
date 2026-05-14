import 'package:mvvm_app_state/mvvm_app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLoadContent', () {
    testWidgets('renders data, empty, loading, and failure states', (
      tester,
    ) async {
      await tester.pumpWidget(
        _TestApp(
          child: AppLoadContent<List<String>>(
            state: const AppLoadState.data(['A']),
            builder: (context, data) => Text(data.single),
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);

      await tester.pumpWidget(
        _TestApp(
          child: AppLoadContent<List<String>>(
            state: const AppLoadState.empty(data: []),
            builder: (context, data) => Text(data.join()),
          ),
        ),
      );
      expect(find.text('No results.'), findsOneWidget);

      await tester.pumpWidget(
        _TestApp(
          child: AppLoadContent<List<String>>(
            state: const AppLoadState.loading(),
            builder: (context, data) => Text(data.join()),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        _TestApp(
          child: AppLoadContent<List<String>>(
            state: AppLoadState.failure(
              AppFailure(
                kind: AppFailureKind.network,
                message: 'Offline',
                report: noopAppFailureReporter,
              ),
            ),
            builder: (context, data) => Text(data.join()),
          ),
        ),
      );
      expect(find.text('Offline'), findsOneWidget);
    });
  });

  group('AppUiMessageListener', () {
    testWidgets('shows snackbar and consumes message', (tester) async {
      var consumed = false;

      await tester.pumpWidget(
        _TestApp(
          child: AppUiMessageListener(
            message: const UiMessage.success('Saved'),
            onConsumed: () => consumed = true,
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Saved'), findsOneWidget);
      expect(consumed, isTrue);
    });
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: child));
  }
}
