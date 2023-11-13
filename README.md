# Integrate Sovendus Checkout Benefits and Voucher Network into Flutter App

## Add a inline WebView on your success page
1. Create a WebView from the following string and place it inline on your success page, where you want the sovendus banner to appear. Replace SOVENDUS_TRAFFIC_SOURCE_NUMBER, SOVENDUS_VOUCHER_NETWORK_TRAFFIC_MEDIUM_NUMBER and SOVENDUS_CHECKOUT_BENEFITS_TRAFFIC_MEDIUM_NUMBER with the ones we provided you. 
```
const String sovendusHtml = '''
    <!DOCTYPE html>
    <html>
        <head>
        </head>
        <body>
            <div id="sovendus-voucher-banner"></div>
            <div id="sovendus-checkout-benefits-banner"></div>
            <script>
                window.sovIframes = [];
                window.sovIframes.push({
                    trafficSourceNumber: SOVENDUS_TRAFFIC_SOURCE_NUMBER,
                    trafficMediumNumber: SOVENDUS_VOUCHER_NETWORK_TRAFFIC_MEDIUM_NUMBER,
                    iframeContainerId: 'sovendus-voucher-banner',
                    timestamp: $orderUnixTime,
                    sessionId: $sessionId,
                    orderId: $orderId,
                    orderValue: $netOrderValue,
                    orderCurrency: $currencyCode,
                    usedCouponCode: $usedCouponCode
                });
                window.sovIframes.push({
                    trafficSourceNumber: SOVENDUS_TRAFFIC_SOURCE_NUMBER,
                    trafficMediumNumber: SOVENDUS_CHECKOUT_BENEFITS_TRAFFIC_MEDIUM_NUMBER,
                    iframeContainerId: 'sovendus-checkout-benefits-banner',
                });
                window.sovConsumer = {
                    consumerSalutation: $customerSalutation,
                    consumerFirstName: $customerFirstName,
                    consumerLastName: $customerLastName,
                    consumerEmail: $customerEmail,
                    consumerPhone : $customerPhone,   
                    consumerYearOfBirth  : $customerYearOfBirth',   
                    consumerStreet: $customerStreet,
                    consumerStreetNumber: $customerStreetNumber,
                    consumerZipcode: $customerZipcode,
                    consumerCity: $customerCity,
                    consumerCountry: $customerCountry,
                };
            </script>
            <script type="text/javascript" src="https://api.sovendus.com/sovabo/common/js/flexibleIframe.js" async=true></script>
        </body>
    </html>
'''
```

2. Also make sure to define all variables used in the HTML string

## Catch clicks on external links and open them in the native browser
1. Every click on external links will fire a javascript custom event. Make sure to catch the event and open the links with the default browser. The custom event looks like this:
```
Event Name: 'openInNativeBrowser'
Event Payload: {
      bubbles: true,
      composed: true,
      cancelable: false,
      detail: {
        url: "https://example.url/something",
      },
  }

```