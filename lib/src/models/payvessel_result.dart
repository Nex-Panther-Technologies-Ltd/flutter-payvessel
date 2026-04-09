/// The result of a Payvessel checkout transaction.
class PayvesselResult {
  /// The status of the transaction.
  final PayvesselStatus status;

  /// The transaction reference.
  final String? reference;

  /// The transaction ID.
  final String? transactionId;

  /// The payment ID.
  final String? paymentId;

  /// Error message if the transaction failed.
  final String? message;

  /// Raw data from the checkout.
  final Map<String, dynamic>? data;

  PayvesselResult({
    required this.status,
    this.reference,
    this.transactionId,
    this.paymentId,
    this.message,
    this.data,
  });

  /// Whether the transaction was successful.
  bool get isSuccessful => status == PayvesselStatus.success;

  /// Whether the transaction failed.
  bool get isFailed => status == PayvesselStatus.failed;

  /// Whether the transaction was cancelled by the user.
  bool get isCancelled => status == PayvesselStatus.cancelled;

  /// Whether the transaction is pending.
  bool get isPending => status == PayvesselStatus.pending;

  @override
  String toString() {
    return 'PayvesselResult(status: $status, reference: $reference, transactionId: $transactionId, message: $message)';
  }

  /// Create a successful result from redirect URL parameters.
  factory PayvesselResult.fromRedirectParams(Map<String, String> params) {
    return PayvesselResult(
      status: PayvesselStatus.success,
      reference: params['payment_ref'],
      paymentId: params['payment_id'],
      transactionId: params['transaction_id'],
      data: params,
    );
  }

  /// Create a cancelled result.
  factory PayvesselResult.cancelled() {
    return PayvesselResult(
      status: PayvesselStatus.cancelled,
      message: 'Transaction was cancelled by user',
    );
  }

  /// Create a failed result.
  factory PayvesselResult.failed(String message) {
    return PayvesselResult(
      status: PayvesselStatus.failed,
      message: message,
    );
  }

  /// Create a pending result.
  factory PayvesselResult.pending() {
    return PayvesselResult(
      status: PayvesselStatus.pending,
      message: 'Transaction is pending',
    );
  }
}

/// The status of a Payvessel transaction.
enum PayvesselStatus {
  /// The transaction was successful.
  success,

  /// The transaction failed.
  failed,

  /// The transaction was cancelled by the user.
  cancelled,

  /// The transaction is pending.
  pending,
}
