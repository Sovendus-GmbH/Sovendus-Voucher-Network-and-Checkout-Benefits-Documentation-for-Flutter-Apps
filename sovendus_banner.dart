import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

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
  // const SovendusBanner({Key? key}) : super(key: key);
  late final double initialWebViewHeight;
  late final String sovendusHtml;

  final Widget? customProgressIndicator;

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
    if (isMobile()) {
      sovendusHtml = '''
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
                          usedCouponCode: "$usedCouponCode"
                      });
                    }
                    if ("$trafficMediumNumberCheckoutBenefits"){
                      window.sovIframes.push({
                          trafficSourceNumber: "$trafficSourceNumber",
                          trafficMediumNumber: "$trafficMediumNumberCheckoutBenefits",
                          iframeContainerId: "sovendus-checkout-benefits-banner",
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
    }
  }

  static isMobile() {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isIOS || Platform.isAndroid;
    }
  }

  @override
  State<SovendusBanner> createState() => _SovendusBanner();
}

class _SovendusBanner extends State<SovendusBanner> {
  final GlobalKey webViewKey = GlobalKey();
  double webViewHeight = 0;
  bool loadingDone = false;

  @override
  Widget build(BuildContext context) {
    if (SovendusBanner.isMobile()) {
      double finalWebViewHeight = webViewHeight;
      if (webViewHeight < 20) {
        finalWebViewHeight = widget.initialWebViewHeight;
      }
      return SizedBox(
          height: finalWebViewHeight,
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(
              url: Uri.dataFromString(widget.sovendusHtml,
                  mimeType: 'text/html', encoding: Encoding.getByName("utf-8")),
            ),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    useOnLoadResource: true,
                    supportZoom: false,
                    mediaPlaybackRequiresUserGesture: false),
                ios: IOSInAppWebViewOptions(
                  allowsInlineMediaPlayback: true,
                  isPagingEnabled: true,
                )),
            onConsoleMessage: (controller, consoleMessage) {
              updateHeight(consoleMessage.message);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var uri = navigationAction.request.url!;
              if (await canLaunchUrl(uri) && isNotBlacklistedUrl(uri)) {
                await launchUrl(
                  uri,
                );
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
          ));
    }
    return const SizedBox.shrink();
  }

  void updateHeight(String windowHeight) async {
    if (windowHeight.startsWith("height")) {
      double height = double.parse(windowHeight.replaceAll("height", ""));
      if (webViewHeight != height && height > 20) {
        setState(() {
          webViewHeight = height;
          loadingDone = true;
        });
      }
    }
  }

  static isNotBlacklistedUrl(Uri uri) {
    return uri.path != "/banner/api/banner" &&
        !uri.path.startsWith("/app-list/");
  }
}
