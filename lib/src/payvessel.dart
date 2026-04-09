import 'package:flutter/material.dart';
import 'models/payvessel_config.dart';
import 'models/payvessel_result.dart';
import 'views/checkout_view.dart';

/// Main class for Payvessel Flutter SDK.
///
/// Use this class to launch the Payvessel checkout and process payments.
///
/// Example:
/// ```dart
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
///   print('Payment successful: ${result.reference}');
/// }
/// ```
class Payvessel {
  /// The Payvessel configuration.
  final PayvesselConfig config;

  /// Create a new Payvessel instance.
  Payvessel({required this.config});

  /// Launch the checkout and wait for the result.
  ///
  /// [context] - The BuildContext to use for navigation.
  /// [transactionId] - The transaction ID from your server.
  /// [showAppBar] - Whether to show the app bar (default: true).
  /// [appBarTitle] - The title for the app bar.
  ///
  /// Returns a [PayvesselResult] with the transaction status.
  Future<PayvesselResult> checkout({
    required BuildContext context,
    required String transactionId,
    bool showAppBar = true,
    String appBarTitle = 'Checkout',
    bool fullScreen = true,
  }) async {
    PayvesselResult? result;

    if (fullScreen) {
      result = await Navigator.of(context).push<PayvesselResult>(
        MaterialPageRoute(
          builder: (context) => PayvesselCheckoutView(
            transactionId: transactionId,
            config: config,
            showAppBar: showAppBar,
            appBarTitle: appBarTitle,
            onComplete: (r) {
              Navigator.of(context).pop(r);
            },
            onCancelled: () {
              Navigator.of(context).pop(PayvesselResult.cancelled());
            },
          ),
        ),
      );
    } else {
      result = await showModalBottomSheet<PayvesselResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: PayvesselCheckoutView(
              transactionId: transactionId,
              config: config,
              showAppBar: showAppBar,
              appBarTitle: appBarTitle,
              onComplete: (r) {
                Navigator.of(context).pop(r);
              },
              onCancelled: () {
                Navigator.of(context).pop(PayvesselResult.cancelled());
              },
            ),
          ),
        ),
      );
    }

    return result ?? PayvesselResult.cancelled();
  }

  /// Get the checkout widget to embed in your own UI.
  ///
  /// Use this if you want more control over how the checkout is displayed.
  Widget buildCheckoutView({
    required String transactionId,
    void Function(PayvesselResult result)? onComplete,
    VoidCallback? onCancelled,
    bool showAppBar = false,
    String appBarTitle = 'Checkout',
    PreferredSizeWidget? appBar,
  }) {
    return PayvesselCheckoutView(
      transactionId: transactionId,
      config: config,
      showAppBar: showAppBar,
      appBarTitle: appBarTitle,
      appBar: appBar,
      onComplete: onComplete,
      onCancelled: onCancelled,
    );
  }
}
