import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_app_state/mvvm_app_state.dart';

void main() {
  group('AppErrorIndicator', () {
    testWidgets('renders title and default icon', (tester) async {
      await tester.pumpWidget(
        const _TestApp(child: AppErrorIndicator(title: 'Something went wrong')),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('renders optional message and optional action', (tester) async {
      final actionButtonFinder = find.byWidgetPredicate(
        (widget) => widget is FilledButton,
      );
      final cases = <_ErrorIndicatorCase>[
        const _ErrorIndicatorCase(
          name: 'without message and without action',
          title: 'A',
          expectedMessage: null,
          hasAction: false,
        ),
        const _ErrorIndicatorCase(
          name: 'with message and without action',
          title: 'B',
          message: 'Details',
          expectedMessage: 'Details',
          hasAction: false,
        ),
        const _ErrorIndicatorCase(
          name: 'without message and with action',
          title: 'C',
          expectedMessage: null,
          hasAction: true,
        ),
        const _ErrorIndicatorCase(
          name: 'with message and with action',
          title: 'D',
          message: 'Try later',
          expectedMessage: 'Try later',
          hasAction: true,
        ),
      ];

      for (final testCase in cases) {
        var tapped = false;
        await tester.pumpWidget(
          _TestApp(
            child: AppErrorIndicator(
              title: testCase.title,
              message: testCase.message,
              onAction: testCase.hasAction ? () => tapped = true : null,
            ),
          ),
        );

        expect(
          find.text(testCase.title),
          findsOneWidget,
          reason: testCase.name,
        );
        if (testCase.expectedMessage == null) {
          expect(find.text('Details'), findsNothing, reason: testCase.name);
          expect(find.text('Try later'), findsNothing, reason: testCase.name);
        } else {
          expect(
            find.text(testCase.expectedMessage!),
            findsOneWidget,
            reason: testCase.name,
          );
        }
        expect(
          actionButtonFinder,
          testCase.hasAction ? findsOneWidget : findsNothing,
          reason: testCase.name,
        );

        if (testCase.hasAction) {
          await tester.tap(actionButtonFinder);
          expect(tapped, isTrue, reason: testCase.name);
        }
      }
    });

    testWidgets('uses custom action label and custom icon', (tester) async {
      await tester.pumpWidget(
        const _TestApp(
          child: AppErrorIndicator(
            title: 'Oops',
            actionLabel: 'Retry now',
            onAction: _noop,
            icon: Icons.wifi_off,
          ),
        ),
      );

      expect(find.text('Retry now'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
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

class _ErrorIndicatorCase {
  const _ErrorIndicatorCase({
    required this.name,
    required this.title,
    required this.expectedMessage,
    required this.hasAction,
    this.message,
  });

  final String name;
  final String title;
  final String? message;
  final String? expectedMessage;
  final bool hasAction;
}

void _noop() {}
