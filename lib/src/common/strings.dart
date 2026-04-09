/// String constants used throughout the plugin.
class Strings {
  static const String userTerminated = 'Transaction terminated by user';
  static const String noTransactionIdOrReference =
      'Please provide either a transactionId or reference for the transaction';
  static const String invalidPublicKey =
      'Invalid public key. Please ensure your public key starts with "pv_"';
  static const String paymentSuccessful = 'Payment successful';
  static const String paymentFailed = 'Payment failed';
  static const String paymentPending = 'Payment pending';
  static const String transactionVerificationFailed =
      'Transaction verification failed';
  static const String networkError =
      'Network error. Please check your internet connection and try again';
  static const String unknownError = 'An unknown error occurred';
  static const String checkoutCancelled = 'Checkout was cancelled';
}
