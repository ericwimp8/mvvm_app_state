import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_app_state/mvvm_app_state.dart';

void main() {
  group('AppUiMessageListener', () {
    testWidgets('shows message and calls onConsumed once per unique key', (
      tester,
    ) async {
      var consumedCount = 0;

      await _pumpListener(
        tester,
        message: const UiMessage.info('Saved'),
        onConsumed: () => consumedCount += 1,
      );
      await tester.pump();

      expect(find.text('Saved'), findsOneWidget);
      expect(consumedCount, 1);

      await _pumpListener(
        tester,
        message: const UiMessage.info('Saved'),
        onConsumed: () => consumedCount += 1,
      );
      await tester.pump();

      expect(consumedCount, 1);

      await _pumpListener(
        tester,
        message: const UiMessage.info('Saved again', id: 'message-2'),
        onConsumed: () => consumedCount += 1,
      );
      await tester.pump();

      expect(find.text('Saved again'), findsOneWidget);
      expect(consumedCount, 2);
    });

    testWidgets('does nothing when message is null', (tester) async {
      var consumedCount = 0;

      await _pumpListener(
        tester,
        message: null,
        onConsumed: () => consumedCount += 1,
      );
      await tester.pump();

      expect(find.byType(SnackBar), findsNothing);
      expect(consumedCount, 0);
    });

    testWidgets('uses custom snackBarBuilder when provided', (tester) async {
      final message = UiMessage.success('Created');
      UiMessage? builtMessage;

      await _pumpListener(
        tester,
        message: message,
        snackBarBuilder: (context, currentMessage) {
          builtMessage = currentMessage;
          return const SnackBar(
            content: Text('Custom snack bar'),
            duration: Duration(seconds: 5),
          );
        },
      );
      await tester.pump();

      expect(find.text('Custom snack bar'), findsOneWidget);
      expect(find.text('Created'), findsNothing);
      expect(builtMessage, same(message));
    });

    testWidgets('does not call onConsumed when no ScaffoldMessenger exists', (
      tester,
    ) async {
      var consumedCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AppUiMessageListener(
            message: const UiMessage.warning('Heads up'),
            onConsumed: () => consumedCount += 1,
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SnackBar), findsNothing);
      expect(consumedCount, 0);
    });

    testWidgets('default snackbar icon matches severity', (tester) async {
      final cases = <({UiMessage message, IconData expectedIcon})>[
        (
          message: const UiMessage.info('Info'),
          expectedIcon: Icons.info_outline,
        ),
        (
          message: const UiMessage.success('Success'),
          expectedIcon: Icons.check_circle_outline,
        ),
        (
          message: const UiMessage.warning('Warning'),
          expectedIcon: Icons.warning_amber_outlined,
        ),
        (
          message: const UiMessage.error('Error'),
          expectedIcon: Icons.error_outline,
        ),
      ];

      for (final testCase in cases) {
        await _pumpListener(tester, message: testCase.message);
        await tester.pump();

        expect(find.byIcon(testCase.expectedIcon), findsOneWidget);
        expect(find.text(testCase.message.message), findsOneWidget);
      }
    });

    testWidgets('default snackbar duration uses message duration or fallback', (
      tester,
    ) async {
      final cases =
          <({String name, UiMessage message, Duration expectedDuration})>[
            (
              name: 'uses fallback when duration is absent',
              message: const UiMessage.info('Default duration'),
              expectedDuration: const Duration(seconds: 4),
            ),
            (
              name: 'uses explicit message duration when present',
              message: const UiMessage.info(
                'Custom duration',
                duration: Duration(milliseconds: 350),
              ),
              expectedDuration: const Duration(milliseconds: 350),
            ),
          ];

      for (final testCase in cases) {
        await _pumpListener(tester, message: testCase.message);
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(
          snackBar.duration,
          testCase.expectedDuration,
          reason: testCase.name,
        );
      }
    });

    testWidgets(
      'clearExisting false keeps current snackbar visible immediately',
      (tester) async {
        await _pumpListener(
          tester,
          message: const UiMessage.info(
            'First message',
            id: 'first',
            duration: Duration(seconds: 5),
          ),
          clearExisting: false,
        );
        await tester.pump();
        expect(find.text('First message'), findsOneWidget);

        await _pumpListener(
          tester,
          message: const UiMessage.info('Second message', id: 'second'),
          clearExisting: false,
        );
        await tester.pump();

        expect(find.text('First message'), findsOneWidget);
        expect(find.text('Second message'), findsNothing);
      },
    );

    testWidgets(
      'clearExisting true replaces current snackbar with new message',
      (tester) async {
        await _pumpListener(
          tester,
          message: const UiMessage.info(
            'First message',
            id: 'first',
            duration: Duration(seconds: 5),
          ),
        );
        await tester.pump();
        expect(find.text('First message'), findsOneWidget);

        await _pumpListener(
          tester,
          message: const UiMessage.info('Second message', id: 'second'),
        );
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('First message'), findsNothing);
        expect(find.text('Second message'), findsOneWidget);
      },
    );
  });
}

Future<void> _pumpListener(
  WidgetTester tester, {
  required UiMessage? message,
  VoidCallback? onConsumed,
  AppSnackBarBuilder? snackBarBuilder,
  bool clearExisting = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AppUiMessageListener(
          message: message,
          onConsumed: onConsumed,
          snackBarBuilder: snackBarBuilder,
          clearExisting: clearExisting,
          child: const SizedBox.shrink(),
        ),
      ),
    ),
  );
}
