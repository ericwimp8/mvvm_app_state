# Unit Test Orchestration Progress

Sequential worker settings:
- model: `gpt-5.3-codex`
- reasoning: `high`
- fork context: `false`
- one worker at a time

## Targets

- [x] `lib/src/app_action_controller.dart`
  - Test file: `test/app_action_controller_test.dart`
  - Checks: `dart format test/app_action_controller_test.dart`; `dart analyze test/app_action_controller_test.dart`; `flutter test test/app_action_controller_test.dart`
  - Status: completed
- [x] `lib/src/app_action_state.dart`
  - Test file: `test/app_action_state_test.dart`
  - Checks: `dart format test/app_action_state_test.dart`; `dart analyze test/app_action_state_test.dart`; `flutter test test/app_action_state_test.dart`
  - Status: completed
- [x] `lib/src/app_failure.dart`
  - Test file: `test/app_failure_test.dart`
  - Checks: `dart format test/app_failure_test.dart`; `dart analyze test/app_failure_test.dart lib/src/app_failure.dart`; `flutter test test/app_failure_test.dart`
  - Status: completed
- [x] `lib/src/app_failure_kind.dart`
  - Test file: `test/app_failure_kind_test.dart`
  - Checks: `dart format test/app_failure_kind_test.dart`; `dart analyze test/app_failure_kind_test.dart`; `flutter test test/app_failure_kind_test.dart`
  - Status: completed
- [x] `lib/src/app_failure_mapper.dart`
  - Test file: `test/app_failure_mapper_test.dart`
  - Checks: `dart format test/app_failure_mapper_test.dart`; `dart analyze test/app_failure_mapper_test.dart`; `flutter test test/app_failure_mapper_test.dart`
  - Status: completed
- [x] `lib/src/app_load_controller.dart`
  - Test file: `test/app_load_controller_test.dart`
  - Checks: `dart format test/app_load_controller_test.dart`; `dart analyze test/app_load_controller_test.dart`; `flutter test test/app_load_controller_test.dart`
  - Status: completed
- [x] `lib/src/app_load_state.dart`
  - Test file: `test/app_load_state_test.dart`
  - Checks: `dart format test/app_load_state_test.dart`; `dart analyze test/app_load_state_test.dart`; `flutter test test/app_load_state_test.dart`
  - Status: completed
- [x] `lib/src/app_result.dart`
  - Test file: `test/app_result_test.dart`
  - Checks: `dart analyze test/app_result_test.dart`; `flutter test test/app_result_test.dart`
  - Status: completed before tracker creation
- [x] `lib/src/ui_message.dart`
  - Test file: `test/ui_message_test.dart`
  - Checks: `dart format test/ui_message_test.dart`; `dart analyze test/ui_message_test.dart`; `flutter test test/ui_message_test.dart`
  - Status: completed
- [ ] `lib/src/widgets/app_error_indicator.dart`
- [ ] `lib/src/widgets/app_load_content.dart`
- [ ] `lib/src/widgets/app_ui_message_listener.dart`

## Current Step

Next target: `lib/src/widgets/app_error_indicator.dart`
