import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// version 1.0.3
class SovendusCustomerData {
  String? salutation;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  int? yearOfBirth;
  String? street;
  String? streetNumber;
  String? zipcode;
  String? city;
  String? country;

  SovendusCustomerData({
    this.salutation,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.yearOfBirth,
    this.street,
    this.streetNumber,
    this.zipcode,
    this.city,
    this.country,
  });
}

class SovendusBanner extends StatefulWidget {
  late final WebViewController? controller;
  late final double initialWebViewHeight;
  final Widget? customProgressIndicator;
  final bool isMobile = isMobileCheck();

  SovendusBanner({
    super.key,
    required int trafficSourceNumber,
    int? trafficMediumNumberVoucherNetwork,
    int? trafficMediumNumberCheckoutBenefits,
    required int orderUnixTime,
    required String sessionId,
    required String orderId,
    required double netOrderValue,
    required String currencyCode,
    required String usedCouponCode,
    SovendusCustomerData? customerData,
    this.customProgressIndicator,
  }) {
    if (isMobile) {
      String sovendusHtml = '''
        <!DOCTYPE html>
        <html>
            <head>
              <meta name="viewport" content="initial-scale=1" />
            </head>
            <body id="body">
                <div id="sovendus-voucher-banner"></div>
                <div id="sovendus-checkout-benefits-banner"></div>
                <script type="text/javascript">
                    const _body = document.getElementById("body");
                    new ResizeObserver(() => {
                        console.log("height" + _body.clientHeight)
                    }).observe(_body);
                    window.sovIframes = [];
                    if ("$trafficMediumNumberVoucherNetwork"){
                      window.sovIframes.push({
                          trafficSourceNumber: "$trafficSourceNumber",
                          trafficMediumNumber: "$trafficMediumNumberVoucherNetwork",
                          iframeContainerId: "sovendus-voucher-banner",
                          timestamp: "$orderUnixTime",
                          sessionId: "$sessionId",
                          orderId: "$orderId",
                          orderValue: "$netOrderValue",
                          orderCurrency: "$currencyCode",
                          usedCouponCode: "$usedCouponCode",
                          integrationType: "flutter-1.0.3"

                      });
                    }
                    if ("$trafficMediumNumberCheckoutBenefits"){
                      window.sovIframes.push({
                          trafficSourceNumber: "$trafficSourceNumber",
                          trafficMediumNumber: "$trafficMediumNumberCheckoutBenefits",
                          iframeContainerId: "sovendus-checkout-benefits-banner",
                          integrationType: "flutter-1.0.3"

                      });
                    }
                    window.sovConsumer = {
                        consumerSalutation: "${customerData?.salutation ?? ""}",
                        consumerFirstName: "${customerData?.firstName ?? ""}",
                        consumerLastName: "${customerData?.lastName ?? ""}",
                        consumerEmail: "${customerData?.email ?? ""}",
                        consumerPhone : "${customerData?.phone ?? ""}",   
                        consumerYearOfBirth  : "${customerData?.yearOfBirth ?? ""}",   
                        consumerStreet: "${customerData?.street ?? ""}",
                        consumerStreetNumber: "${customerData?.streetNumber ?? ""}",
                        consumerZipcode: "${customerData?.zipcode ?? ""}",
                        consumerCity: "${customerData?.city ?? ""}",
                        consumerCountry: "${customerData?.country ?? ""}",
                    };
                </script>
                <script type="text/javascript" src="https://api.sovendus.com/sovabo/common/js/flexibleIframe.js" async=true></script>
            </body>
        </html>
    ''';
      double _initialWebViewHeight = 0;
      if (trafficMediumNumberVoucherNetwork is int) {
        _initialWebViewHeight += 348;
      }
      if (trafficMediumNumberCheckoutBenefits is int) {
        _initialWebViewHeight += 500;
      }
      initialWebViewHeight = _initialWebViewHeight;
      WebViewController _controller = WebViewController();
      _controller.loadHtmlString(sovendusHtml);
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      _controller.enableZoom(false);
      _controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            Uri uri = Uri.parse(request.url);
            if (isNotBlacklistedUrl(uri)) {
              launchUrl(uri);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
      controller = _controller;
    }
  }

  static isNotBlacklistedUrl(Uri uri) {
    return uri.path != "/banner/api/banner" &&
        !uri.path.startsWith("/app-list/") &&
        uri.path != "blank";
  }

  @override
  State<SovendusBanner> createState() => _SovendusBanner();

  static bool isMobileCheck() {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isIOS || Platform.isAndroid;
    }
  }
}

class _SovendusBanner extends State<SovendusBanner> {
  double webViewHeight = 0;
  bool loadingDone = false;
  late final WebViewWidget webViewWidget;

  @override
  void initState() {
    if (widget.isMobile) {
      widget.controller?.setOnConsoleMessage(
        (JavaScriptConsoleMessage message) {
          updateHeight(message.message);
        },
      );
      webViewWidget = WebViewWidget(
        controller: widget.controller ?? WebViewController(),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMobile) {
      double widgetHeight = webViewHeight;
      if (webViewHeight < 20) {
        widgetHeight = widget.initialWebViewHeight;
      }
      return SizedBox(
        height: widgetHeight,
        child: loadingDone
            ? webViewWidget
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    widget.customProgressIndicator ??
                        const CircularProgressIndicator()
                  ]),
      );
    }
    return const SizedBox.shrink();
  }

  void updateHeight(String consoleMessage) async {
    if (consoleMessage.startsWith("height")) {
      double height = double.parse(consoleMessage.replaceAll("height", ""));
      if (webViewHeight != height && height > 20) {
        setState(() {
          webViewHeight = height;
          loadingDone = true;
        });
      }
    }
  }
}
