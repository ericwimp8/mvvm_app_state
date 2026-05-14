import 'package:flutter/material.dart';

import '../app_failure.dart';
import '../app_load_state.dart';
import 'app_error_indicator.dart';

typedef AppDataWidgetBuilder<T> = Widget Function(BuildContext context, T data);
typedef AppFailureWidgetBuilder =
    Widget Function(
      BuildContext context,
      AppFailure failure,
      VoidCallback? retry,
    );

class AppLoadContent<T> extends StatelessWidget {
  const AppLoadContent({
    required this.state,
    required this.builder,
    this.onRetry,
    this.initialBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.showPreviousDataWhileLoading = false,
    this.showPreviousDataOnFailure = false,
    super.key,
  });

  final AppLoadState<T> state;
  final AppDataWidgetBuilder<T> builder;
  final VoidCallback? onRetry;
  final WidgetBuilder? initialBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final AppFailureWidgetBuilder? errorBuilder;
  final bool showPreviousDataWhileLoading;
  final bool showPreviousDataOnFailure;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AppLoadInitial<T>() =>
        initialBuilder?.call(context) ??
            loadingBuilder?.call(context) ??
            const Center(child: CircularProgressIndicator()),
      AppLoadLoading<T>(:final previousData) =>
        showPreviousDataWhileLoading && previousData != null
            ? builder(context, previousData)
            : loadingBuilder?.call(context) ??
                  const Center(child: CircularProgressIndicator()),
      AppLoadData<T>(:final data) => builder(context, data),
      AppLoadEmpty<T>() =>
        emptyBuilder?.call(context) ?? const Center(child: Text('No results.')),
      AppLoadFailure<T>(:final failure, :final previousData) =>
        showPreviousDataOnFailure && previousData != null
            ? builder(context, previousData)
            : errorBuilder?.call(context, failure, onRetry) ??
                  AppErrorIndicator(title: failure.message, onAction: onRetry),
    };
  }
}
