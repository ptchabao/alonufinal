abstract class Failure {
  final String message;
  final dynamic originalError;

  Failure({required this.message, this.originalError});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final int? statusCode;

  ServerFailure({
    required String message,
    this.statusCode,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class NetworkFailure extends Failure {
  NetworkFailure({
    String message = 'Network error. Check your connection.',
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class CacheFailure extends Failure {
  CacheFailure({
    String message = 'Cache operation failed.',
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  ValidationFailure({
    required String message,
    this.fieldErrors,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class AuthenticationFailure extends Failure {
  AuthenticationFailure({
    String message = 'Authentication failed.',
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class AuthorizationFailure extends Failure {
  AuthorizationFailure({
    String message = 'You do not have permission.',
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class NotFoundFailure extends Failure {
  NotFoundFailure({
    String message = 'Resource not found.',
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class ConflictFailure extends Failure {
  ConflictFailure({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}
