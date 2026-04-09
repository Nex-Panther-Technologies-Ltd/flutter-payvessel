import 'package:flutter/material.dart';
import 'package:flutter_payvessel/flutter_payvessel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payvessel Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B00)),
        useMaterial3: true,
      ),
      home: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final payvessel = Payvessel(
    config: PayvesselConfig(
      publicKey: 'pk_test_xxxxx', // Replace with your public key
    ),
  );

  String _status = 'Ready to pay';
  bool _isLoading = false;

  // In a real app, you would call your backend to initialize the transaction
  // and get the transaction ID. For demo purposes, we use a placeholder.
  Future<String> _initializeTransaction() async {
    // TODO: Call your backend API to initialize the transaction
    // Example:
    // final response = await http.post(
    //   Uri.parse('https://your-server.com/api/payments/initialize'),
    //   body: {'amount': 1000, 'email': 'customer@email.com'},
    // );
    // return jsonDecode(response.body)['transaction_id'];

    // For demo, return a test transaction ID
    return 'TEST-demo-transaction-id';
  }

  Future<void> _makePayment() async {
    setState(() {
      _isLoading = true;
      _status = 'Initializing payment...';
    });

    try {
      // Step 1: Initialize transaction on your server
      final transactionId = await _initializeTransaction();

      setState(() => _status = 'Opening checkout...');

      // Step 2: Launch checkout
      final result = await payvessel.checkout(
        context: context,
        transactionId: transactionId,
        appBarTitle: 'Complete Payment',
      );

      // Step 3: Handle result
      if (result.isSuccessful) {
        setState(
            () => _status = '✅ Payment successful!\nRef: ${result.reference}');
        _showSuccessDialog();
      } else if (result.isCancelled) {
        setState(() => _status = '❌ Payment cancelled');
      } else {
        setState(() => _status = '❌ Payment failed: ${result.message}');
      }
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: const Text('Your payment has been processed successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payvessel Demo'),
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Product Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Color(0xFFFF6B00),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Premium Subscription',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '₦1,000.00',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B00),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _makePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Pay with Payvessel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
