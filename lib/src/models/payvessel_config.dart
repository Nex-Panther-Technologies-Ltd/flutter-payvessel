/// Configuration for Payvessel checkout.
class PayvesselConfig {
  /// Your Payvessel API key (public key).
  final String apiKey;

  /// The base URL for the checkout.
  /// Defaults to Payvessel production checkout URL.
  final String checkoutUrl;

  PayvesselConfig({
    required this.apiKey,
    this.checkoutUrl = 'https://checkout.payvessel.com',
  });

  /// Get the checkout URL for inline checkout.
  String getInlineCheckoutUrl() {
    return '$checkoutUrl/inline';
  }

  /// Get the full checkout URL with transaction ID (for pre-initialized transactions).
  String getCheckoutUrl(String transactionId) {
    return '$checkoutUrl/$transactionId';
  }
}
