/// Custom exceptions for Payvessel plugin.

/// Base exception class for all Payvessel exceptions.
class PayvesselException implements Exception {
  final String message;

  PayvesselException(this.message);

  @override
  String toString() => 'PayvesselException: $message';
}

/// Thrown when the SDK has not been initialized before use.
class PayvesselSdkNotInitializedException extends PayvesselException {
  PayvesselSdkNotInitializedException(String message) : super(message);

  @override
  String toString() => 'PayvesselSdkNotInitializedException: $message';
}

/// Thrown when authentication fails (invalid API key).
class AuthenticationException extends PayvesselException {
  AuthenticationException(String message) : super(message);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Thrown when the charge object is invalid.
class ChargeException extends PayvesselException {
  ChargeException(String message) : super(message);

  @override
  String toString() => 'ChargeException: $message';
}

/// Thrown when the amount is invalid.
class InvalidAmountException extends PayvesselException {
  final int amount;

  InvalidAmountException(this.amount)
      : super('Invalid amount: $amount. Amount must be a positive integer.');

  @override
  String toString() => 'InvalidAmountException: Invalid amount $amount';
}

/// Thrown when the email is invalid.
class InvalidEmailException extends PayvesselException {
  final String? email;

  InvalidEmailException(this.email) : super('Invalid email: $email');

  @override
  String toString() => 'InvalidEmailException: Invalid email $email';
}

/// Thrown when a transaction fails.
class TransactionException extends PayvesselException {
  TransactionException(String message) : super(message);

  @override
  String toString() => 'TransactionException: $message';
}

/// Thrown when a payment is cancelled by the user.
class PaymentCancelledException extends PayvesselException {
  PaymentCancelledException() : super('Payment was cancelled by the user');

  @override
  String toString() => 'PaymentCancelledException: Payment was cancelled';
}
