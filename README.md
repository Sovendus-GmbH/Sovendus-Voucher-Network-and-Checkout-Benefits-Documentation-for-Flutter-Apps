# 🚀 Sovendus Component for Flutter

A Flutter package that provides seamless integration with Sovendus Voucher Network and Checkout Benefits, enabling you to display personalized offers and vouchers to your customers after successful purchases.

## ⚠️ Disclaimer

> [!WARNING]
> **Open Source License & Support**
> This component is released as open source under the GPL v3 license. We welcome bug reports and pull requests from the community. However, please note that the component is provided "as is" without any warranties or guarantees. It may not be compatible with all other plugins and could potentially cause issues with your store. We strongly recommend that you test the plugin thoroughly in a staging environment before deploying it to a live site. Furthermore, we do not promise future support or updates and reserve the right to discontinue support for the component at any time.

## 📦 Installation

### 1. Add the Package

Install the Sovendus Flutter component using the following command:

```bash
flutter pub add sovendus_voucher_network_and_checkout_benefits
```

### 2. Import the Package

```dart
import 'package:sovendus_voucher_network_and_checkout_benefits/sovendus_voucher_network_and_checkout_benefits.dart';
```

## 🎯 Integration

### ⚠️ Important Considerations

#### Banner Variants

> [!WARNING]
> **Supported Banner Types**
> This component currently only supports **inline/embedded banner variants**. Overlay or sticky banners are not supported. Any overlay functionality needs to be implemented on your side in Flutter.

#### Android Performance Optimization

> [!ERROR]
> **Android Performance Issue**
> When only using a Voucher Network banner **without Checkout Benefits**, you must set `disableAndroidWaitingForCheckoutBenefits: true` to avoid a 5-second delay on Android devices. This is due to a known bug in the `flutter_inappwebview` library.

```dart
SovendusBanner(
  trafficSourceNumber: YOUR_TRAFFIC_SOURCE_NUMBER,
  trafficMediumNumber: TRAFFIC_MEDIUM_NUMBER,
  disableAndroidWaitingForCheckoutBenefits: true, // Add this for VN-only
  // ... other parameters
)
```

## 💻 Usage Example

### Complete Implementation

> [!INFO]
> **Parameter Documentation**
> For detailed information on all parameters and which ones are required, visit our [Parameter Documentation](https://developer-hub.sovendus.com/Voucher-Network-Checkout-Benefits/Parameter).

```dart
import 'package:sovendus_voucher_network_and_checkout_benefits/sovendus_voucher_network_and_checkout_benefits.dart';

class OrderSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Confirmation')),
      body: Column(
        children: [
          // Your order confirmation content
          Text('Thank you for your order!'),

          // Sovendus Banner
          SovendusBanner(
            trafficSourceNumber: YOUR_TRAFFIC_SOURCE_NUMBER,
            trafficMediumNumber: TRAFFIC_MEDIUM_NUMBER,
            sessionId: "unique-session-id",
            orderId: "Order-123",
            netOrderValue: 120.5,
            currencyCode: "EUR",
            usedCouponCode: "CouponCodeFromThePurchase",
            customerData: SovendusCustomerData(
              salutation: "Mr.",
              firstName: "John",
              lastName: "Smith",
              email: "example@example.com",
              phone: "+4915546456456",
              yearOfBirth: 1990,
              dateOfBirth: "01.12.2020",
              street: "Main Street",
              streetNumber: "12/1",
              zipcode: "76135",
              city: "Karlsruhe",
              country: "DE",
            ),
            // Custom loading indicator (optional)
            customProgressIndicator: CircularProgressIndicator(
              color: Colors.orange,
            ),
            // Error handling (optional)
            onError: (message, error) {
              print('Sovendus Error: $message');
              // Handle error appropriately
            },
          ),
        ],
      ),
    );
  }
}
```

## 🔧 Parameter Configuration

### Replace Placeholder Variables

> [!WARNING]
> **Replace Placeholder Variables**
> Make sure to replace `YOUR_TRAFFIC_SOURCE_NUMBER` and `TRAFFIC_MEDIUM_NUMBER` with the actual values provided by Sovendus. These are unique identifiers for your integration.

#### Sovendus Identifiers

- **`trafficSourceNumber`** - Your unique Sovendus traffic source number
- **`trafficMediumNumber`** - Your unique Sovendus traffic medium number

> [!INFO]
> **Parameter Documentation**
> For detailed information on all parameters, examples, and requirements, visit: [Parameter Documentation](https://developer-hub.sovendus.com/Voucher-Network-Checkout-Benefits/Parameter)

#### Order Information

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `sessionId` | `String` | `""` | Unique session identifier |
| `orderId` | `String` | `""` | Unique order identifier |
| `netOrderValue` | `double` | `0` | Net order value |
| `currencyCode` | `String` | `""` | ISO currency code (e.g., "EUR", "GBP") |
| `usedCouponCode` | `String` | `""` | Coupon code used in the order |

#### Customer Data

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `customerData` | `SovendusCustomerData?` | `null` | Customer information object |

#### Customization Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `customProgressIndicator` | `Widget?` | `null` | Custom loading indicator widget |
| `padding` | `double` | `0` | Padding around the banner in pixels |
| `backgroundColor` | `String` | `"#fff"` | Background color in hex format |

#### Performance & Error Handling

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `disableAndroidWaitingForCheckoutBenefits` | `bool` | `false` | Disable Android delay for VN-only integration |
| `onError` | `Function?` | `null` | Error callback function `(String message, dynamic error)` |

### Customer Data Object

The `SovendusCustomerData` class accepts the following optional parameters:

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `salutation` | `String?` | Customer salutation | `"Mr."`, `"Ms."` |
| `firstName` | `String?` | Customer first name | `"John"` |
| `lastName` | `String?` | Customer last name | `"Smith"` |
| `email` | `String?` | Customer email address | `"john@example.com"` |
| `phone` | `String?` | Customer phone number | `"+4915546456456"` |
| `yearOfBirth` | `int?` | Customer birth year | `1990` |
| `dateOfBirth` | `String?` | Customer birth date | `"01.12.1990"` |
| `street` | `String?` | Street address | `"Main Street"` |
| `streetNumber` | `String?` | Street number | `"123"` |
| `zipcode` | `String?` | Postal code | `"76135"` |
| `city` | `String?` | City name | `"Karlsruhe"` |
| `country` | `String?` | Country code (ISO 2-letter) | `"DE"`, `"GB"` |

## 🤝 Contributing

We welcome contributions! Please feel free to submit pull requests. If you have found any bugs please don't open a bug report, but instead get in touch with your Sovendus account manager.

### Development Setup

For contributors who want to work on this package, see our [Development Guide](https://github.com/Sovendus-GmbH/Sovendus-Voucher-Network-and-Checkout-Benefits-Documentation-for-Flutter-Apps/blob/main/README-dev.md)
