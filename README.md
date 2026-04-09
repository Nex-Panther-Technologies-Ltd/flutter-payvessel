# Flutter Payvessel

A Flutter SDK for integrating Payvessel Payment Gateway into your mobile app.

## Features

- 🌐 **WebView-based checkout** - Uses your existing web checkout, ensuring consistency
- 🔄 **Auto-updates** - Any web checkout improvements automatically apply to your app
- 📱 **Full-screen & Bottom Sheet modes** - Choose how to display the checkout
- ✅ **Simple API** - Just pass the transaction ID and get the result

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_payvessel: ^1.0.0
```

## Platform Setup

### Android

Add internet permission in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS

No additional setup required.

## Usage

### 1. Initialize Transaction on Server

First, initialize the transaction on your backend server using the Payvessel API:

```bash
curl -X POST https://api.payvessel.com/api/external/transactions/initialize \
  -H "Authorization: Bearer YOUR_SECRET_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 1000,
    "currency": "NGN",
    "email": "customer@email.com",
    "name": "Customer Name"
  }'
```

Response:
```json
{
  "status": true,
  "data": {
    "id": "txn_abc123xyz",
    "reference": "PV-1234567890"
  }
}
```

### 2. Launch Checkout in Flutter

```dart
import 'package:flutter_payvessel/flutter_payvessel.dart';

class PaymentPage extends StatelessWidget {
  final payvessel = Payvessel(
    config: PayvesselConfig(
      publicKey: 'pk_live_xxxxx', // Your public key
    ),
  );

  Future<void> makePayment(BuildContext context, String transactionId) async {
    final result = await payvessel.checkout(
      context: context,
      transactionId: transactionId, // From your server
    );

    if (result.isSuccessful) {
      print('Payment successful!');
      print('Reference: ${result.reference}');
      print('Payment ID: ${result.paymentId}');
      // Navigate to success page or update UI
    } else if (result.isCancelled) {
      print('Payment was cancelled');
    } else {
      print('Payment failed: ${result.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => makePayment(context, 'txn_abc123xyz'),
      child: Text('Pay Now'),
    );
  }
}
```

### Bottom Sheet Mode

```dart
final result = await payvessel.checkout(
  context: context,
  transactionId: transactionId,
  fullScreen: false, // Shows as bottom sheet
);
```

### Custom App Bar

```dart
final result = await payvessel.checkout(
  context: context,
  transactionId: transactionId,
  showAppBar: true,
  appBarTitle: 'Complete Payment',
);
```

### Embed in Your Own UI

```dart
Scaffold(
  body: payvessel.buildCheckoutView(
    transactionId: transactionId,
    showAppBar: false,
    onComplete: (result) {
      // Handle result
    },
    onCancelled: () {
      // Handle cancel
    },
  ),
)
```

## PayvesselResult Properties

| Property | Type | Description |
|----------|------|-------------|
| `status` | `PayvesselStatus` | The transaction status |
| `isSuccessful` | `bool` | Whether payment succeeded |
| `isFailed` | `bool` | Whether payment failed |
| `isCancelled` | `bool` | Whether user cancelled |
| `reference` | `String?` | The payment reference |
| `paymentId` | `String?` | The payment ID |
| `transactionId` | `String?` | The transaction ID |
| `message` | `String?` | Error or status message |

## Test Mode

For testing, use your test public key:

```dart
final payvessel = Payvessel(
  config: PayvesselConfig(
    publicKey: 'pk_test_xxxxx',
    testMode: true,
  ),
);
```

## Example

See the [example](example/) directory for a complete sample app.

## License

MIT License - see [LICENSE](LICENSE) for details.
