import 'package:flutter/foundation.dart';

import 'app_failure_kind.dart';

abstract interface class AppFailureHandler {
  void handle(AppFailure failure);
}

final class NoopAppFailureHandler implements AppFailureHandler {
  const NoopAppFailureHandler();

  @override
  void handle(AppFailure failure) {}
}

const AppFailureHandler noopAppFailureHandler = NoopAppFailureHandler();

@immutable
final class AppFailure implements Exception {
  AppFailure({
    required this.kind,
    required this.message,
    required this.stackTrace,
    required AppFailureHandler handler,
    this.code,
    this.cause,
    this.data = const {},
  }) {
    handler.handle(this);
  }

  factory AppFailure.unexpected(
    Object cause,
    StackTrace stackTrace, {
    String message = 'Something went wrong.',
    required AppFailureHandler handler,
    String? code,
    Map<String, Object?> data = const {},
  }) {
    return AppFailure(
      kind: AppFailureKind.unknown,
      message: message,
      stackTrace: stackTrace,
      handler: handler,
      code: code,
      cause: cause,
      data: data,
    );
  }

  factory AppFailure.notFound({
    required StackTrace stackTrace,
    required AppFailureHandler handler,
    String message = 'Item not found.',
    String? code,
    Object? cause,
    Map<String, Object?> data = const {},
  }) {
    return AppFailure(
      kind: AppFailureKind.notFound,
      message: message,
      stackTrace: stackTrace,
      handler: handler,
      code: code,
      cause: cause,
      data: data,
    );
  }

  factory AppFailure.validation({
    required String message,
    required StackTrace stackTrace,
    required AppFailureHandler handler,
    String? code,
    Map<String, Object?> data = const {},
  }) {
    return AppFailure(
      kind: AppFailureKind.validation,
      message: message,
      stackTrace: stackTrace,
      handler: handler,
      code: code,
      data: data,
    );
  }

  final AppFailureKind kind;
  final String message;
  final String? code;
  final Object? cause;
  final StackTrace stackTrace;
  final Map<String, Object?> data;

  bool get isNotFound => kind == AppFailureKind.notFound;

  bool get isValidation => kind == AppFailureKind.validation;

  AppFailure copyWith({
    required AppFailureHandler handler,
    AppFailureKind? kind,
    String? message,
    String? code,
    Object? cause,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    return AppFailure(
      kind: kind ?? this.kind,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      handler: handler,
      code: code ?? this.code,
      cause: cause ?? this.cause,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    final suffix = code == null ? '' : ' ($code)';
    return 'AppFailure.${kind.name}: $message$suffix';
  }
}
