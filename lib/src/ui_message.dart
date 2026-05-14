import 'package:flutter/foundation.dart';

import 'app_failure.dart';

enum UiMessageSeverity { info, success, warning, error }

@immutable
final class UiMessage {
  const UiMessage({
    required this.message,
    this.severity = UiMessageSeverity.info,
    this.id,
    this.title,
    this.failure,
    this.duration,
  });

  const UiMessage.info(
    String message, {
    String? id,
    String? title,
    Duration? duration,
  }) : this(message: message, id: id, title: title, duration: duration);

  const UiMessage.success(
    String message, {
    String? id,
    String? title,
    Duration? duration,
  }) : this(
         message: message,
         id: id,
         title: title,
         severity: UiMessageSeverity.success,
         duration: duration,
       );

  const UiMessage.warning(
    String message, {
    String? id,
    String? title,
    Duration? duration,
  }) : this(
         message: message,
         id: id,
         title: title,
         severity: UiMessageSeverity.warning,
         duration: duration,
       );

  const UiMessage.error(
    String message, {
    String? id,
    String? title,
    AppFailure? failure,
    Duration? duration,
  }) : this(
         message: message,
         id: id,
         title: title,
         severity: UiMessageSeverity.error,
         failure: failure,
         duration: duration,
       );

  final String message;
  final UiMessageSeverity severity;
  final String? id;
  final String? title;
  final AppFailure? failure;
  final Duration? duration;

  Object get key => id ?? '$severity:$message:${title ?? ''}';
}
