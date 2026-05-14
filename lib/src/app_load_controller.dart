import 'package:signals/signals.dart';

import 'app_failure.dart';
import 'app_failure_mapper.dart';
import 'app_load_state.dart';
import 'app_result.dart';

typedef AppLoadTask<T> = Future<AppResult<T>> Function();
typedef AppEmptyPredicate<T> = bool Function(T value);

final class AppLoadController<T> {
  AppLoadController({
    required AppFailureReporter reportFailure,
    AppLoadState<T> initialState = const AppLoadState.initial(),
    AppEmptyPredicate<T>? isEmpty,
  }) : _isEmpty = isEmpty,
       _reportFailure = reportFailure,
       state = signal(initialState);

  final AppEmptyPredicate<T>? _isEmpty;
  final AppFailureReporter _reportFailure;
  final Signal<AppLoadState<T>> state;

  Future<AppResult<T>> run(
    AppLoadTask<T> task, {
    AppEmptyPredicate<T>? isEmpty,
    AppFailureMapper? mapError,
    bool preserveData = false,
  }) async {
    final previousData = preserveData ? state.value.dataOrNull : null;
    state.value = AppLoadState.loading(previousData: previousData);

    late final AppResult<T> result;
    try {
      result = await task();
    } catch (error, stackTrace) {
      result = AppResult.failure(
        mapError?.call(error, stackTrace) ??
            AppFailure.unexpected(error, stackTrace, report: _reportFailure),
      );
    }

    switch (result) {
      case AppSuccess<T>(:final value):
        final emptyPredicate = isEmpty ?? _isEmpty ?? _defaultIsEmpty;
        state.value = emptyPredicate(value)
            ? AppLoadState.empty(data: value)
            : AppLoadState.data(value);
      case AppError<T>(:final failure):
        state.value = AppLoadState.failure(failure, previousData: previousData);
    }
    return result;
  }

  void setData(T data, {AppEmptyPredicate<T>? isEmpty}) {
    final emptyPredicate = isEmpty ?? _isEmpty ?? _defaultIsEmpty;
    state.value = emptyPredicate(data)
        ? AppLoadState.empty(data: data)
        : AppLoadState.data(data);
  }

  void setFailure(AppFailure failure, {bool preserveData = true}) {
    state.value = AppLoadState.failure(
      failure,
      previousData: preserveData ? state.value.dataOrNull : null,
    );
  }

  void reset() {
    state.value = const AppLoadState.initial();
  }

  void dispose() {
    state.dispose();
  }

  bool _defaultIsEmpty(T value) {
    final object = value;
    return object is Iterable && object.isEmpty;
  }
}
