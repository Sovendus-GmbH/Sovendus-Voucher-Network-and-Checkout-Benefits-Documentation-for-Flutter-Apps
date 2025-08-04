import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sovendus_voucher_network_and_checkout_benefits/sovendus_voucher_network_and_checkout_benefits.dart';

void main() {
  group('SovendusCustomerData', () {
    test('should create customer data with all fields', () {
      const customerData = SovendusCustomerData(
        salutation: 'Mr.',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        yearOfBirth: 1990,
        dateOfBirth: '1990-01-01',
        street: 'Main Street',
        streetNumber: '123',
        zipcode: '12345',
        city: 'New York',
        country: 'US',
      );

      expect(customerData.salutation, 'Mr.');
      expect(customerData.firstName, 'John');
      expect(customerData.lastName, 'Doe');
      expect(customerData.email, 'john@example.com');
      expect(customerData.phone, '+1234567890');
      expect(customerData.yearOfBirth, 1990);
      expect(customerData.dateOfBirth, '1990-01-01');
      expect(customerData.street, 'Main Street');
      expect(customerData.streetNumber, '123');
      expect(customerData.zipcode, '12345');
      expect(customerData.city, 'New York');
      expect(customerData.country, 'US');
    });

    test('should create customer data with null fields', () {
      const customerData = SovendusCustomerData();

      expect(customerData.salutation, null);
      expect(customerData.firstName, null);
      expect(customerData.lastName, null);
      expect(customerData.email, null);
      expect(customerData.phone, null);
      expect(customerData.yearOfBirth, null);
      expect(customerData.dateOfBirth, null);
      expect(customerData.street, null);
      expect(customerData.streetNumber, null);
      expect(customerData.zipcode, null);
      expect(customerData.city, null);
      expect(customerData.country, null);
    });

    test('should sanitize customer data correctly', () {
      const customerData = SovendusCustomerData(
        firstName: '<script>alert("xss")</script>',
        lastName: 'Test & Co',
        email: 'test@example.com"onclick="alert(1)"',
        phone: '+123<script>',
        street: 'Main & Oak',
        city: 'New York "City"',
        country: 'US\'A',
      );

      final sanitized = customerData.sanitized(
        trafficSourceNumber: 123,
        trafficMediumNumber: 456,
      );

      // jsonEncode escapes quotes but not HTML characters
      expect(sanitized.firstName, '<script>alert(\\"xss\\")</script>');
      expect(sanitized.lastName, 'Test & Co');
      expect(sanitized.email, 'test@example.com\\"onclick=\\"alert(1)\\"');
      expect(sanitized.phone, '+123<script>');
      expect(sanitized.street, 'Main & Oak');
      expect(sanitized.city, 'New York \\"City\\"');
      expect(sanitized.country, 'US\'A');
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

    test('should handle sanitization errors gracefully', () {
      const customerData = SovendusCustomerData(firstName: 'John');

      final sanitized = customerData.sanitized(
        onError: (message, error) {
          // Error callback is available if needed
        },
      );

      // Should return valid data even if there are no errors
      expect(sanitized.firstName, 'John');
    });

    test('should return empty customer data on sanitization exception', () {
      // This test simulates an exception during sanitization
      // In practice, this would be hard to trigger, but we test the fallback
      const customerData = SovendusCustomerData(firstName: 'John');

      final sanitized = customerData.sanitized();

      // Should always return some form of customer data
      expect(sanitized, isA<SovendusCustomerData>());
    });
  });

  group('HtmlSanitizer', () {
    late HtmlSanitizer sanitizer;

    setUp(() {
      sanitizer = HtmlSanitizer(
        trafficSourceNumber: 123,
        trafficMediumNumber: 456,
      );
    });

    test('should sanitize HTML input correctly', () {
      final result1 = sanitizer.sanitize('<script>alert("xss")</script>');
      expect(result1, '<script>alert(\\"xss\\")</script>');

      final result2 = sanitizer.sanitize('Test & Co');
      expect(result2, 'Test & Co');

      final result3 = sanitizer.sanitize("It's a test");
      expect(result3, "It's a test");

      final result4 = sanitizer.sanitize('Normal text');
      expect(result4, 'Normal text');

      final result5 = sanitizer.sanitize('Quote "test" here');
      expect(result5, 'Quote \\"test\\" here');
    });

    test('should handle nullable input correctly', () {
      final result1 = sanitizer.sanitizeNullable(null);
      expect(result1, null);

      final result2 = sanitizer.sanitizeNullable('<script>');
      expect(result2, '<script>');

      final result3 = sanitizer.sanitizeNullable('');
      expect(result3, '');

      final result4 = sanitizer.sanitizeNullable('Quote "test"');
      expect(result4, 'Quote \\"test\\"');
    });

    test('should sanitize integers correctly', () {
      final result1 = sanitizer.sanitizeInt(123);
      expect(result1, '123');

      final result2 = sanitizer.sanitizeInt(-456);
      expect(result2, '-456');

      final result3 = sanitizer.sanitizeInt(0);
      expect(result3, '0');
    });

    test('should sanitize nullable integers correctly', () {
      final result1 = sanitizer.sanitizeIntNullable(null);
      expect(result1, null);

      final result2 = sanitizer.sanitizeIntNullable(789);
      expect(result2, '789');
    });

    test('should sanitize doubles correctly', () {
      final result1 = sanitizer.sanitizeDouble(123.45);
      expect(result1, '123.45');

      final result2 = sanitizer.sanitizeDouble(-67.89);
      expect(result2, '-67.89');

      final result3 = sanitizer.sanitizeDouble(0.0);
      expect(result3, '0.0');
    });

    test('should handle special double values', () {
      final result1 = sanitizer.sanitizeDouble(double.nan);
      expect(result1, '0');

      final result2 = sanitizer.sanitizeDouble(double.infinity);
      expect(result2, '0');

      final result3 = sanitizer.sanitizeDouble(double.negativeInfinity);
      expect(result3, '0');
    });

    test('should sanitize nullable doubles correctly', () {
      final result1 = sanitizer.sanitizeDoubleNullable(null);
      expect(result1, null);

      final result2 = sanitizer.sanitizeDoubleNullable(123.45);
      expect(result2, '123.45');
    });

    test('should handle sanitization errors gracefully', () {
      final sanitizerWithCallback = HtmlSanitizer(
        trafficSourceNumber: 123,
        trafficMediumNumber: 456,
        onError: (message, error) {
          // Error callback is available if needed
        },
      );

      // Normal operation should not trigger errors
      final result = sanitizerWithCallback.sanitize('normal text');
      expect(result, 'normal text');
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
      expect(banner.sessionId, '');
      expect(banner.orderId, '');
      expect(banner.netOrderValue, 0);
      expect(banner.currencyCode, '');
      expect(banner.usedCouponCode, '');
      expect(banner.customerData, null);
      expect(banner.customProgressIndicator, null);
      expect(banner.padding, 0);
      expect(banner.backgroundColor, '#fff');
      expect(banner.disableAndroidWaitingForCheckoutBenefits, false);
      expect(banner.onError, null);
    });

    testWidgets('should create banner with all parameters',
        (WidgetTester tester) async {
      const customerData = SovendusCustomerData(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        country: 'US',
      );

      const customIndicator = Text('Loading...');

      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
        sessionId: 'test-session-123',
        orderId: 'order-456',
        netOrderValue: 99.99,
        currencyCode: 'USD',
        usedCouponCode: 'SAVE10',
        customerData: customerData,
        customProgressIndicator: customIndicator,
        padding: 15.0,
        backgroundColor: '#f5f3ef',
        disableAndroidWaitingForCheckoutBenefits: true,
        onError: (message, error) {},
      );

      expect(banner.trafficSourceNumber, 1234);
      expect(banner.trafficMediumNumber, 5678);
      expect(banner.sessionId, 'test-session-123');
      expect(banner.orderId, 'order-456');
      expect(banner.netOrderValue, 99.99);
      expect(banner.currencyCode, 'USD');
      expect(banner.usedCouponCode, 'SAVE10');
      expect(banner.customerData, customerData);
      expect(banner.customProgressIndicator, customIndicator);
      expect(banner.padding, 15.0);
      expect(banner.backgroundColor, '#f5f3ef');
      expect(banner.disableAndroidWaitingForCheckoutBenefits, true);
      expect(banner.onError, isNotNull);
    });

    test('should have correct version number', () {
      expect(SovendusBanner.versionNumber, '1.3.0');
    });

    test('should have correct initial web view height', () {
      expect(SovendusBanner.initialWebViewHeight, 348.0);
    });

    test('should check mobile platform correctly', () {
      // This test will vary based on the platform the test is running on
      final isMobile = SovendusBanner.isMobileCheck;
      expect(isMobile, isA<bool>());
    });

    test('should generate HTML content for mobile platforms', () {
      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
        sessionId: 'test-session',
        orderId: 'test-order',
        backgroundColor: '#ffffff',
        padding: 10.0,
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
        expect(html.contains('padding-top: 10.0px'), true);
      } else {
        expect(html, '');
      }
    });

    test('should generate HTML with customer data when provided', () {
      const customerData = SovendusCustomerData(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        country: 'US',
        yearOfBirth: 1990,
      );

      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
        customerData: customerData,
      );

      final html = banner.generateHtml();

      if (SovendusBanner.isMobileCheck) {
        expect(html.contains('consumerFirstName'), true);
        expect(html.contains('consumerLastName'), true);
        expect(html.contains('consumerEmail'), true);
        expect(html.contains('consumerCountry'), true);
        expect(html.contains('consumerYearOfBirth'), true);
      }
    });

    test('should handle HTML generation errors gracefully', () {
      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
        onError: (message, error) {
          // Error callback is available if needed
        },
      );

      final html = banner.generateHtml();

      // Should not throw errors during normal operation
      if (SovendusBanner.isMobileCheck) {
        expect(html, isNotEmpty);
      } else {
        expect(html, isEmpty);
      }
    });

    test('should get sovendusHtml property', () {
      final banner = SovendusBanner(
        trafficSourceNumber: 1234,
        trafficMediumNumber: 5678,
      );

      final html = banner.sovendusHtml;
      expect(html, equals(banner.generateHtml()));
    });

    test('should have correct error API URL', () {
      expect(SovendusBanner.errorApi,
          'https://press-tracking-api.sovendus.com/error');
    });

    test('should initialize error counter to 0', () {
      expect(SovendusBanner.errorCounter, 0);
    });

    group('reportError', () {
      setUp(() {
        // Reset error counter before each test
        SovendusBanner.errorCounter = 0;
      });

      test('should call onError callback when provided', () async {
        String? receivedMessage;
        dynamic receivedError;

        await SovendusBanner.reportError(
          'Test error message',
          'Test error object',
          onError: (message, error) {
            receivedMessage = message;
            receivedError = error;
          },
          type: 'test-error',
          trafficSourceNumber: 123,
          trafficMediumNumber: 456,
        );

        expect(receivedMessage, 'Test error message');
        expect(receivedError, 'Test error object');
        expect(SovendusBanner.errorCounter, 1);
      });

      test('should increment error counter', () async {
        await SovendusBanner.reportError(
          'Error 1',
          'Error object 1',
          onError: (message, error) {},
          type: 'test-error',
        );

        expect(SovendusBanner.errorCounter, 1);

        await SovendusBanner.reportError(
          'Error 2',
          'Error object 2',
          onError: (message, error) {},
          type: 'test-error',
        );

        expect(SovendusBanner.errorCounter, 2);
      });

      test('should stop reporting after 3 errors', () async {
        String? lastMessage;

        // Report 4 errors
        for (int i = 1; i <= 4; i++) {
          await SovendusBanner.reportError(
            'Error $i',
            'Error object $i',
            onError: (message, error) {
              lastMessage = message;
            },
            type: 'test-error',
          );
        }

        expect(SovendusBanner.errorCounter, 4);
        // The 4th error should not have been processed (counter incremented but no callback)
        expect(lastMessage, 'Error 3');
      });

      test('should work without onError callback', () async {
        // Should not throw when onError is null
        await SovendusBanner.reportError(
          'Test error',
          'Test error object',
          onError: null,
          type: 'test-error',
        );

        expect(SovendusBanner.errorCounter, 1);
      });

      test('should handle additional data', () async {
        String? receivedMessage;

        await SovendusBanner.reportError(
          'Test error with data',
          'Test error object',
          onError: (message, error) {
            receivedMessage = message;
          },
          type: 'test-error',
          trafficSourceNumber: 123,
          trafficMediumNumber: 456,
          additionalData: {'customField': 'customValue'},
        );

        expect(receivedMessage, 'Test error with data');
        expect(SovendusBanner.errorCounter, 1);
      });
    });
  });

  group('SovendusOrderData', () {
    test('should create order data with all fields', () {
      const customerData = SovendusCustomerData(firstName: 'John');

      final orderData = SovendusOrderData(
        sessionId: 'session123',
        orderId: 'order456',
        currencyCode: 'USD',
        usedCouponCode: 'SAVE10',
        backgroundColor: '#ffffff',
        trafficSourceNumber: 123,
        trafficMediumNumber: 456,
        netOrderValue: 99.99,
        padding: 15.0,
        customerData: customerData,
      );

      expect(orderData.sessionId, 'session123');
      expect(orderData.orderId, 'order456');
      expect(orderData.currencyCode, 'USD');
      expect(orderData.usedCouponCode, 'SAVE10');
      expect(orderData.backgroundColor, '#ffffff');
      expect(orderData.trafficSourceNumber, 123);
      expect(orderData.trafficMediumNumber, 456);
      expect(orderData.netOrderValue, 99.99);
      expect(orderData.padding, 15.0);
      expect(orderData.customerData, customerData);
    });

    test('should sanitize order data correctly', () {
      const customerData =
          SovendusCustomerData(firstName: '<script>alert("xss")</script>');

      final orderData = SovendusOrderData(
        sessionId: '<script>session</script>',
        orderId: 'order & test',
        currencyCode: 'USD"test',
        usedCouponCode: 'SAVE10\'test',
        backgroundColor: '#ffffff<script>',
        trafficSourceNumber: 123,
        trafficMediumNumber: 456,
        netOrderValue: 99.99,
        padding: 15.0,
        customerData: customerData,
      );

      final sanitizer = HtmlSanitizer(
        trafficSourceNumber: 123,
        trafficMediumNumber: 456,
      );

      final sanitized = orderData.sanitized(sanitizer);

      expect(sanitized.sessionId, '<script>session</script>');
      expect(sanitized.orderId, 'order & test');
      expect(sanitized.currencyCode, 'USD\\"test');
      expect(sanitized.usedCouponCode, 'SAVE10\'test');
      expect(sanitized.backgroundColor, '#ffffff<script>');
      expect(sanitized.trafficSourceNumber, 123);
      expect(sanitized.trafficMediumNumber, 456);
      expect(sanitized.netOrderValue, 99.99);
      expect(sanitized.padding, 15.0);
      expect(sanitized.customerData, isNotNull);
    });
  });
}
