import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/payvessel_config.dart';
import '../models/payvessel_result.dart';
import '../models/checkout_params.dart';
import 'dart:convert';

/// A WebView widget that displays the Payvessel checkout page.
///
/// Supports two modes:
/// 1. Inline checkout - Initialize directly with customer details (like npm package)
/// 2. Transaction ID checkout - Load a pre-initialized transaction
class PayvesselCheckoutView extends StatefulWidget {
  /// The transaction ID to load (for pre-initialized transactions).
  final String? transactionId;

  /// Checkout parameters for inline initialization.
  final CheckoutParams? checkoutParams;

  /// The Payvessel configuration.
  final PayvesselConfig config;

  /// Callback when the transaction is completed.
  final void Function(PayvesselResult result)? onComplete;

  /// Callback when an error occurs.
  final void Function(String error)? onError;

  /// Callback when the checkout is closed/cancelled.
  final VoidCallback? onCancelled;

  /// Whether to show the app bar.
  final bool showAppBar;

  /// The app bar title.
  final String appBarTitle;

  /// Custom app bar widget.
  final PreferredSizeWidget? appBar;

  const PayvesselCheckoutView({
    super.key,
    this.transactionId,
    this.checkoutParams,
    required this.config,
    this.onComplete,
    this.onError,
    this.onCancelled,
    this.showAppBar = true,
    this.appBarTitle = 'Checkout',
    this.appBar,
  }) : assert(transactionId != null || checkoutParams != null,
            'Either transactionId or checkoutParams must be provided');

  @override
  State<PayvesselCheckoutView> createState() => _PayvesselCheckoutViewState();
}

class _PayvesselCheckoutViewState extends State<PayvesselCheckoutView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _checkForRedirect(url);

            // Inject JS to listen for checkout events
            _injectEventListeners();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
              _isLoading = false;
            });
            widget.onError?.call(error.description);
          },
          onNavigationRequest: (NavigationRequest request) {
            // Check if this is a redirect URL indicating completion
            if (_isRedirectUrl(request.url)) {
              _handleRedirect(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'PayvesselFlutter',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJsMessage(message.message);
        },
      );

    // Load the appropriate URL
    if (widget.transactionId != null) {
      _controller.loadRequest(Uri.parse(_getTransactionUrl()));
    } else {
      _loadInlineCheckout();
    }
  }

  String _getTransactionUrl() {
    return widget.config.getCheckoutUrl(widget.transactionId!);
  }

  void _loadInlineCheckout() {
    final params = widget.checkoutParams!;

    // Build the HTML page that initializes the checkout
    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #f5f5f5;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .loading {
      text-align: center;
      color: #666;
    }
    .spinner {
      width: 40px;
      height: 40px;
      border: 3px solid #f3f3f3;
      border-top: 3px solid #ff6b00;
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin: 0 auto 16px;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <div class="loading">
    <div class="spinner"></div>
    <p>Initializing checkout...</p>
  </div>
  
  <script src="https://cdn.jsdelivr.net/npm/payvessel-checkout@latest/dist/index.umd.js"></script>
  <script>
    (async function() {
      try {
        const init = PayvesselCheckout.Checkout({
          api_key: "${widget.config.apiKey}",
        });

        await init.initializeCheckout({
          customer_email: "${params.customerEmail}",
          customer_phone_number: "${params.customerPhoneNumber}",
          amount: "${params.amount}",
          currency: "${params.currency}",
          customer_name: "${params.customerName}",
          ${params.channels != null ? 'channels: ${jsonEncode(params.channels)},' : ''}
          ${params.metadata != null ? 'metadata: ${jsonEncode(params.metadata)},' : ''}
          ${params.reference != null ? 'reference: "${params.reference}",' : ''}
          ${params.redirectUrl != null ? 'redirect_url: "${params.redirectUrl}",' : ''}
          onError: (error) => {
            PayvesselFlutter.postMessage(JSON.stringify({
              event: 'error',
              data: error
            }));
          },
          onSuccess: (response) => {
            PayvesselFlutter.postMessage(JSON.stringify({
              event: 'success',
              data: response
            }));
          },
          onSuccessfulOrder: (order) => {
            PayvesselFlutter.postMessage(JSON.stringify({
              event: 'order_confirmed',
              data: order
            }));
          },
          onClose: (reference) => {
            PayvesselFlutter.postMessage(JSON.stringify({
              event: 'close',
              data: { reference: reference }
            }));
          },
        });
      } catch (e) {
        PayvesselFlutter.postMessage(JSON.stringify({
          event: 'error',
          data: { message: e.message || 'Failed to initialize checkout' }
        }));
      }
    })();
  </script>
</body>
</html>
''';

    _controller.loadHtmlString(html);
  }

  void _injectEventListeners() {
    // Inject additional event listeners for the checkout modal
    _controller.runJavaScript('''
      window.addEventListener('message', function(event) {
        if (event.data && typeof event.data === 'object') {
          PayvesselFlutter.postMessage(JSON.stringify(event.data));
        }
      });
    ''');
  }

  bool _isRedirectUrl(String url) {
    return url.contains('payment_ref=') ||
        url.contains('payment_id=') ||
        url.contains('status=success') ||
        url.contains('status=failed');
  }

  void _checkForRedirect(String url) {
    if (_isRedirectUrl(url)) {
      _handleRedirect(url);
    }
  }

  void _handleRedirect(String url) {
    final uri = Uri.parse(url);
    final params = uri.queryParameters;

    final result = PayvesselResult.fromRedirectParams(
      params.map((key, value) => MapEntry(key, value)),
    );

    widget.onComplete?.call(result);
  }

  void _handleJsMessage(String message) {
    try {
      final data = jsonDecode(message);
      final event = data['event'];
      final eventData = data['data'];

      switch (event) {
        case 'success':
          widget.onComplete?.call(PayvesselResult(
            status: PayvesselStatus.success,
            reference: eventData['reference'],
            transactionId: eventData['id'] ?? eventData['transaction_id'],
            data: eventData is Map<String, dynamic> ? eventData : null,
          ));
          break;
        case 'order_confirmed':
          widget.onComplete?.call(PayvesselResult(
            status: PayvesselStatus.success,
            reference: eventData['reference'],
            transactionId: eventData['id'] ?? eventData['transaction_id'],
            paymentId: eventData['payment_id'],
            data: eventData is Map<String, dynamic> ? eventData : null,
          ));
          break;
        case 'error':
          final errorMsg = eventData['message'] ?? 'Payment failed';
          widget.onError?.call(errorMsg);
          widget.onComplete?.call(PayvesselResult.failed(errorMsg));
          break;
        case 'close':
          widget.onCancelled?.call();
          break;
        case 'payment_success':
          widget.onComplete?.call(PayvesselResult(
            status: PayvesselStatus.success,
            transactionId: widget.transactionId,
          ));
          break;
        case 'payment_failed':
          widget.onComplete?.call(PayvesselResult.failed('Payment failed'));
          break;
        case 'checkout_closed':
          widget.onCancelled?.call();
          break;
      }
    } catch (e) {
      // Handle legacy string messages
      if (message == 'payment_success') {
        widget.onComplete?.call(PayvesselResult(
          status: PayvesselStatus.success,
          transactionId: widget.transactionId,
        ));
      } else if (message == 'payment_failed') {
        widget.onComplete?.call(PayvesselResult.failed('Payment failed'));
      } else if (message == 'checkout_closed') {
        widget.onCancelled?.call();
      }
    }
  }

  void _handleCancel() {
    widget.onCancelled?.call();
    widget.onComplete?.call(PayvesselResult.cancelled());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ??
          (widget.showAppBar
              ? AppBar(
                  title: Text(widget.appBarTitle),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _handleCancel,
                  ),
                )
              : null),
      body: Stack(
        children: [
          if (_hasError)
            _buildErrorView()
          else
            WebViewWidget(controller: _controller),
          if (_isLoading) _buildLoadingView(),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6B00),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load checkout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _controller.reload();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
