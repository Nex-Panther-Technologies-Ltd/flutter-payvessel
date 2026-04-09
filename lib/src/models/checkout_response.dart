import 'package:flutter_payvessel/src/common/strings.dart';

/// The payment method used for the transaction.
enum PaymentMethod {
  /// Bank transfer payment.
  bankTransfer,

  /// Card payment.
  card,

  /// USSD payment.
  ussd,

  /// Unknown or not specified.
  unknown,
}

/// The status of a checkout response.
enum CheckoutStatus {
  /// Payment was successful.
  success,

  /// Payment failed.
  failed,

  /// Payment is pending.
  pending,

  /// Payment was cancelled by user.
  cancelled,

  /// Unknown status.
  unknown,
}

/// The response returned after a checkout attempt.
class CheckoutResponse {
  /// A user-readable message about the transaction status.
  final String message;

  /// The transaction reference.
  final String? reference;

  /// The transaction ID.
  final String? transactionId;

  /// Whether the payment was successful.
  final bool status;

  /// The payment method used.
  final PaymentMethod method;

  /// Whether the transaction should be verified on the server.
  final bool verify;

  /// The checkout status.
  final CheckoutStatus checkoutStatus;

  /// The amount paid (in smallest currency unit).
  final int? amount;

  /// The currency code.
  final String? currency;

  /// Customer email.
  final String? email;

  /// Customer name.
  final String? name;

  /// Additional data from the transaction.
  final Map<String, dynamic>? data;

  CheckoutResponse({
    required this.message,
    this.reference,
    this.transactionId,
    required this.status,
    required this.method,
    required this.verify,
    this.checkoutStatus = CheckoutStatus.unknown,
    this.amount,
    this.currency,
    this.email,
    this.name,
    this.data,
  });

  /// Create a default response for cancelled/terminated transactions.
  factory CheckoutResponse.defaults() {
    return CheckoutResponse(
      message: Strings.userTerminated,
      status: false,
      verify: false,
      method: PaymentMethod.unknown,
      checkoutStatus: CheckoutStatus.cancelled,
    );
  }

  /// Create a success response.
  factory CheckoutResponse.success({
    String? reference,
    String? transactionId,
    PaymentMethod method = PaymentMethod.unknown,
    int? amount,
    String? currency,
    String? email,
    String? name,
    Map<String, dynamic>? data,
  }) {
    return CheckoutResponse(
      message: Strings.paymentSuccessful,
      reference: reference,
      transactionId: transactionId,
      status: true,
      method: method,
      verify: true,
      checkoutStatus: CheckoutStatus.success,
      amount: amount,
      currency: currency,
      email: email,
      name: name,
      data: data,
    );
  }

  /// Create a failed response.
  factory CheckoutResponse.failed({
    required String message,
    String? reference,
    String? transactionId,
    PaymentMethod method = PaymentMethod.unknown,
    Map<String, dynamic>? data,
  }) {
    return CheckoutResponse(
      message: message,
      reference: reference,
      transactionId: transactionId,
      status: false,
      method: method,
      verify: true,
      checkoutStatus: CheckoutStatus.failed,
      data: data,
    );
  }

  /// Create a pending response.
  factory CheckoutResponse.pending({
    String? reference,
    String? transactionId,
    PaymentMethod method = PaymentMethod.unknown,
    int? amount,
    String? currency,
    Map<String, dynamic>? data,
  }) {
    return CheckoutResponse(
      message: Strings.paymentPending,
      reference: reference,
      transactionId: transactionId,
      status: false,
      method: method,
      verify: true,
      checkoutStatus: CheckoutStatus.pending,
      amount: amount,
      currency: currency,
      data: data,
    );
  }

  @override
  String toString() {
    return 'CheckoutResponse{message: $message, reference: $reference, '
        'transactionId: $transactionId, status: $status, method: $method, '
        'checkoutStatus: $checkoutStatus, verify: $verify}';
  }
}
