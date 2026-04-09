/// Flutter SDK for Payvessel Payment Gateway.
///
/// This package provides a simple way to integrate Payvessel checkout
/// into your Flutter application. Works similar to the npm package
/// `payvessel-checkout`.
///
/// ## Getting Started
///
/// Use the [Payvessel] class to initialize and launch the checkout:
///
/// ```dart
/// import 'package:flutter_payvessel/flutter_payvessel.dart';
///
/// final payvessel = Payvessel(
///   config: PayvesselConfig(
///     apiKey: 'YOUR_API_KEY',
///   ),
/// );
///
/// final result = await payvessel.initializeCheckout(
///   context: context,
///   params: CheckoutParams(
///     customerEmail: 'customer@example.com',
///     customerPhoneNumber: '08012345678',
///     amount: '1000',
///     currency: 'NGN',
///     customerName: 'John Doe',
///     channels: [PaymentChannels.bankTransfer, PaymentChannels.card],
///   ),
/// );
///
/// if (result.isSuccessful) {
///   print('Payment successful!');
///   print('Reference: ${result.reference}');
/// } else if (result.isCancelled) {
///   print('Payment cancelled');
/// } else {
///   print('Payment failed: ${result.message}');
/// }
/// ```
///
/// ## Features
///
/// - Simple, promise-based API (similar to npm package)
/// - Initialize checkout directly with customer details
/// - Support for full-screen and bottom sheet modes
/// - Automatic handling of callbacks (onSuccess, onError, onClose)
/// - Bank Transfer and Card payment channels
///
library flutter_payvessel;

export 'src/payvessel.dart';
export 'src/models/payvessel_config.dart';
export 'src/models/payvessel_result.dart';
export 'src/models/checkout_params.dart';
export 'src/views/checkout_view.dart';
