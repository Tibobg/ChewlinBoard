import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../user/success_page.dart';

class StripeCheckoutPage extends StatefulWidget {
  final String checkoutUrl;
  final String skateboardId;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String buyerAddress;
  final double price;
  final bool isProjectOrder;
  final String? projectId;
  final String? previewImageUrl;
  final DateTime? deliveryDate;

  const StripeCheckoutPage({
    super.key,
    required this.checkoutUrl,
    required this.skateboardId,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.buyerAddress,
    required this.price,
    this.isProjectOrder = false,
    this.projectId,
    this.previewImageUrl,
    this.deliveryDate,
  });

  static bool shouldGoToSuccess(String url) => url.contains('/success');
  @override
  State<StripeCheckoutPage> createState() => _StripeCheckoutPageState();
}

class _StripeCheckoutPageState extends State<StripeCheckoutPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                if (StripeCheckoutPage.shouldGoToSuccess(request.url)) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => SuccessPage(
                            skateboardId: widget.skateboardId,
                            buyerName: widget.buyerName,
                            buyerEmail: widget.buyerEmail,
                            buyerPhone: widget.buyerPhone,
                            buyerAddress: widget.buyerAddress,
                            price: widget.price,
                            isProjectOrder: widget.isProjectOrder,
                            projectId: widget.projectId,
                            previewImageUrl: widget.previewImageUrl,
                            deliveryDate: widget.deliveryDate,
                          ),
                    ),
                  );
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paiement sécurisé')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
