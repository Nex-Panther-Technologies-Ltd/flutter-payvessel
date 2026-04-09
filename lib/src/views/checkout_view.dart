import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/payvessel_config.dart';
import '../models/payvessel_result.dart';

/// A WebView widget that displays the Payvessel checkout page.
class PayvesselCheckoutView extends StatefulWidget {
  /// The transaction ID to load.
  final String transactionId;

  /// The Payvessel configuration.
  final PayvesselConfig config;

  /// Callback when the transaction is completed.
  final void Function(PayvesselResult result)? onComplete;

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
    required this.transactionId,
    required this.config,
    this.onComplete,
    this.onCancelled,
    this.showAppBar = true,
    this.appBarTitle = 'Checkout',
    this.appBar,
  });

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
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
              _isLoading = false;
            });
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
      )
      ..loadRequest(Uri.parse(_getCheckoutUrl()));
  }

  String _getCheckoutUrl() {
    return widget.config.getCheckoutUrl(widget.transactionId);
  }

  bool _isRedirectUrl(String url) {
    // Check for common redirect patterns
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
    // Handle messages from the web checkout
    // The web checkout can send: payment_success, payment_failed, checkout_closed
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
          color: Color(0xFFFF6B00), // Payvessel brand color
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
