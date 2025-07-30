import 'package:flutter_test/flutter_test.dart';
import 'package:sovendus_voucher_network_and_checkout_benefits/sovendus_voucher_network_and_checkout_benefits.dart';

void main() {
  group('HtmlSanitizer', () {
    test('should sanitize HTML input correctly', () {
      final result = HtmlSanitizer.sanitize('<script>alert("xss")</script>');
      expect(result, '&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;');

      final result2 = HtmlSanitizer.sanitize('Test & Co');
      expect(result2, 'Test &amp; Co');

      final result3 = HtmlSanitizer.sanitize("It's a test");
      expect(result3, 'It&#x27;s a test');

      final result4 = HtmlSanitizer.sanitize('Normal text');
      expect(result4, 'Normal text');
    });

    test('should handle nullable input correctly', () {
      final result1 = HtmlSanitizer.sanitizeNullable(null);
      expect(result1, null);

      final result2 = HtmlSanitizer.sanitizeNullable('<script>');
      expect(result2, '&lt;script&gt;');

      final result3 = HtmlSanitizer.sanitizeNullable('');
      expect(result3, '');
    });

    test('should escape all dangerous characters', () {
      final input = '&<>"\'';
      final result = HtmlSanitizer.sanitize(input);
      expect(result, '&amp;&lt;&gt;&quot;&#x27;');
    });
  });

  group('SovendusCustomerData', () {
    test('should create customer data with all fields', () {
      const customerData = SovendusCustomerData(
        salutation: 'Mr.',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
        yearOfBirth: 1990,
        dateOfBirth: '1990-01-01',
        street: 'Main Street',
        streetNumber: '123',
        zipcode: '12345',
        city: 'Test City',
        country: 'US',
      );

      expect(customerData.firstName, 'John');
      expect(customerData.lastName, 'Doe');
      expect(customerData.email, 'john.doe@example.com');
      expect(customerData.yearOfBirth, 1990);
    });

    test('should sanitize HTML in customer data', () {
      const customerData = SovendusCustomerData(
        firstName: '<script>alert("xss")</script>',
        lastName: 'Test & Co',
        email: 'test@example.com"onclick="alert(1)"',
      );

      final sanitized = customerData.sanitized();

      expect(sanitized.firstName,
          '&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;');
      expect(sanitized.lastName, 'Test &amp; Co');
      expect(sanitized.email,
          'test@example.com&quot;onclick=&quot;alert(1)&quot;');
    });

    test('should handle null values in sanitization', () {
      const customerData = SovendusCustomerData(
        firstName: 'John',
        lastName: null,
        email: null,
      );

      final sanitized = customerData.sanitized();

      expect(sanitized.firstName, 'John');
      expect(sanitized.lastName, null);
      expect(sanitized.email, null);
    });
  });

  group('SovendusBanner', () {
    testWidgets('should create banner with required parameters',
        (WidgetTester tester) async {
      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
      );

      expect(banner.trafficSourceNumber, 1234);
      expect(banner.trafficMediumNumber, 5678);
      expect(banner.orderUnixTime, 0);
      expect(banner.sessionId, '');
      expect(banner.backgroundColor, '#fff');
    });

    testWidgets('should create banner with all parameters',
        (WidgetTester tester) async {
      const customerData = SovendusCustomerData(
        firstName: 'John',
        lastName: 'Doe',
        country: 'US',
      );

      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
        orderUnixTime: 1699904232,
        sessionId: 'test-session-123',
        orderId: 'order-456',
        netOrderValue: 99.99,
        currencyCode: 'USD',
        usedCouponCode: 'SAVE10',
        customerData: customerData,
        padding: 15.0,
        backgroundColor: '#f5f3ef',
        disableAndroidWaitingForCheckoutBenefits: true,
      );

      expect(banner.trafficSourceNumber, 1234);
      expect(banner.trafficMediumNumber, 5678);
      expect(banner.orderUnixTime, 1699904232);
      expect(banner.sessionId, 'test-session-123');
      expect(banner.orderId, 'order-456');
      expect(banner.netOrderValue, 99.99);
      expect(banner.currencyCode, 'USD');
      expect(banner.usedCouponCode, 'SAVE10');
      expect(banner.customerData, customerData);
      expect(banner.padding, 15.0);
      expect(banner.backgroundColor, '#f5f3ef');
      expect(banner.disableAndroidWaitingForCheckoutBenefits, true);
    });

    test('should validate blacklisted URLs correctly', () {
      expect(
          SovendusBanner.isNotBlacklistedUrl(
              Uri.parse('https://example.com/test')),
          true);
      expect(
          SovendusBanner.isNotBlacklistedUrl(
              Uri.parse('https://example.com/banner/api/banner')),
          false);
      expect(
          SovendusBanner.isNotBlacklistedUrl(
              Uri.parse('https://example.com/app-list/test')),
          false);
      expect(SovendusBanner.isNotBlacklistedUrl(Uri.parse('blank')), false);
    });

    test('should generate HTML content for mobile platforms', () {
      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
        sessionId: 'test-session',
        orderId: 'test-order',
        backgroundColor: '#ffffff',
      );

      final html = banner.generateHtml();

      if (SovendusBanner.isMobileCheck) {
        expect(html.isNotEmpty, true);
        expect(html.contains('<!DOCTYPE html>'), true);
        expect(html.contains('sovendus-voucher-banner'), true);
        expect(html.contains('trafficSourceNumber: "1234"'), true);
        expect(html.contains('trafficMediumNumber: "5678"'), true);
        expect(html.contains('sessionId: "test-session"'), true);
        expect(html.contains('orderId: "test-order"'), true);
        expect(html.contains('background-color: #ffffff'), true);
      } else {
        expect(html, '');
      }
    });

    test('should return correct initial WebView height', () {
      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
      );

      if (SovendusBanner.isMobileCheck) {
        expect(banner.initialWebViewHeight, 348.0);
      } else {
        expect(banner.initialWebViewHeight, 0.0);
      }
    });

    test('should include customer data in HTML when provided', () {
      const customerData = SovendusCustomerData(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        country: 'US',
      );

      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
        customerData: customerData,
      );

      final html = banner.generateHtml();

      if (SovendusBanner.isMobileCheck) {
        expect(html.contains('consumerFirstName: "John"'), true);
        expect(html.contains('consumerLastName: "Doe"'), true);
        expect(html.contains('consumerEmail: "john@example.com"'), true);
        expect(html.contains('consumerCountry: "US"'), true);
      }
    });

    test('should handle HTML generation errors gracefully', () {
      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
      );

      // This should not throw an exception
      final html = banner.generateHtml();
      expect(html, isA<String>());
    });

    test('should call onError callback when provided', () async {
      String? capturedErrorMessage;
      dynamic capturedError;

      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
        onError: (errorMessage, error) {
          capturedErrorMessage = errorMessage;
          capturedError = error;
        },
      );

      // Test the reportError function
      await SovendusBanner.reportError(
        'Test error message',
        'Test error object',
        onError: banner.onError,
      );

      expect(capturedErrorMessage, 'Test error message');
      expect(capturedError, 'Test error object');
    });

    test('should handle null onError callback gracefully', () async {
      // This should not throw an exception
      await expectLater(() async {
        await SovendusBanner.reportError(
          'Test error message',
          'Test error object',
          onError: null,
        );
      }(), completes);
    });
  });
}
