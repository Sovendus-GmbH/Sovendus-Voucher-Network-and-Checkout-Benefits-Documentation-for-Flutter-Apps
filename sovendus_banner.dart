import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SovendusBanner extends StatefulWidget {
  // Version 1.0.0
  late final WebViewController _controller;

  SovendusBanner({
    key,
    required int trafficSourceNumber,
    int? trafficMediumNumberVoucherNetwork,
    int? trafficMediumNumberCheckoutBenefits,
    required int orderUnixTime,
    required String sessionId,
    required String orderId,
    required double netOrderValue,
    required String currencyCode,
    required String usedCouponCode,
    String? customerSalutation,
    String? customerFirstName,
    String? customerLastName,
    String? customerEmail,
    String? customerPhone,
    int? customerYearOfBirth,
    String? customerStreet,
    String? customerStreetNumber,
    String? customerZipcode,
    String? customerCity,
    String? customerCountry,
  }) {
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
                        consumerSalutation: "$customerSalutation",
                        consumerFirstName: "$customerFirstName",
                        consumerLastName: "$customerLastName",
                        consumerEmail: "$customerEmail",
                        consumerPhone : "$customerPhone",   
                        consumerYearOfBirth  : "$customerYearOfBirth",   
                        consumerStreet: "$customerStreet",
                        consumerStreetNumber: "$customerStreetNumber",
                        consumerZipcode: "$customerZipcode",
                        consumerCity: "$customerCity",
                        consumerCountry: "$customerCountry",
                    };
                </script>
                <script type="text/javascript" src="https://api.sovendus.com/sovabo/common/js/flexibleIframe.js" async=true></script>
            </body>
        </html>
    ''';

    final WebViewController controller = WebViewController();
    controller.loadHtmlString(sovendusHtml);
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.enableZoom(false);
    controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          launchUrl(
            Uri.parse(request.url),
          );
          return NavigationDecision.prevent;
        },
      ),
    );
    _controller = controller;
  }

  @override
  State<SovendusBanner> createState() => _SovendusBanner();
}

class _SovendusBanner extends State<SovendusBanner> {
  double webViewHeight = 1;

  @override
  Widget build(BuildContext context) {
    widget._controller.setOnConsoleMessage(
      (JavaScriptConsoleMessage message) {
        updateHeight(message.message);
      },
    );
    return SizedBox(
      height: webViewHeight,
      child: WebViewWidget(
        controller: widget._controller,
      ),
    );
  }

  void updateHeight(String windowHeight) async {
    if (windowHeight.startsWith("height")) {
      double height = double.parse(windowHeight.replaceAll("height", ""));
      if (webViewHeight != height) {
        setState(() {
          webViewHeight = height;
        });
      }
    }
  }
}
