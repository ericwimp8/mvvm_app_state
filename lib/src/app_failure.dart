import 'package:flutter/foundation.dart';

import 'app_failure_kind.dart';

typedef AppFailureReporter = void Function(AppFailure failure);

void noopAppFailureReporter(AppFailure _) {}

@immutable
final class AppFailure implements Exception {
  AppFailure({
    required this.kind,
    required this.message,
    required AppFailureReporter report,
    this.code,
    this.cause,
    this.stackTrace,
    this.data = const {},
  }) {
    report(this);
  }

  factory AppFailure.unexpected(
    Object cause,
    StackTrace stackTrace, {
    String message = 'Something went wrong.',
    required AppFailureReporter report,
    String? code,
    Map<String, Object?> data = const {},
  }) {
    return AppFailure(
      kind: AppFailureKind.unknown,
      message: message,
      report: report,
      code: code,
      cause: cause,
      stackTrace: stackTrace,
      data: data,
    );
  }

  factory AppFailure.notFound({
    String message = 'Item not found.',
    required AppFailureReporter report,
    String? code,
    Object? cause,
    StackTrace? stackTrace,
    Map<String, Object?> data = const {},
  }) {
    return AppFailure(
      kind: AppFailureKind.notFound,
      message: message,
      report: report,
      code: code,
      cause: cause,
      stackTrace: stackTrace,
      data: data,
    );
  }

  factory AppFailure.validation({
    required String message,
    required AppFailureReporter report,
    String? code,
    Map<String, Object?> data = const {},
  }) {
    return AppFailure(
      kind: AppFailureKind.validation,
      message: message,
      report: report,
      code: code,
      data: data,
    );
  }

  final AppFailureKind kind;
  final String message;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;
  final Map<String, Object?> data;

  bool get isNotFound => kind == AppFailureKind.notFound;

  bool get isValidation => kind == AppFailureKind.validation;

  AppFailure copyWith({
    required AppFailureReporter report,
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
      report: report,
      code: code ?? this.code,
      cause: cause ?? this.cause,
      stackTrace: stackTrace ?? this.stackTrace,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    final suffix = code == null ? '' : ' ($code)';
    return 'AppFailure.${kind.name}: $message$suffix';
  }
}
