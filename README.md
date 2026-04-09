# Flutter Payvessel

A Flutter SDK for integrating Payvessel Payment Gateway into your mobile app.
Works similar to the [npm package](https://www.npmjs.com/package/payvessel-checkout).

## Features

`payvessel-checkout`
- 💳 **Multiple Channels** - Bank Transfer and Card payments
- 📱 **Full-screen & Bottom Sheet** - Choose how to display checkout
- 🔄 **Callbacks** - onSuccess, onError, onClose support
- 🌐 **WebView-based** - Uses your existing web checkout

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

### Initialize and Launch Checkout

Similar to the npm package:

```dart
import 'package:flutter_payvessel/flutter_payvessel.dart';

// Create Payvessel instance with your API key
final payvessel = Payvessel(
  config: PayvesselConfig(
    apiKey: 'YOUR_API_KEY',
  ),
);

// Launch checkout
Future<void> openCheckout() async {
  final result = await payvessel.initializeCheckout(
    context: context,
    params: CheckoutParams(
      customerEmail: 'customer@example.com',
      customerPhoneNumber: '08012345678',
      amount: '1000',
      currency: 'NGN',
      customerName: 'John Doe',
      channels: [
        PaymentChannels.bankTransfer,
        PaymentChannels.card,
      ],
      metadata: {
        'order_id': '12345',
      },
    ),
    onError: (error) => print('Error: $error'),
  );

  if (result.isSuccessful) {
    print('Payment successful!');
    print('Reference: ${result.reference}');
  } else if (result.isCancelled) {
    print('Payment cancelled');
  } else {
    print('Payment failed: ${result.message}');
  }
}
```

### Trigger from a Button

```dart
ElevatedButton(
  onPressed: openCheckout,
  child: Text('Pay with Payvessel'),
)
```

### Bottom Sheet Mode

```dart
final result = await payvessel.initializeCheckout(
  context: context,
  params: params,
  fullScreen: false, // Shows as bottom sheet
);
```

## Parameters

### PayvesselConfig

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| apiKey | String | ✅ | Your Payvessel API key |
| checkoutUrl | String | ❌ | Custom checkout URL (optional) |

### CheckoutParams

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| customerEmail | String | ✅ | Customer's email |
| customerPhoneNumber | String | ✅ | Customer's phone number |
| amount | String | ✅ | Amount to charge (e.g., "1000") |
| currency | String | ✅ | Currency code (e.g., "NGN") |
| customerName | String | ✅ | Full name of the customer |
| channels | List<String> | ❌ | Payment channels. Defaults to BANK_TRANSFER |
| metadata | Map | ❌ | Custom metadata object |
| reference | String | ❌ | Unique transaction reference |
| redirectUrl | String | ❌ | URL to redirect after payment |

### PayvesselResult

| Property | Type | Description |
|----------|------|-------------|
| status | PayvesselStatus | Transaction status |
| isSuccessful | bool | Whether payment succeeded |
| isFailed | bool | Whether payment failed |
| isCancelled | bool | Whether user cancelled |
| reference | String? | Payment reference |
| paymentId | String? | Payment ID |
| transactionId | String? | Transaction ID |
| message | String? | Error or status message |

## Payment Channels

```dart
PaymentChannels.bankTransfer  // "BANK_TRANSFER"
PaymentChannels.card          // "CARD"
PaymentChannels.all           // Both channels
```

## Comparison with npm Package

| npm Package | Flutter SDK |
|-------------|-------------|
| `Checkout({ api_key })` | `Payvessel(config: PayvesselConfig(apiKey: ...))` |
| `initializeCheckout({ ... })` | `payvessel.initializeCheckout(params: CheckoutParams(...))` |
| `onSuccess` | `result.isSuccessful` |
| `onError` | `onError` callback or `result.isFailed` |
| `onClose` | `result.isCancelled` |

## Example

See the [example](example/) directory for a complete sample app.

## License

MIT License
