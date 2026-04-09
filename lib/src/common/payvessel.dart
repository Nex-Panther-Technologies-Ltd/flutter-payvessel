import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_payvessel/src/common/exceptions.dart';
import 'package:flutter_payvessel/src/common/strings.dart';
import 'package:flutter_payvessel/src/common/utils.dart';
import 'package:flutter_payvessel/src/models/charge.dart';
import 'package:flutter_payvessel/src/models/checkout_response.dart';
import 'package:flutter_payvessel/src/widgets/checkout_widget.dart';

/// The main Payvessel plugin class.
///
/// Initialize this class with your public key before making any payments.
///
/// ```dart
/// final plugin = PayvesselPlugin();
/// await plugin.initialize(publicKey: 'your_public_key');
/// ```
class PayvesselPlugin {
  bool _sdkInitialized = false;
  String _publicKey = "";
  String _baseUrl = "https://checkout.payvessel.com";

  /// Initialize the Payvessel object. It should be called as early as possible
  /// (preferably in initState() of the Widget).
  ///
  /// [publicKey] - your Payvessel public key. This is mandatory.
  /// [baseUrl] - optional custom checkout URL (for testing purposes).
  Future<void> initialize({
    required String publicKey,
    String? baseUrl,
  }) async {
    assert(() {
      if (publicKey.isEmpty) {
        throw PayvesselException('publicKey cannot be null or empty');
      }
      return true;
    }());

    if (_sdkInitialized) return;

    _publicKey = publicKey;
    if (baseUrl != null && baseUrl.isNotEmpty) {
      _baseUrl = baseUrl;
    }
    _sdkInitialized = true;
  }

  /// Dispose the plugin and reset the state.
  void dispose() {
    _publicKey = "";
    _sdkInitialized = false;
  }

  /// Check if the SDK has been initialized.
  bool get sdkInitialized => _sdkInitialized;

  /// Get the public key.
  String get publicKey {
    _validateSdkInitialized();
    return _publicKey;
  }

  /// Get the base checkout URL.
  String get baseUrl => _baseUrl;

  void _validateSdkInitialized() {
    if (!_sdkInitialized) {
      throw PayvesselSdkNotInitializedException(
        'Payvessel SDK has not been initialized. The SDK has '
        'to be initialized before use',
      );
    }
  }

  void _performChecks() {
    _validateSdkInitialized();
    if (_publicKey.isEmpty || !_publicKey.startsWith("pv_")) {
      throw AuthenticationException(Utils.getKeyErrorMsg('public'));
    }
  }

  /// Make payment using Payvessel's checkout form via WebView.
  ///
  /// The plugin will handle all the processes involved in making a payment.
  /// Transaction initialization should be done from your backend.
  ///
  /// [context] - the widget's BuildContext
  /// [charge] - the charge object containing payment details
  /// [fullscreen] - whether to display the checkout in fullscreen mode
  /// [logo] - optional custom logo widget
  /// [hideEmail] - whether to hide the email in the checkout
  /// [hideAmount] - whether to hide the amount in the checkout
  ///
  /// Returns a [CheckoutResponse] with the transaction status and details.
  Future<CheckoutResponse> checkout(
    BuildContext context, {
    required Charge charge,
    bool fullscreen = false,
    Widget? logo,
    bool hideEmail = false,
    bool hideAmount = false,
  }) async {
    _performChecks();
    _validateCharge(charge);

    final checkoutUrl = _buildCheckoutUrl(charge);

    CheckoutResponse? response = await showDialog<CheckoutResponse>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => CheckoutWidget(
        checkoutUrl: checkoutUrl,
        charge: charge,
        publicKey: _publicKey,
        fullscreen: fullscreen,
        logo: logo,
        hideAmount: hideAmount,
        hideEmail: hideEmail,
      ),
    );

    return response ?? CheckoutResponse.defaults();
  }

  /// Build the checkout URL with the transaction reference or access code.
  String _buildCheckoutUrl(Charge charge) {
    if (charge.transactionId != null && charge.transactionId!.isNotEmpty) {
      return '$_baseUrl/${charge.transactionId}';
    } else if (charge.reference != null && charge.reference!.isNotEmpty) {
      return '$_baseUrl/ref/${charge.reference}';
    }
    throw ChargeException(Strings.noTransactionIdOrReference);
  }

  void _validateCharge(Charge charge) {
    if (charge.amount != null && charge.amount!.isNegative) {
      throw InvalidAmountException(charge.amount!);
    }
    if (charge.transactionId == null && charge.reference == null) {
      throw ChargeException(Strings.noTransactionIdOrReference);
    }
  }
}
