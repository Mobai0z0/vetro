import 'package:flutter/foundation.dart';

enum ErrorSeverity { info, warning, error, critical }

class AppError {
  const AppError({
    required this.message,
    this.title,
    this.severity = ErrorSeverity.error,
    this.source,
    this.stackTrace,
    this.userMessage,
    this.suggestion,
  });

  final String message;
  final String? title;
  final ErrorSeverity severity;
  final String? source;
  final StackTrace? stackTrace;
  final String? userMessage;
  final String? suggestion;

  @override
  String toString() => 'AppError($severity: $message)';
}

class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();
  ErrorHandler._();

  final List<AppError> _errors = [];
  final List<Function(AppError)> _listeners = [];

  List<AppError> get errors => List.unmodifiable(_errors);

  void addListener(Function(AppError) listener) => _listeners.add(listener);
  void removeListener(Function(AppError) listener) => _listeners.remove(listener);

  void handle(dynamic error, {
    String? source,
    StackTrace? stackTrace,
    ErrorSeverity severity = ErrorSeverity.error,
  }) {
    final appError = AppError(
      message: error.toString(),
      severity: severity,
      source: source,
      stackTrace: stackTrace ?? StackTrace.current,
      userMessage: _getUserMessage(error),
      suggestion: _getSuggestion(error),
    );

    _errors.add(appError);
    if (_errors.length > 100) _errors.removeAt(0);

    for (final listener in _listeners) {
      try {
        listener(appError);
      } catch (_) {}
    }

    if (severity == ErrorSeverity.critical) {
      debugPrint('CRITICAL ERROR: ${appError.message}');
    } else {
      debugPrint('Error: ${appError.message}');
    }
  }

  String _getUserMessage(dynamic error) {
    if (error is Exception) {
      return _describeException(error);
    }
    return 'An unexpected error occurred.';
  }

  String _describeException(Exception e) {
    final type = e.runtimeType.toString();
    if (type.contains('FileSystemException')) {
      return 'File or folder not found.';
    }
    if (type.contains('PermissionDenied')) {
      return 'Permission denied. Please grant access in settings.';
    }
    if (type.contains('SocketException')) {
      return 'Network error. Please check your connection.';
    }
    return 'An error occurred: ${e.toString()}';
  }

  String? _getSuggestion(dynamic error) {
    if (error.toString().contains('Permission denied') ||
        error.toString().contains('Access denied')) {
      return 'Try opening app settings to grant file access permissions.';
    }
    if (error.toString().contains('No such file')) {
      return 'The file or folder may have been moved or deleted.';
    }
    if (error.toString().contains('disk') || error.toString().contains('space')) {
      return 'Check available disk space.';
    }
    return null;
  }

  void clear() => _errors.clear();
}
