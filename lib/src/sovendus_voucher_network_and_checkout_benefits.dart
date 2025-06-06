import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SovendusCustomerData {
  const SovendusCustomerData({
    this.salutation,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.yearOfBirth,
    this.dateOfBirth,
    this.street,
    this.streetNumber,
    this.zipcode,
    this.city,
    this.country,
  });

  final String? salutation;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final int? yearOfBirth;
  final String? dateOfBirth;
  final String? street;
  final String? streetNumber;
  final String? zipcode;
  final String? city;
  final String? country;

  SovendusCustomerData sanitized(
      {Function(String errorMessage, dynamic error)? onError,
      int? trafficSourceNumber,
      int? trafficMediumNumber}) {
    try {
      final sanitizer = HtmlSanitizer(
        trafficSourceNumber: trafficSourceNumber ?? 0,
        trafficMediumNumber: trafficMediumNumber ?? 0,
        onError: onError,
      );

      return SovendusCustomerData(
        salutation: sanitizer.sanitizeNullable(salutation),
        firstName: sanitizer.sanitizeNullable(firstName),
        lastName: sanitizer.sanitizeNullable(lastName),
        email: sanitizer.sanitizeNullable(email),
        phone: sanitizer.sanitizeNullable(phone),
        yearOfBirth:
            yearOfBirth, // Note: yearOfBirth will be sanitized when used in HTML generation
        dateOfBirth: sanitizer.sanitizeNullable(dateOfBirth),
        street: sanitizer.sanitizeNullable(street),
        streetNumber: sanitizer.sanitizeNullable(streetNumber),
        zipcode: sanitizer.sanitizeNullable(zipcode),
        city: sanitizer.sanitizeNullable(city),
        country: sanitizer.sanitizeNullable(country),
      );
    } catch (e) {
      SovendusBanner.reportError(
        'Error sanitizing customer data',
        e,
        onError: onError,
        type: 'sanitization-error',
        trafficSourceNumber: trafficSourceNumber,
        trafficMediumNumber: trafficMediumNumber,
      );
      // Return empty customer data as fallback
      return const SovendusCustomerData();
    }
  }
}

class SovendusOrderData {
  final String sessionId;
  final String orderId;
  final String currencyCode;
  final String usedCouponCode;
  final String backgroundColor;
  final int trafficSourceNumber;
  final int trafficMediumNumber;
  final int orderUnixTime;
  final double netOrderValue;
  final double padding;
  final SovendusCustomerData? customerData;

  const SovendusOrderData({
    required this.sessionId,
    required this.orderId,
    required this.currencyCode,
    required this.usedCouponCode,
    required this.backgroundColor,
    required this.trafficSourceNumber,
    required this.trafficMediumNumber,
    required this.orderUnixTime,
    required this.netOrderValue,
    required this.padding,
    this.customerData,
  });

  SovendusOrderData sanitized(HtmlSanitizer sanitizer) {
    return SovendusOrderData(
      sessionId: sanitizer.sanitize(sessionId),
      orderId: sanitizer.sanitize(orderId),
      currencyCode: sanitizer.sanitize(currencyCode),
      usedCouponCode: sanitizer.sanitize(usedCouponCode),
      backgroundColor: sanitizer.sanitize(backgroundColor),
      trafficSourceNumber:
          int.tryParse(sanitizer.sanitizeInt(trafficSourceNumber)) ?? 0,
      trafficMediumNumber:
          int.tryParse(sanitizer.sanitizeInt(trafficMediumNumber)) ?? 0,
      orderUnixTime: int.tryParse(sanitizer.sanitizeInt(orderUnixTime)) ?? 0,
      netOrderValue:
          double.tryParse(sanitizer.sanitizeDouble(netOrderValue)) ?? 0.0,
      padding: double.tryParse(sanitizer.sanitizeDouble(padding)) ?? 0.0,
      customerData: customerData?.sanitized(
        onError: sanitizer.onError,
        trafficSourceNumber: trafficSourceNumber,
        trafficMediumNumber: trafficMediumNumber,
      ),
    );
  }
}

class SovendusBanner extends StatefulWidget {
  SovendusBanner({
    super.key,
    required this.trafficSourceNumber,
    required this.trafficMediumNumber,
    this.orderUnixTime = 0,
    this.sessionId = "",
    this.orderId = "",
    this.netOrderValue = 0,
    this.currencyCode = "",
    this.usedCouponCode = "",
    this.customerData,
    this.customProgressIndicator,
    this.padding = 0,
    this.backgroundColor = "#fff",
    this.disableAndroidWaitingForCheckoutBenefits = false,
    this.onError,
  });

  final int trafficSourceNumber;
  final int trafficMediumNumber;
  final int orderUnixTime;
  final String sessionId;
  final String orderId;
  final double netOrderValue;
  final String currencyCode;
  final String usedCouponCode;
  final SovendusCustomerData? customerData;
  final Widget? customProgressIndicator;
  final double padding;
  final String backgroundColor;
  final bool disableAndroidWaitingForCheckoutBenefits;
  final Function(String errorMessage, dynamic error)? onError;

  // update with component version number
  static const String versionNumber = "1.3.0";

  String generateHtml() {
    if (!isMobileCheck) return '';

    try {
      final sanitizer = HtmlSanitizer(
        trafficSourceNumber: trafficSourceNumber,
        trafficMediumNumber: trafficMediumNumber,
        onError: onError,
      );

      final orderData = _createOrderData().sanitized(sanitizer);
      final consumerJson = _createConsumerJson(orderData, sanitizer);
      final resizeObserver = _createResizeObserver();
      final paddingString = "${orderData.padding}px";

      return _buildHtmlTemplate(
          orderData, consumerJson, resizeObserver, paddingString);
    } catch (e) {
      reportError(
        'Error generating Sovendus HTML',
        e,
        onError: onError,
        type: 'html-generation-error',
        trafficSourceNumber: trafficSourceNumber,
        trafficMediumNumber: trafficMediumNumber,
      );
      return '';
    }
  }

  SovendusOrderData _createOrderData() {
    return SovendusOrderData(
      sessionId: sessionId,
      orderId: orderId,
      currencyCode: currencyCode,
      usedCouponCode: usedCouponCode,
      backgroundColor: backgroundColor,
      trafficSourceNumber: trafficSourceNumber,
      trafficMediumNumber: trafficMediumNumber,
      orderUnixTime: orderUnixTime,
      netOrderValue: netOrderValue,
      padding: padding,
      customerData: customerData,
    );
  }

  /// consumer JSON with fallback
  String _createConsumerJson(
      SovendusOrderData orderData, HtmlSanitizer sanitizer) {
    try {
      final customerData =
          orderData.customerData ?? const SovendusCustomerData();
      final consumerMap = {
        'consumerSalutation': customerData.salutation ?? "",
        'consumerFirstName': customerData.firstName ?? "",
        'consumerLastName': customerData.lastName ?? "",
        'consumerEmail': customerData.email ?? "",
        'consumerPhone': customerData.phone ?? "",
        'consumerYearOfBirth':
            sanitizer.sanitizeIntNullable(customerData.yearOfBirth) ?? "",
        'consumerDateOfBirth': customerData.dateOfBirth ?? "",
        'consumerStreet': customerData.street ?? "",
        'consumerStreetNumber': customerData.streetNumber ?? "",
        'consumerZipcode': customerData.zipcode ?? "",
        'consumerCity': customerData.city ?? "",
        'consumerCountry': customerData.country ?? "",
      };
      return jsonEncode(consumerMap);
    } catch (e) {
      reportError(
        'Error creating consumer JSON',
        e,
        onError: onError,
        type: 'consumer-json-creation-error',
        trafficSourceNumber: trafficSourceNumber,
        trafficMediumNumber: trafficMediumNumber,
      );
      return '{}';
    }
  }

  String _createResizeObserver() {
    return Platform.isAndroid && !disableAndroidWaitingForCheckoutBenefits
        ? '''
        const interval = 250;
        const totalDuration = 5000;
        const maxChecks = totalDuration / interval;

        let checkCount = 0;
        let intervalCheckDone = false;
        const checkInterval = setInterval(() => {
          checkCount++;
          if (document.body.scrollHeight > 800 || checkCount >= maxChecks) {
            clearInterval(checkInterval);
            intervalCheckDone = true;
            window.flutter_inappwebview.callHandler('sovHandler', {
              type: 'height',
              value: document.body.scrollHeight
            });
          }
        }, interval);
        new ResizeObserver(() => {
          if (intervalCheckDone) {
            window.flutter_inappwebview.callHandler('sovHandler', {
              type: 'height',
              value: document.body.scrollHeight
            });
          }
        }).observe(document.body);
        '''
        : '''
        new ResizeObserver(() => {
          window.flutter_inappwebview.callHandler('sovHandler', {
            type: 'height',
            value: document.body.scrollHeight
          });
        }).observe(document.body);
        ''';
  }

  String _buildHtmlTemplate(SovendusOrderData orderData, String consumerJson,
      String resizeObserver, String paddingString) {
    return '''
      <!DOCTYPE html>
      <html>
          <head>
            <meta name="viewport" content="initial-scale=1" />
          </head>
          <body id="body" style="padding-bottom: 0; margin: 0; padding-top: $paddingString; padding-left: $paddingString; padding-right: $paddingString; background-color: ${orderData.backgroundColor}">
              <div id="sovendus-voucher-banner"></div>
              <script type="text/javascript">
                  $resizeObserver
                  window.sovApi = "v1";
                  window.addEventListener("message", (event) => {
                    if (event.data.channel === "sovendus:integration") {
                      window.flutter_inappwebview.callHandler('sovHandler', {
                        type: 'openUrl',
                        value: event.data.payload.url
                      });
                    }
                  });
                  window.sovIframes = [];
                  window.sovIframes.push({
                      trafficSourceNumber: "${orderData.trafficSourceNumber}",
                      trafficMediumNumber: "${orderData.trafficMediumNumber}",
                      iframeContainerId: "sovendus-voucher-banner",
                      timestamp: "${orderData.orderUnixTime}",
                      sessionId: "${orderData.sessionId}",
                      orderId: "${orderData.orderId}",
                      orderValue: "${orderData.netOrderValue}",
                      orderCurrency: "${orderData.currencyCode}",
                      usedCouponCode: "${orderData.usedCouponCode}",
                      integrationType: "flutter-$versionNumber",
                  });
                  window.sovConsumer = $consumerJson;
              </script>
              <script type="text/javascript" src="https://api.sovendus.com/sovabo/common/js/flexibleIframe.js" async=true></script>
          </body>
      </html>
    ''';
  }

  static double initialWebViewHeight = 348.0;

  String get sovendusHtml => generateHtml();

  static String errorApi = 'https://press-tracking-api.sovendus.com/error';
  static int errorCounter = 0;

  static bool isNotBlacklistedUrl(Uri uri) {
    return uri.path != '/banner/api/banner' &&
        !uri.path.startsWith('/app-list') &&
        uri.path != 'blank';
  }

  static Future<void> reportError(
    String errorMessage,
    dynamic error, {
    required Function(String errorMessage, dynamic error)? onError,
    required String type,
    int? trafficSourceNumber,
    int? trafficMediumNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      errorCounter++;
      if (errorCounter > 3) return;

      final errorData = {
        'source': 'flutter-$type',
        'type': 'exception',
        'message': errorMessage,
        'counter': errorCounter,
        'trafficSource': trafficSourceNumber ?? "not_defined",
        'trafficMedium': trafficMediumNumber ?? "not_defined",
        'additionalData': jsonEncode({
          'error': error.toString(),
          "appName": "flutter-script-$versionNumber",
          ...?additionalData,
        }),
        'implementationType': 'flutter-$versionNumber',
      };
      await http.post(
        Uri.parse(errorApi),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(errorData),
      );
    } catch (apiError) {
      onError?.call("Failed to report error to API: $apiError", error);
    }
    onError?.call(errorMessage, error);
  }

  @override
  State<SovendusBanner> createState() => _SovendusBanner();
  static bool get isMobileCheck {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isIOS || Platform.isAndroid;
    }
  }
}

class _SovendusBanner extends State<SovendusBanner> {
  double webViewHeight = 0;
  bool doneLoading = false;
  late final InAppWebView webViewWidget;

  @override
  void initState() {
    if (SovendusBanner.isMobileCheck) {
      webViewHeight = SovendusBanner.initialWebViewHeight;
      webViewWidget = InAppWebView(
        initialData: InAppWebViewInitialData(data: widget.sovendusHtml),
        initialSettings: InAppWebViewSettings(
          allowsInlineMediaPlayback: true,
          textZoom: 100,
          mediaPlaybackRequiresUserGesture: false,
          // To prevent links from opening in external browser.
          useShouldOverrideUrlLoading: true,
          supportZoom: false,
        ),
        onWebViewCreated: (controller) {
          controller.addJavaScriptHandler(
            handlerName: 'sovHandler',
            callback: (args) {
              handleJsMessage(args.first);
            },
          );
        },
        onConsoleMessage: (controller, consoleMessage) {
          // Any console message indicates unexpected behavior and should be reported
          SovendusBanner.reportError(
            'Unexpected console message received',
            'Level: ${consoleMessage.messageLevel}, Message: ${consoleMessage.message}',
            onError: widget.onError,
            type: 'console-message-error',
            trafficSourceNumber: widget.trafficSourceNumber,
            trafficMediumNumber: widget.trafficMediumNumber,
          );
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          if (navigationAction.request.url != null &&
              SovendusBanner.isNotBlacklistedUrl(
                navigationAction.request.url!,
              )) {
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (SovendusBanner.isMobileCheck) {
      return SizedBox(
        height: webViewHeight,
        child: Column(
          children: [
            SizedBox(
              // using a pixel intentionally as webview wont load with 0px
              height: doneLoading ? webViewHeight : 1,
              child: webViewWidget,
            ),
            ...doneLoading
                ? []
                : [
                    SizedBox(
                      height: webViewHeight - 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          widget.customProgressIndicator ??
                              const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ],
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void handleJsMessage(dynamic message) {
    try {
      if (message is! Map<String, dynamic>) {
        throw Exception(
            'Invalid JS message format: expected Map<String, dynamic>, got ${message.runtimeType}');
      }

      final type = message['type'];
      final value = message['value'];

      switch (type) {
        case 'height':
          updateHeight(value);
          break;
        case 'openUrl':
          openUrlInNativeBrowser(value);
          break;
        default:
          throw Exception('Unknown JS message type: $type');
      }
    } catch (e) {
      SovendusBanner.reportError(
        'Error processing JS message',
        e,
        onError: widget.onError,
        type: 'message-handling-error',
        trafficSourceNumber: widget.trafficSourceNumber,
        trafficMediumNumber: widget.trafficMediumNumber,
      );
    }
  }

  Future<void> openUrlInNativeBrowser(dynamic urlValue) async {
    try {
      final urlString = urlValue?.toString() ?? '';

      if (urlString.isEmpty) {
        throw Exception('Empty URL provided for opening');
      }

      final url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      } else {
        throw Exception('Cannot launch URL: $urlString');
      }
    } catch (e) {
      SovendusBanner.reportError(
        'Error launching URL',
        e,
        onError: widget.onError,
        type: 'url-launch-error',
        trafficSourceNumber: widget.trafficSourceNumber,
        trafficMediumNumber: widget.trafficMediumNumber,
      );
    }
  }

  void updateHeight(dynamic heightValue) {
    try {
      double? height;

      if (heightValue is num) {
        height = heightValue.toDouble();
      } else if (heightValue is String) {
        height = double.tryParse(heightValue);
      }

      if (height == null) {
        throw Exception(
            'Could not parse height: $heightValue (${heightValue.runtimeType})');
      }

      if (webViewHeight != height && height > 100) {
        setState(() {
          webViewHeight = height!;
          doneLoading = true;
        });
      }
    } catch (e) {
      SovendusBanner.reportError(
        'Error updating height',
        e,
        onError: widget.onError,
        type: 'height-update-error',
        trafficSourceNumber: widget.trafficSourceNumber,
        trafficMediumNumber: widget.trafficMediumNumber,
      );
    }
  }
}

class HtmlSanitizer {
  final int trafficSourceNumber;
  final int trafficMediumNumber;
  final Function(String errorMessage, dynamic error)? onError;

  HtmlSanitizer({
    required this.trafficSourceNumber,
    required this.trafficMediumNumber,
    this.onError,
  });

  String sanitize(String input) {
    try {
      // jsonEncode returns a string with quotes around it (e.g. "value")
      return jsonEncode(input).substring(1, jsonEncode(input).length - 1);
    } catch (e) {
      SovendusBanner.reportError(
        'Error sanitizing string input',
        e,
        onError: onError,
        type: 'sanitization-error',
        trafficSourceNumber: trafficSourceNumber,
        trafficMediumNumber: trafficMediumNumber,
      );
      // Return empty string as fallback
      return '';
    }
  }

  String? sanitizeNullable(String? input) {
    return input != null ? sanitize(input) : null;
  }

  String sanitizeInt(int input) {
    try {
      // Ensure the int is properly formatted and safe for HTML/JS injection
      return input.toString();
    } catch (e) {
      SovendusBanner.reportError(
        'Error sanitizing int input: $input',
        e,
        onError: onError,
        type: 'sanitization-error',
        trafficSourceNumber: trafficSourceNumber,
        trafficMediumNumber: trafficMediumNumber,
      );
      // Return '0' as fallback
      return '0';
    }
  }

  String? sanitizeIntNullable(int? input) {
    return input != null ? sanitizeInt(input) : null;
  }

  String sanitizeDouble(double input) {
    try {
      // Ensure the double is properly formatted and safe for HTML/JS injection
      // Handle special cases like NaN, infinity
      if (input.isNaN) return '0';
      if (input.isInfinite) return '0';
      return input.toString();
    } catch (e) {
      SovendusBanner.reportError(
        'Error sanitizing double input: $input',
        e,
        onError: onError,
        type: 'sanitization-error',
        trafficSourceNumber: trafficSourceNumber,
        trafficMediumNumber: trafficMediumNumber,
      );
      // Return '0' as fallback
      return '0';
    }
  }

  String? sanitizeDoubleNullable(double? input) {
    return input != null ? sanitizeDouble(input) : null;
  }
}
