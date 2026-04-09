/// Checkout parameters for initializing a Payvessel payment.
class CheckoutParams {
  /// Customer's email address (required).
  final String customerEmail;

  /// Customer's phone number (required).
  final String customerPhoneNumber;

  /// Amount to charge as a string (required).
  final String amount;

  /// Currency code, e.g., "NGN" (required).
  final String currency;

  /// Customer's full name (required).
  final String customerName;

  /// Payment channels to enable. Defaults to ["BANK_TRANSFER"].
  final List<String>? channels;

  /// Additional metadata to attach to the transaction.
  final Map<String, dynamic>? metadata;

  /// Optional unique reference for the transaction.
  final String? reference;

  /// URL to redirect to after payment confirmation.
  final String? redirectUrl;

  CheckoutParams({
    required this.customerEmail,
    required this.customerPhoneNumber,
    required this.amount,
    required this.currency,
    required this.customerName,
    this.channels,
    this.metadata,
    this.reference,
    this.redirectUrl,
  });

  /// Convert to URL query parameters for the checkout page.
  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'customer_email': customerEmail,
      'customer_phone_number': customerPhoneNumber,
      'amount': amount,
      'currency': currency,
      'customer_name': customerName,
    };

    if (channels != null && channels!.isNotEmpty) {
      params['channels'] = channels!.join(',');
    }

    if (reference != null) {
      params['reference'] = reference!;
    }

    if (redirectUrl != null) {
      params['redirect_url'] = redirectUrl!;
    }

    return params;
  }

  /// Convert metadata to JSON string for passing to checkout.
  String? get metadataJson {
    if (metadata == null) return null;
    // Simple JSON encoding without importing dart:convert
    final entries = metadata!.entries.map((e) {
      final value = e.value is String ? '"${e.value}"' : '${e.value}';
      return '"${e.key}":$value';
    });
    return '{${entries.join(',')}}';
  }
}

/// Payment channels supported by Payvessel.
class PaymentChannels {
  static const String bankTransfer = 'BANK_TRANSFER';
  static const String card = 'CARD';

  /// All available payment channels.
  static const List<String> all = [bankTransfer, card];
}
