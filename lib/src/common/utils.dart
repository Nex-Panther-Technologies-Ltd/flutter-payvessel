/// Utility functions for the Payvessel plugin.
class Utils {
  /// Get error message for invalid API key.
  static String getKeyErrorMsg(String keyType) {
    return 'Invalid $keyType key. Please ensure your $keyType key '
        'is valid and starts with the appropriate prefix.';
  }

  /// Format amount with currency.
  static String formatAmount(int amount, {String currency = 'NGN'}) {
    final symbol = _getCurrencySymbol(currency);
    final formattedAmount = (amount / 100).toStringAsFixed(2);
    return '$symbol$formattedAmount';
  }

  /// Get currency symbol from currency code.
  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'GHS':
        return 'GH₵';
      case 'KES':
        return 'KSh';
      case 'ZAR':
        return 'R';
      default:
        return currency;
    }
  }

  /// Validate email format.
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Generate a unique reference.
  static String generateReference() {
    return 'PV_${DateTime.now().millisecondsSinceEpoch}';
  }
}
