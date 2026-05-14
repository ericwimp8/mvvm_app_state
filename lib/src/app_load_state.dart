import 'app_failure.dart';

sealed class AppLoadState<T> {
  const AppLoadState();

  const factory AppLoadState.initial() = AppLoadInitial<T>;

  const factory AppLoadState.loading({T? previousData}) = AppLoadLoading<T>;

  const factory AppLoadState.data(T data) = AppLoadData<T>;

  const factory AppLoadState.empty({T? data}) = AppLoadEmpty<T>;

  const factory AppLoadState.failure(AppFailure failure, {T? previousData}) =
      AppLoadFailure<T>;

  bool get isInitial => this is AppLoadInitial<T>;

  bool get isLoading => this is AppLoadLoading<T>;

  bool get hasData => dataOrNull != null;

  bool get isEmpty => this is AppLoadEmpty<T>;

  bool get isFailure => this is AppLoadFailure<T>;

  T? get dataOrNull => switch (this) {
    AppLoadData<T>(:final data) => data,
    AppLoadEmpty<T>(:final data) => data,
    AppLoadLoading<T>(:final previousData) => previousData,
    AppLoadFailure<T>(:final previousData) => previousData,
    AppLoadInitial<T>() => null,
  };

  AppFailure? get failureOrNull => switch (this) {
    AppLoadFailure<T>(:final failure) => failure,
    _ => null,
  };
}

final class AppLoadInitial<T> extends AppLoadState<T> {
  const AppLoadInitial();
}

final class AppLoadLoading<T> extends AppLoadState<T> {
  const AppLoadLoading({this.previousData});

  final T? previousData;
}

final class AppLoadData<T> extends AppLoadState<T> {
  const AppLoadData(this.data);

  final T data;
}

final class AppLoadEmpty<T> extends AppLoadState<T> {
  const AppLoadEmpty({this.data});

  final T? data;
}

final class AppLoadFailure<T> extends AppLoadState<T> {
  const AppLoadFailure(this.failure, {this.previousData});

  final AppFailure failure;
  final T? previousData;
}
