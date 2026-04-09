# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-09

### Added
- Initial release of Flutter Payvessel SDK
- `Payvessel` class for initializing checkout
- `initializeCheckout()` method similar to npm package API
- `CheckoutParams` for configuring payment details
- Support for Bank Transfer and Card payment channels
- `PayvesselResult` for handling payment outcomes
- Full-screen and bottom sheet checkout modes
- WebView-based checkout using existing web checkout
- Callbacks for onSuccess, onError, and onClose events
- Example app demonstrating SDK usage

### Features
- Simple, promise-based API matching npm `payvessel-checkout` package
- Customer details: email, phone, name
- Amount and currency configuration
- Multiple payment channels support
- Custom metadata support
- Transaction reference support
- Redirect URL support
