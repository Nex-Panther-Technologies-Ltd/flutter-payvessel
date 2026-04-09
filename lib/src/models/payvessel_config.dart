/// Configuration for Payvessel checkout.
class PayvesselConfig {
  /// Your Payvessel public key.
  final String publicKey;

  /// The base URL for the checkout.
  /// Defaults to Payvessel production checkout URL.
  final String checkoutUrl;

  /// Whether to use test mode.
  final bool testMode;

  PayvesselConfig({
    required this.publicKey,
    this.checkoutUrl = 'https://checkout.payvessel.com',
    this.testMode = false,
  });

  /// Get the full checkout URL with transaction ID.
  String getCheckoutUrl(String transactionId) {
    return '$checkoutUrl/$transactionId';
  }
}
