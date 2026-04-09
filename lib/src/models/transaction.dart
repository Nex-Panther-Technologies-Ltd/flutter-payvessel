/// The transaction model represents a payment transaction.
class Transaction {
  /// The unique transaction ID.
  final String? id;

  /// The transaction reference.
  final String? reference;

  /// The transaction status.
  final String? status;

  /// The amount in the smallest currency unit.
  final int? amount;

  /// The currency code.
  final String? currency;

  /// Customer email.
  final String? email;

  /// Customer name.
  final String? name;

  /// The payment method used.
  final String? paymentMethod;

  /// When the transaction was created.
  final DateTime? createdAt;

  /// When the transaction was updated.
  final DateTime? updatedAt;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Virtual account details (for bank transfer).
  final VirtualAccount? virtualAccount;

  Transaction({
    this.id,
    this.reference,
    this.status,
    this.amount,
    this.currency,
    this.email,
    this.name,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.virtualAccount,
  });

  /// Create a Transaction from JSON.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString(),
      reference: json['reference']?.toString(),
      status: json['status']?.toString(),
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? ''),
      currency: json['currency']?.toString(),
      email: json['email']?.toString() ?? json['customer_email']?.toString(),
      name: json['name']?.toString() ?? json['customer_name']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      virtualAccount: json['virtual_account'] != null
          ? VirtualAccount.fromJson(
              Map<String, dynamic>.from(json['virtual_account']))
          : null,
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (reference != null) 'reference': reference,
      if (status != null) 'status': status,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
      if (virtualAccount != null) 'virtual_account': virtualAccount!.toJson(),
    };
  }

  /// Check if the transaction is successful.
  bool get isSuccessful => status?.toUpperCase() == 'SUCCESSFUL';

  /// Check if the transaction is pending.
  bool get isPending => status?.toUpperCase() == 'PENDING';

  /// Check if the transaction failed.
  bool get isFailed => status?.toUpperCase() == 'FAILED';

  @override
  String toString() {
    return 'Transaction{id: $id, reference: $reference, status: $status, amount: $amount}';
  }
}

/// Virtual account details for bank transfer payments.
class VirtualAccount {
  /// The bank name.
  final String? bankName;

  /// The account number.
  final String? accountNumber;

  /// The account name.
  final String? accountName;

  /// When the virtual account expires.
  final DateTime? expiresAt;

  VirtualAccount({
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.expiresAt,
  });

  /// Create from JSON.
  factory VirtualAccount.fromJson(Map<String, dynamic> json) {
    return VirtualAccount(
      bankName: json['bank_name']?.toString() ?? json['bank']?.toString(),
      accountNumber: json['account_number']?.toString(),
      accountName: json['account_name']?.toString(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      if (bankName != null) 'bank_name': bankName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (accountName != null) 'account_name': accountName,
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'VirtualAccount{bankName: $bankName, accountNumber: $accountNumber, '
        'accountName: $accountName}';
  }
}
