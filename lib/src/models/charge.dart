/// The Charge class holds the payment information.
///
/// You must provide either a [transactionId] or [reference] for the checkout.
class Charge {
  /// The amount to charge in the smallest currency unit (e.g., kobo for NGN).
  int? amount;

  /// The currency code (e.g., 'NGN', 'USD').
  String currency;

  /// The customer's email address.
  String? email;

  /// The customer's name.
  String? name;

  /// The customer's phone number.
  String? phone;

  /// The transaction ID returned from initializing a transaction on the server.
  String? transactionId;

  /// The transaction reference.
  String? reference;

  /// The access code returned from initializing a transaction on the server.
  String? accessCode;

  /// Additional metadata to attach to the transaction.
  Map<String, dynamic>? metadata;

  /// Custom fields to add to the transaction.
  final Map<String, dynamic> _customFields = {};

  Charge({
    this.amount,
    this.currency = 'NGN',
    this.email,
    this.name,
    this.phone,
    this.transactionId,
    this.reference,
    this.accessCode,
    this.metadata,
  });

  /// Add a custom field to the charge.
  void putCustomField(String key, dynamic value) {
    _customFields[key] = value;
  }

  /// Get all custom fields.
  Map<String, dynamic> get customFields => Map.unmodifiable(_customFields);

  /// Convert the charge to a JSON map for API requests.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (amount != null) json['amount'] = amount;
    json['currency'] = currency;
    if (email != null) json['email'] = email;
    if (name != null) json['name'] = name;
    if (phone != null) json['phone'] = phone;
    if (transactionId != null) json['transaction_id'] = transactionId;
    if (reference != null) json['reference'] = reference;
    if (accessCode != null) json['access_code'] = accessCode;

    if (metadata != null || _customFields.isNotEmpty) {
      json['metadata'] = {
        ...?metadata,
        ..._customFields,
      };
    }

    return json;
  }

  @override
  String toString() {
    return 'Charge{amount: $amount, currency: $currency, email: $email, '
        'transactionId: $transactionId, reference: $reference}';
  }
}
