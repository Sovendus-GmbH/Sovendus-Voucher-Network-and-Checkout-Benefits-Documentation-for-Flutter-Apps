# Sovendus Component for Flutter

## Disclaimer

This component is released as open source under the GPL v3 license. We welcome bug reports and pull requests from the community. However, please note that the component is provided "as is" without any warranties or guarantees. It may not be compatible with all other plugins and could potentially cause issues with your store. We strongly recommend that you test the plugin thoroughly in a staging environment before deploying it to a live site. Furthermore, we do not promise future support or updates and reserve the right to discontinue support for the component at any time.

## 1. Download and install the component with the following command

   ```bash
   flutter pub add sovendus_voucher_network_and_checkout_benefits
   ```

## 2. Use the component on the order success page, where you want to display the Sovendus banner

- Make sure to replace the arguments with the actual data from the purchase.
- Replace YOUR_TRAFFIC_SOURCE_NUMBER and TRAFFIC_MEDIUM_NUMBER with the one we provided you.
- Note that the height of the widget is determined by its content

## Important Notes

- **Banner Variants:** This component currently only supports inline/embedded banner variants. Overlay or sticky banners are not supported. Any overlay functionality needs to be implemented on your side in Flutter.

- **Android Performance:** When only using a Voucher Network banner without Checkout Benefits, you must set `disableAndroidWaitingForCheckoutBenefits: true` to avoid a 5-second delay on Android devices. This is due to a known bug in the `flutter_inappwebview` library.

## Usage

You can use the component like this:

[Click here for detailed information on the parameters and which ones are required.](https://developer-hub.sovendus.com/Voucher-Network-Checkout-Benefits/Parameter)

   ```dart
   import 'package:sovendus_voucher_network_and_checkout_benefits/sovendus_voucher_network_and_checkout_benefits.dart';
   SovendusBanner(
       trafficSourceNumber: YOUR_TRAFFIC_SOURCE_NUMBER,
       trafficMediumNumber: TRAFFIC_MEDIUM_NUMBER,
       orderUnixTime: 1699904232,
       sessionId: "kljadkaskdlaksdjaskd",
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
           street: "Teststreet",
           streetNumber: "12/1",
           zipcode: "76135",
           city: "Karlsruhe",
           country: "DE",
       ),
       // Until the banner is loaded we're showing a loading indicator,
       // optionally you can pass a custom loading spinner with the type Widget
       customProgressIndicator: RefreshProgressIndicator(),
   )
   ```
