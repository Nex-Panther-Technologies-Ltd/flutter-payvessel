import 'package:flutter/material.dart';
import 'models/payvessel_config.dart';
import 'models/payvessel_result.dart';
import 'models/checkout_params.dart';
import 'views/checkout_view.dart';

/// Main class for Payvessel Flutter SDK.
///
/// Use this class to launch the Payvessel checkout and process payments.
/// Works similar to the npm package `payvessel-checkout`.
///
/// Example:
/// ```dart
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
///     metadata: {'order_id': '12345'},
///   ),
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
  ///
  /// [config] must include your API key.
  Payvessel({required this.config});

  /// Initialize and launch the checkout.
  ///
  /// This method works similar to `initializeCheckout` in the npm package.
  ///
  /// [context] - The BuildContext to use for navigation.
  /// [params] - The checkout parameters including customer details and amount.
  /// [showAppBar] - Whether to show the app bar (default: true).
  /// [appBarTitle] - The title for the app bar.
  /// [fullScreen] - Whether to show as full screen or bottom sheet.
  /// [onError] - Callback when an error occurs.
  ///
  /// Returns a [PayvesselResult] with the transaction status.
  Future<PayvesselResult> initializeCheckout({
    required BuildContext context,
    required CheckoutParams params,
    bool showAppBar = true,
    String appBarTitle = 'Checkout',
    bool fullScreen = true,
    void Function(String error)? onError,
  }) async {
    PayvesselResult? result;

    if (fullScreen) {
      result = await Navigator.of(context).push<PayvesselResult>(
        MaterialPageRoute(
          builder: (ctx) => PayvesselCheckoutView(
            checkoutParams: params,
            config: config,
            showAppBar: showAppBar,
            appBarTitle: appBarTitle,
            onComplete: (r) {
              Navigator.of(ctx).pop(r);
            },
            onError: onError,
            onCancelled: () {
              Navigator.of(ctx).pop(PayvesselResult.cancelled());
            },
          ),
        ),
      );
    } else {
      result = await showModalBottomSheet<PayvesselResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: PayvesselCheckoutView(
              checkoutParams: params,
              config: config,
              showAppBar: showAppBar,
              appBarTitle: appBarTitle,
              onComplete: (r) {
                Navigator.of(ctx).pop(r);
              },
              onError: onError,
              onCancelled: () {
                Navigator.of(ctx).pop(PayvesselResult.cancelled());
              },
            ),
          ),
        ),
      );
    }

    return result ?? PayvesselResult.cancelled();
  }

  /// Launch checkout with a pre-initialized transaction ID.
  ///
  /// Use this if you've already initialized the transaction on your server.
  ///
  /// [context] - The BuildContext to use for navigation.
  /// [transactionId] - The transaction ID from your server.
  /// [showAppBar] - Whether to show the app bar (default: true).
  /// [appBarTitle] - The title for the app bar.
  /// [fullScreen] - Whether to show as full screen or bottom sheet.
  ///
  /// Returns a [PayvesselResult] with the transaction status.
  Future<PayvesselResult> checkout({
    required BuildContext context,
    required String transactionId,
    bool showAppBar = true,
    String appBarTitle = 'Checkout',
    bool fullScreen = true,
    void Function(String error)? onError,
  }) async {
    PayvesselResult? result;

    if (fullScreen) {
      result = await Navigator.of(context).push<PayvesselResult>(
        MaterialPageRoute(
          builder: (ctx) => PayvesselCheckoutView(
            transactionId: transactionId,
            config: config,
            showAppBar: showAppBar,
            appBarTitle: appBarTitle,
            onComplete: (r) {
              Navigator.of(ctx).pop(r);
            },
            onError: onError,
            onCancelled: () {
              Navigator.of(ctx).pop(PayvesselResult.cancelled());
            },
          ),
        ),
      );
    } else {
      result = await showModalBottomSheet<PayvesselResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
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
                Navigator.of(ctx).pop(r);
              },
              onError: onError,
              onCancelled: () {
                Navigator.of(ctx).pop(PayvesselResult.cancelled());
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
    String? transactionId,
    CheckoutParams? checkoutParams,
    void Function(PayvesselResult result)? onComplete,
    void Function(String error)? onError,
    VoidCallback? onCancelled,
    bool showAppBar = false,
    String appBarTitle = 'Checkout',
    PreferredSizeWidget? appBar,
  }) {
    return PayvesselCheckoutView(
      transactionId: transactionId,
      checkoutParams: checkoutParams,
      config: config,
      showAppBar: showAppBar,
      appBarTitle: appBarTitle,
      appBar: appBar,
      onComplete: onComplete,
      onError: onError,
      onCancelled: onCancelled,
    );
  }
}
