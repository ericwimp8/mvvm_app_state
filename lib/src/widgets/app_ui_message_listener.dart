import 'package:flutter/material.dart';

import '../ui_message.dart';

typedef AppSnackBarBuilder =
    SnackBar Function(BuildContext context, UiMessage message);

class AppUiMessageListener extends StatefulWidget {
  const AppUiMessageListener({
    required this.message,
    required this.child,
    this.onConsumed,
    this.snackBarBuilder,
    this.clearExisting = true,
    super.key,
  });

  final UiMessage? message;
  final Widget child;
  final VoidCallback? onConsumed;
  final AppSnackBarBuilder? snackBarBuilder;
  final bool clearExisting;

  @override
  State<AppUiMessageListener> createState() => _AppUiMessageListenerState();
}

class _AppUiMessageListenerState extends State<AppUiMessageListener> {
  Object? _lastShownKey;

  @override
  void initState() {
    super.initState();
    _scheduleMessage(widget.message);
  }

  @override
  void didUpdateWidget(covariant AppUiMessageListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleMessage(widget.message);
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _scheduleMessage(UiMessage? message) {
    if (message == null || message.key == _lastShownKey) return;
    _lastShownKey = message.key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      if (widget.clearExisting) {
        messenger.hideCurrentSnackBar();
      }
      messenger.showSnackBar(
        widget.snackBarBuilder?.call(context, message) ??
            _defaultSnackBar(context, message),
      );
      widget.onConsumed?.call();
    });
  }

  SnackBar _defaultSnackBar(BuildContext context, UiMessage message) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, foreground, background) = switch (message.severity) {
      UiMessageSeverity.info => (
        Icons.info_outline,
        colorScheme.onInverseSurface,
        colorScheme.inverseSurface,
      ),
      UiMessageSeverity.success => (
        Icons.check_circle_outline,
        colorScheme.onPrimaryContainer,
        colorScheme.primaryContainer,
      ),
      UiMessageSeverity.warning => (
        Icons.warning_amber_outlined,
        colorScheme.onTertiaryContainer,
        colorScheme.tertiaryContainer,
      ),
      UiMessageSeverity.error => (
        Icons.error_outline,
        colorScheme.onErrorContainer,
        colorScheme.errorContainer,
      ),
    };

    return SnackBar(
      duration: message.duration ?? const Duration(seconds: 4),
      backgroundColor: background,
      content: Row(
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.message,
              style: TextStyle(color: foreground),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
