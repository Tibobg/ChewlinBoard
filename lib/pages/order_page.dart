import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';
import 'stripe_checkout_page.dart';

class OrderPage extends StatefulWidget {
  final Map<String, dynamic> skateboard;
  const OrderPage({super.key, required this.skateboard});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final nameController = TextEditingController();
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final zipController = TextEditingController();
  final cityController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.email != null) {
      emailController.text = currentUser.email!;
    }
  }

  Future<void> _createStripeSession() async {
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final zip = zipController.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("L'email n'est pas valide.")),
      );
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le numéro de téléphone doit comporter 10 chiffres."),
        ),
      );
      return;
    }

    if (!RegExp(r'^\d{5}$').hasMatch(zip) ||
        int.tryParse(zip.substring(0, 2)) == null ||
        int.parse(zip.substring(0, 2)) > 98) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le code postal ne semble pas valide pour la France."),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final uri = Uri.parse(
      'https://europe-west1-chewlinboard-7a16f.cloudfunctions.net/createStripeSession',
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'skateboardId': widget.skateboard['id'],
        'imageUrl': widget.skateboard['imageUrl'],
        'price': widget.skateboard['price'],
        'buyerName': '${firstNameController.text} ${nameController.text}',
        'email': email,
        'phone': phone,
        'address':
            '${addressController.text}, ${zipController.text} ${cityController.text}',
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final url = jsonDecode(response.body)['checkoutUrl'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => StripeCheckoutPage(
                checkoutUrl: url,
                skateboardId: widget.skateboard['id'],
                buyerName: '${firstNameController.text} ${nameController.text}',
                buyerEmail: emailController.text,
                buyerPhone: phoneController.text,
                buyerAddress:
                    '${addressController.text}, ${zipController.text} ${cityController.text}',
                price: double.parse(
                  widget.skateboard['price']
                      .toString()
                      .replaceAll('€', '')
                      .trim(),
                ),
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la création de la session de paiement"),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.beige),
      filled: true,
      fillColor: AppColors.black,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.skateboard;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.beige,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Finaliser la commande",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.beige,
                              fontFamily: 'ReginaBlack',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: board['imageUrl'],
                        height: 400,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Prix : ${board['price']}",
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.beige,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: AppColors.beige),
                          decoration: _inputDecoration('Nom'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: firstNameController,
                          style: const TextStyle(color: AppColors.beige),
                          decoration: _inputDecoration('Prénom'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: AppColors.beige),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration('Email'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: phoneController,
                          style: const TextStyle(color: AppColors.beige),
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration('Téléphone'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: addressController,
                          style: const TextStyle(color: AppColors.beige),
                          decoration: _inputDecoration('Adresse (n° et rue)'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: zipController,
                          style: const TextStyle(color: AppColors.beige),
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Code postal'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: cityController,
                          style: const TextStyle(color: AppColors.beige),
                          decoration: _inputDecoration('Ville'),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _createStripeSession,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
