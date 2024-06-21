# Add a inline WebView on your success page

1. Download and install the component with the following command:

   ```bash
   flutter pub add sovendus_voucher_network_and_checkout_benefits
   ```

2. Use the component on the order success page, where you want to display the Sovendus banner.

   - Make sure to replace the arguments with the actual data from the purchase.
   - Replace YOUR_TRAFFIC_SOURCE_NUMBER with the one we provided you.
   - If you want to use the Voucher network, replace YOUR_VOUCHER_NETWORK_TRAFFIC_MEDIUM_NUMBER with the one we provided you, or remove the argument.
   - If you also use Checkout Benefits, replace YOUR_CHECKOUT_BENEFITS_TRAFFIC_MEDIUM_NUMBER with the one we provided you, or remove the argument.
   - Note that the height of the widget is determined by its content

   You can use the component like this:
   
   ```dart
   import 'package:sovendus_voucher_network_and_checkout_benefits/sovendus_voucher_network_and_checkout_benefits.dart';
   SovendusBanner(
       trafficSourceNumber: YOUR_TRAFFIC_SOURCE_NUMBER,
       trafficMediumNumberVoucherNetwork: YOUR_VOUCHER_NETWORK_TRAFFIC_MEDIUM_NUMBER,
       trafficMediumNumberCheckoutBenefits: YOUR_CHECKOUT_BENEFITS_TRAFFIC_MEDIUM_NUMBER,
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
