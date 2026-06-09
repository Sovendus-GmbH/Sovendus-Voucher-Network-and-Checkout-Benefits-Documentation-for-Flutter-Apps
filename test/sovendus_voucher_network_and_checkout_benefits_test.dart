import 'package:flutter_test/flutter_test.dart';

import 'package:sovendus_voucher_network_and_checkout_benefits/sovendus_voucher_network_and_checkout_benefits.dart';

void main() {
  test('SovendusBanner exposes the values it was constructed with', () {
    const banner = SovendusBanner(
      trafficSourceNumber: 1234,
      trafficMediumNumber: 5678,
      hasConsent: true,
      customerData: SovendusCustomerData(firstName: 'John', lastName: 'Smith'),
    );

    expect(banner.trafficSourceNumber, 1234);
    expect(banner.trafficMediumNumber, 5678);
    expect(banner.hasConsent, isTrue);
    expect(banner.customerData?.firstName, 'John');
  });
}
