import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/colors.dart';
import '../../services/order_service.dart';
import '../../navigation/bottom_nav_container.dart';

class SuccessPage extends StatefulWidget {
  final String skateboardId;
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String buyerAddress;
  final double price;

  // 🔽 Spécifique “projet personnalisé”
  final bool isProjectOrder;
  final String? projectId;
  final DateTime? deliveryDate;

  const SuccessPage({
    super.key,
    required this.skateboardId,
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.buyerAddress,
    required this.price,
    this.isProjectOrder = false,
    this.projectId,
    this.deliveryDate,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
    _handleAfterPayment();
  }

  Future<void> _handleAfterPayment() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (widget.isProjectOrder) {
      // ✅ Cas commande de projet personnalisé
      await _finalizeProjectOrder(currentUser.uid);
    } else {
      // 🛒 Cas achat d’une planche de la galerie
      await OrderService.saveOrder(
        skateboardId: widget.skateboardId,
        buyerName: widget.buyerName,
        buyerEmail: widget.buyerEmail,
        buyerPhone: widget.buyerPhone,
        buyerAddress: widget.buyerAddress,
        price: widget.price,
      );
    }

    await _sendConfirmationMessage(currentUser.uid);
  }

  Future<void> _finalizeProjectOrder(String userId) async {
    try {
      // 1) Marquer le projet comme “payé” + enregistrer la date de livraison
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(widget.projectId)
            .set({
              'userId': userId,
              'isPaid': true,
              'isDraft': false,
              if (widget.deliveryDate != null)
                'deliveryDate': widget.deliveryDate!.toIso8601String(),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } else {
        debugPrint(
          '⚠️ projectId manquant : impossible de mettre à jour le projet.',
        );
      }

      // 2) Ajouter l’évènement Google Agenda (21 jours AVANT la date choisie sont bloqués côté backend)
      if (widget.deliveryDate != null) {
        await _addGoogleCalendarEvent(widget.deliveryDate!, widget.buyerName);
      } else {
        debugPrint('⚠️ deliveryDate manquante : pas d’ajout au Google Agenda.');
      }
    } catch (e) {
      debugPrint('❌ Erreur finalizeProjectOrder: $e');
    }
  }

  Future<void> _addGoogleCalendarEvent(
    DateTime deliveryDate,
    String username,
  ) async {
    try {
      final url = Uri.parse(
        // Ta fonction déjà en prod
        'https://europe-west1-chewlinboard-7a16f.cloudfunctions.net/addAgendaEvent',
      );
      final body = {
        'startDate': deliveryDate.toIso8601String(),
        'username': username,
      };

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) {
        debugPrint('❌ Échec ajout agenda : ${res.body}');
      } else {
        debugPrint('✅ Évènement Google Agenda ajouté');
      }
    } catch (e) {
      debugPrint('❌ Erreur interne ajout agenda : $e');
    }
  }

  Future<void> _sendConfirmationMessage(String userId) async {
    const adminUid = 'wjGx853IYFTe2hrtNxrSvTKc23h1';
    final chatId =
        userId.compareTo(adminUid) < 0
            ? '${userId}_$adminUid'
            : '${adminUid}_$userId';

    final messageText =
        widget.isProjectOrder
            ? '✅ Votre commande de planche personnalisée a bien été validée. Merci !'
            : '✅ Votre commande a bien été validée. Merci pour votre achat !';

    await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': adminUid,
          'text': messageText,
          'createdAt': Timestamp.now(),
          'isRead': false,
        });

    await FirebaseFirestore.instance.collection('messages').doc(chatId).set({
      'participants': [userId, adminUid],
      'lastMessage': messageText,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
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
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder:
                    (_) =>
                        const BottomNavContainer(initialIndex: 0), // Home tab
              ),
              (route) => false,
            );
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
              Text(
                widget.isProjectOrder
                    ? 'Commande de projet confirmée !'
                    : 'Commande confirmée !',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.beige,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.isProjectOrder
                    ? 'Merci ! Nous lançons la fabrication. Voici votre récap :'
                    : 'Merci pour votre achat. Voici le récapitulatif de votre commande :',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildSummaryRow('Nom', widget.buyerName),
              _buildSummaryRow('Email', widget.buyerEmail),
              _buildSummaryRow('Téléphone', widget.buyerPhone),
              _buildSummaryRow('Adresse', widget.buyerAddress),
              if (widget.isProjectOrder && widget.deliveryDate != null)
                _buildSummaryRow(
                  'Livraison prévue',
                  '${widget.deliveryDate!.day}/${widget.deliveryDate!.month}/${widget.deliveryDate!.year}',
                ),
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
                onPressed:
                    () => Navigator.popUntil(context, (route) => route.isFirst),
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
