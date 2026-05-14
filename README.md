# mvvm_app_state

Typed app state primitives for Flutter MVVM apps.

This package captures a repeatable state shape for Flutter apps using an MVVM
style architecture. It is intentionally small: repositories and use cases return
typed results, view models expose typed load/action state, and widgets render
loading, empty, failure, and one-shot message states consistently.

## Package Shape

- `AppResult<T>` for success/failure returns from fallible work
- `AppFailure` and `AppFailureKind` for typed, loggable failures
- `AppLoadState<T>` for initial load, loading, data, empty, and failure states
- `AppActionState<T>` for command/action idle, running, success, and failure
  states
- `UiMessage` for one-shot snackbar/toast-style messages
- `AppLoadController<T>` and `AppActionController<T>` for signal-backed view
  model state
- `AppLoadContent`, `AppErrorIndicator`, and `AppUiMessageListener` for
  consistent Flutter presentation

## Usage

```dart
import 'package:mvvm_app_state/mvvm_app_state.dart';

final class AppFailureHandling {
  static AppFailureHandler handler = const NoopAppFailureHandler();
}

final class ResourcesViewModel {
  ResourcesViewModel({required this.repository});

  final ResourceRepository repository;
  final resources = AppLoadController<List<Resource>>(
    failureHandler: AppFailureHandling.handler,
  );
  final save = AppActionController<void>(
    failureHandler: AppFailureHandling.handler,
  );

  Future<void> load() {
    return resources.run(() => repository.fetchResources());
  }

  Future<void> saveResource(Resource resource) {
    return save.run(
      () => repository.save(resource),
      successMessage: (_) => const UiMessage.success('Resource saved.'),
      failureMessage: (failure) => UiMessage.error(failure.message),
    );
  }

  void dispose() {
    resources.dispose();
    save.dispose();
  }
}
```

```dart
AppUiMessageListener(
  message: viewModel.save.message.value,
  onConsumed: viewModel.save.clearMessage,
  child: AppLoadContent<List<Resource>>(
    state: viewModel.resources.state.value,
    onRetry: viewModel.load,
    builder: (context, resources) => ResourceList(resources: resources),
  ),
)
```

## Error Handling Rule

Use load state for screen-critical failures. Use action state and `UiMessage`
for transient save/delete/update outcomes. Keep validation local to forms and
fields. Keep route-level and platform-level error handling outside this package.
Every `AppFailure` constructor and package fallback error path requires an
explicit `AppFailureHandler`. Every `AppFailure` must carry a non-null
`StackTrace`. Apps should pass one central handler object, or
`noopAppFailureHandler` when a failure is intentionally silent.
