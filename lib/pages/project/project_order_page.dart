import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../theme/colors.dart';
import '../../models/project_data.dart';
import '../checkout/stripe_checkout_page.dart';

class ProjectOrderPage extends StatefulWidget {
  final ProjectData projectData;
  final DateTime deliveryDate;

  const ProjectOrderPage({
    Key? key,
    required this.projectData,
    required this.deliveryDate,
  }) : super(key: key);

  @override
  State<ProjectOrderPage> createState() => _ProjectOrderPageState();
}

class _ProjectOrderPageState extends State<ProjectOrderPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();

  bool isLoading = false;

  double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9.,]'), '');
      return double.tryParse(cleaned.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  Future<void> _createStripeSession() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    final price = _parsePrice(widget.projectData.boardPrice);
    final imageUrl = widget.projectData.imagePaths?.first ?? '';

    setState(() => isLoading = true);

    try {
      final uri = Uri.parse(
        'https://europe-west1-chewlinboard-7a16f.cloudfunctions.net/createStripeSession',
      );

      final body = jsonEncode({
        'skateboardId': widget.projectData.projectId ?? 'customProject',
        'imageUrl': imageUrl,
        'price': price,
        'buyerName':
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address':
            '${_addressController.text.trim()}, ${_postalCodeController.text.trim()} ${_cityController.text.trim()}',
      });

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (!mounted) return;

      if (resp.statusCode == 200) {
        final checkoutUrl =
            (jsonDecode(resp.body)['checkoutUrl'] as String?) ?? '';
        if (checkoutUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("URL de paiement manquante.")),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => StripeCheckoutPage(
                  checkoutUrl: checkoutUrl,
                  skateboardId: widget.projectData.projectId ?? '',
                  buyerName:
                      "${_firstNameController.text} ${_lastNameController.text}",
                  buyerEmail: _emailController.text,
                  buyerPhone: _phoneController.text,
                  buyerAddress:
                      "${_addressController.text}, ${_postalCodeController.text} ${_cityController.text}",
                  price: _parsePrice(widget.projectData.boardPrice),
                  isProjectOrder: true,
                  projectId: widget.projectData.projectId ?? '',
                  deliveryDate: widget.deliveryDate,
                ),
          ),
        );
      } else {
        debugPrint('Erreur Stripe (${resp.statusCode}) : ${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de la création du paiement."),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur réseau Stripe: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur réseau: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.projectData.imagePaths?.first ?? '';
    final price = _parsePrice(widget.projectData.boardPrice);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text(
          "Finaliser la commande",
          style: TextStyle(color: AppColors.beige),
        ),
        iconTheme: const IconThemeData(color: AppColors.beige),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + prix + livraison
              Container(
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(imageUrl, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      "${price.toStringAsFixed(2)} €",
                      style: const TextStyle(
                        color: AppColors.beige,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Livraison prévue le : ${widget.deliveryDate.day}/${widget.deliveryDate.month}/${widget.deliveryDate.year}",
                      style: const TextStyle(
                        color: AppColors.beige,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Formulaire
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_firstNameController, "Prénom"),
                    _buildTextField(_lastNameController, "Nom"),
                    _buildTextField(
                      _emailController,
                      "Email",
                      type: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      _phoneController,
                      "Téléphone",
                      type: TextInputType.phone,
                    ),
                    _buildTextField(_addressController, "Adresse"),
                    _buildTextField(
                      _postalCodeController,
                      "Code postal",
                      type: TextInputType.number,
                    ),
                    _buildTextField(_cityController, "Ville"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bouton payer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _createStripeSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(
                            color: AppColors.beige,
                          )
                          : const Text(
                            "Payer avec Stripe",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.beige,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: AppColors.beige),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.beige),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.green),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.green, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Veuillez entrer $label';
          }
          return null;
        },
      ),
    );
  }
}
