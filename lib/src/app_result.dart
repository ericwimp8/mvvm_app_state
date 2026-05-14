import 'app_failure.dart';

sealed class AppResult<T> {
  const AppResult();

  const factory AppResult.success(T value) = AppSuccess<T>;

  const factory AppResult.failure(AppFailure failure) = AppError<T>;

  static Future<AppResult<T>> guard<T>(
    Future<T> Function() action, {
    required AppFailureHandler failureHandler,
    AppFailure Function(Object error, StackTrace stackTrace)? mapError,
  }) async {
    try {
      return AppResult.success(await action());
    } catch (error, stackTrace) {
      return AppResult.failure(
        mapError?.call(error, stackTrace) ??
            AppFailure.unexpected(error, stackTrace, handler: failureHandler),
      );
    }
  }

  bool get isSuccess => this is AppSuccess<T>;

  bool get isFailure => this is AppError<T>;

  T? get valueOrNull => switch (this) {
    AppSuccess<T>(:final value) => value,
    AppError<T>() => null,
  };

  AppFailure? get failureOrNull => switch (this) {
    AppSuccess<T>() => null,
    AppError<T>(:final failure) => failure,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    return switch (this) {
      AppSuccess<T>(:final value) => onSuccess(value),
      AppError<T>(:final failure) => onFailure(failure),
    };
  }

  AppResult<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      AppSuccess<T>(:final value) => AppResult.success(transform(value)),
      AppError<T>(:final failure) => AppResult.failure(failure),
    };
  }

  AppResult<R> flatMap<R>(AppResult<R> Function(T value) transform) {
    return switch (this) {
      AppSuccess<T>(:final value) => transform(value),
      AppError<T>(:final failure) => AppResult.failure(failure),
    };
  }
}

final class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.value);

  final T value;

  @override
  String toString() => 'AppResult<$T>.success($value)';
}

final class AppError<T> extends AppResult<T> {
  const AppError(this.failure);

  final AppFailure failure;

  @override
  String toString() => 'AppResult<$T>.failure($failure)';
}
