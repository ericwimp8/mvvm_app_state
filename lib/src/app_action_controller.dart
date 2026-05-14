import 'package:signals/signals.dart';

import 'app_action_state.dart';
import 'app_failure.dart';
import 'app_failure_kind.dart';
import 'app_failure_mapper.dart';
import 'app_result.dart';
import 'ui_message.dart';

typedef AppActionTask<T> = Future<AppResult<T>> Function();
typedef AppSuccessMessageBuilder<T> = UiMessage? Function(T value);
typedef AppFailureMessageBuilder = UiMessage? Function(AppFailure failure);

final class AppActionController<T> {
  AppActionController({
    required AppFailureHandler failureHandler,
    AppActionState<T> initialState = const AppActionState.idle(),
  }) : state = signal(initialState),
       _failureHandler = failureHandler,
       message = signal(null);

  final AppFailureHandler _failureHandler;
  final Signal<AppActionState<T>> state;
  final Signal<UiMessage?> message;

  bool get isRunning => state.value.isRunning;

  Future<AppResult<T>> run(
    AppActionTask<T> task, {
    AppSuccessMessageBuilder<T>? successMessage,
    AppFailureMessageBuilder? failureMessage,
    AppFailureMapper? mapError,
  }) async {
    if (isRunning) {
      return AppResult.failure(
        AppFailure(
          kind: AppFailureKind.conflict,
          message: 'Action is already running.',
          stackTrace: StackTrace.current,
          handler: _failureHandler,
        ),
      );
    }

    state.value = const AppActionState.running();
    message.value = null;

    late final AppResult<T> result;
    try {
      result = await task();
    } catch (error, stackTrace) {
      result = AppResult.failure(
        mapError?.call(error, stackTrace) ??
            AppFailure.unexpected(error, stackTrace, handler: _failureHandler),
      );
    }

    switch (result) {
      case AppSuccess<T>(:final value):
        state.value = AppActionState.success(value);
        message.value = successMessage?.call(value);
      case AppError<T>(:final failure):
        state.value = AppActionState.failure(failure);
        message.value =
            failureMessage?.call(failure) ??
            UiMessage.error(failure.message, failure: failure);
    }
    return result;
  }

  void clearResult() {
    state.value = const AppActionState.idle();
  }

  void clearMessage() {
    message.value = null;
  }

  void reset() {
    state.value = const AppActionState.idle();
    message.value = null;
  }

  void dispose() {
    state.dispose();
    message.dispose();
  }
}
