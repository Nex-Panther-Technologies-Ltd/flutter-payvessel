/// Flutter SDK for Payvessel Payment Gateway.
///
/// This package provides a simple way to integrate Payvessel checkout
/// into your Flutter application using a WebView.
///
/// ## Getting Started
///
/// 1. Initialize the transaction on your server and get the transaction ID.
/// 2. Use the [Payvessel] class to launch the checkout:
///
/// ```dart
/// import 'package:flutter_payvessel/flutter_payvessel.dart';
///
/// final payvessel = Payvessel(
///   config: PayvesselConfig(
///     publicKey: 'your_public_key',
///   ),
/// );
///
/// final result = await payvessel.checkout(
///   context: context,
///   transactionId: 'transaction_id_from_server',
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
/// - Simple WebView-based checkout
/// - Automatic handling of redirects and callbacks
/// - Support for full-screen and bottom sheet modes
/// - Customizable app bar
///
library flutter_payvessel;

export 'src/payvessel.dart';
export 'src/models/payvessel_config.dart';
export 'src/models/payvessel_result.dart';
export 'src/views/checkout_view.dart';
