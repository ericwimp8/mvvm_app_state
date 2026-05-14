import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_app_state/mvvm_app_state.dart';

void main() {
  group('UiMessage', () {
    test('exposes expected severity values in declaration order', () {
      expect(UiMessageSeverity.values, [
        UiMessageSeverity.info,
        UiMessageSeverity.success,
        UiMessageSeverity.warning,
        UiMessageSeverity.error,
      ]);
    });

    group('constructors', () {
      final failure = AppFailure.validation(
        message: 'Invalid',
        stackTrace: StackTrace.current,
        handler: noopAppFailureHandler,
      );
      final cases =
          <
            ({
              String name,
              UiMessage message,
              UiMessageSeverity expectedSeverity,
              String expectedMessage,
              String? expectedId,
              String? expectedTitle,
              AppFailure? expectedFailure,
              Duration? expectedDuration,
            })
          >[
            (
              name: 'base constructor defaults to info severity',
              message: const UiMessage(
                message: 'Hello',
                id: 'base-1',
                title: 'Greeting',
                duration: Duration(seconds: 3),
              ),
              expectedSeverity: UiMessageSeverity.info,
              expectedMessage: 'Hello',
              expectedId: 'base-1',
              expectedTitle: 'Greeting',
              expectedFailure: null,
              expectedDuration: Duration(seconds: 3),
            ),
            (
              name: 'info constructor maps to info severity',
              message: const UiMessage.info(
                'Saved',
                id: 'info-1',
                title: 'Done',
                duration: Duration(milliseconds: 500),
              ),
              expectedSeverity: UiMessageSeverity.info,
              expectedMessage: 'Saved',
              expectedId: 'info-1',
              expectedTitle: 'Done',
              expectedFailure: null,
              expectedDuration: Duration(milliseconds: 500),
            ),
            (
              name: 'success constructor maps to success severity',
              message: const UiMessage.success(
                'Created',
                id: 'success-1',
                title: 'Great',
                duration: Duration(seconds: 2),
              ),
              expectedSeverity: UiMessageSeverity.success,
              expectedMessage: 'Created',
              expectedId: 'success-1',
              expectedTitle: 'Great',
              expectedFailure: null,
              expectedDuration: Duration(seconds: 2),
            ),
            (
              name: 'warning constructor maps to warning severity',
              message: const UiMessage.warning(
                'Limited',
                id: 'warning-1',
                title: 'Heads up',
              ),
              expectedSeverity: UiMessageSeverity.warning,
              expectedMessage: 'Limited',
              expectedId: 'warning-1',
              expectedTitle: 'Heads up',
              expectedFailure: null,
              expectedDuration: null,
            ),
            (
              name: 'error constructor maps to error severity and failure',
              message: UiMessage.error(
                'Failed',
                id: 'error-1',
                title: 'Problem',
                failure: failure,
                duration: const Duration(seconds: 1),
              ),
              expectedSeverity: UiMessageSeverity.error,
              expectedMessage: 'Failed',
              expectedId: 'error-1',
              expectedTitle: 'Problem',
              expectedFailure: failure,
              expectedDuration: const Duration(seconds: 1),
            ),
          ];

      for (final testCase in cases) {
        test(testCase.name, () {
          expect(testCase.message.severity, testCase.expectedSeverity);
          expect(testCase.message.message, testCase.expectedMessage);
          expect(testCase.message.id, testCase.expectedId);
          expect(testCase.message.title, testCase.expectedTitle);
          expect(testCase.message.failure, same(testCase.expectedFailure));
          expect(testCase.message.duration, testCase.expectedDuration);
        });
      }
    });

    group('key', () {
      test('returns id when present', () {
        const message = UiMessage.success(
          'Saved',
          id: 'message-id',
          title: 'Done',
        );

        expect(message.key, 'message-id');
      });

      test('derives key from severity message and title when id absent', () {
        const withTitle = UiMessage.warning('Almost full', title: 'Storage');
        const withoutTitle = UiMessage.warning('Almost full');

        expect(withTitle.key, 'UiMessageSeverity.warning:Almost full:Storage');
        expect(withoutTitle.key, 'UiMessageSeverity.warning:Almost full:');
      });
    });
  });
}
