import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/order_service.dart';

class SuccessPage extends StatefulWidget {
  final String skateboardId;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String buyerAddress;
  final double price;

  const SuccessPage({
    super.key,
    required this.skateboardId,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.buyerAddress,
    required this.price,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
    _saveOrder();
  }

  Future<void> _saveOrder() async {
    await OrderService.saveOrder(
      skateboardId: widget.skateboardId,
      buyerName: widget.buyerName,
      buyerEmail: widget.buyerEmail,
      buyerPhone: widget.buyerPhone,
      buyerAddress: widget.buyerAddress,
      price: widget.price,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 100,
                color: AppColors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Commande confirmée !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.beige,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Merci pour votre achat. Voici le récapitulatif de votre commande :',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildSummaryRow('Nom', widget.buyerName),
              _buildSummaryRow('Email', widget.buyerEmail),
              _buildSummaryRow('Téléphone', widget.buyerPhone),
              _buildSummaryRow('Adresse', widget.buyerAddress),
              _buildSummaryRow('Prix', '${widget.price.toStringAsFixed(2)} €'),
              const SizedBox(height: 36),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Retour à l’accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(
              color: AppColors.beige,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
