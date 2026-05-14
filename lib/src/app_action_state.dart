import 'app_failure.dart';

sealed class AppActionState<T> {
  const AppActionState();

  const factory AppActionState.idle() = AppActionIdle<T>;

  const factory AppActionState.running() = AppActionRunning<T>;

  const factory AppActionState.success(T value) = AppActionSuccess<T>;

  const factory AppActionState.failure(AppFailure failure) =
      AppActionFailure<T>;

  bool get isIdle => this is AppActionIdle<T>;

  bool get isRunning => this is AppActionRunning<T>;

  bool get isSuccess => this is AppActionSuccess<T>;

  bool get isFailure => this is AppActionFailure<T>;

  T? get valueOrNull => switch (this) {
    AppActionSuccess<T>(:final value) => value,
    _ => null,
  };

  AppFailure? get failureOrNull => switch (this) {
    AppActionFailure<T>(:final failure) => failure,
    _ => null,
  };
}

final class AppActionIdle<T> extends AppActionState<T> {
  const AppActionIdle();
}

final class AppActionRunning<T> extends AppActionState<T> {
  const AppActionRunning();
}

final class AppActionSuccess<T> extends AppActionState<T> {
  const AppActionSuccess(this.value);

  final T value;
}

final class AppActionFailure<T> extends AppActionState<T> {
  const AppActionFailure(this.failure);

  final AppFailure failure;
}
