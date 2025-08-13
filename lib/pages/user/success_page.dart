import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewlin_board/core/firebase_refs.dart';
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

  // 🔽 NOUVEAU : on peut recevoir l’image déjà affichée dans OrderPage
  final String? previewImageUrl;

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
    this.previewImageUrl, // 👈 nouveau
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

  String? _normalizeStorageUrl(String? raw) {
    if (raw == null) return null;
    final url = raw.trim();
    if (url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    if (url.startsWith('gs://')) {
      final without = url.substring(5);
      final slash = without.indexOf('/');
      if (slash == -1) return null;
      final bucket = without.substring(0, slash);
      final path = without.substring(slash + 1);
      final enc = Uri.encodeComponent(path);
      return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$enc?alt=media';
    }

    // chemin simple "dir/file.jpg"
    const defaultBucket = 'chewlinboard-7a16f.firebasestorage.app';
    if (!url.contains('://') && url.contains('/')) {
      final enc = Uri.encodeComponent(url);
      return 'https://firebasestorage.googleapis.com/v0/b/$defaultBucket/o/$enc?alt=media';
    }
    return url;
  }

  Future<void> _handleAfterPayment() async {
    final currentUser = firebaseAuth.currentUser;
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
      // 1) ProjectId (simple : on prend ce qu'on a reçu)
      String? effectiveProjectId =
          (widget.projectId != null && widget.projectId!.isNotEmpty)
              ? widget.projectId
              : null;

      // 2) Image du projet
      //    priorité à previewImageUrl (passée depuis OrderPage/StripeCheckoutPage),
      //    sinon fallback lecture du doc 'projects/{id}'
      String? projectImageUrl = _normalizeStorageUrl(widget.previewImageUrl);

      if (projectImageUrl == null && effectiveProjectId != null) {
        try {
          final projDoc =
              await firestore
                  .collection('projects')
                  .doc(effectiveProjectId)
                  .get();

          if (projDoc.exists) {
            final p = projDoc.data() ?? {};
            String? raw;
            if (p['imagePaths'] is List &&
                (p['imagePaths'] as List).isNotEmpty) {
              raw = (p['imagePaths'] as List).first as String?;
            } else if (p['finalImageUrl'] is String) {
              raw = p['finalImageUrl'] as String?;
            } else if (p['imageUrl'] is String) {
              raw = p['imageUrl'] as String?;
            } else if (p['coverUrl'] is String) {
              raw = p['coverUrl'] as String?;
            }
            projectImageUrl = _normalizeStorageUrl(raw);
          }
        } catch (e) {
          debugPrint('ℹ️ Lecture projet échouée (image ignorée) : $e');
        }
      }

      // 3) Mettre à jour le projet (si id dispo)
      if (effectiveProjectId != null) {
        await firestore.collection('projects').doc(effectiveProjectId).set({
          'userId': userId,
          'isPaid': true,
          'isDraft': false,
          if (widget.deliveryDate != null)
            'deliveryDate': widget.deliveryDate!.toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        debugPrint(
          '⚠️ Aucun projectId fourni — on crée quand même la commande.',
        );
      }

      // 4) Créer l’order (toujours)
      await firestore.collection('orders').add({
        'skateboardId': 'customProject',
        'projectId': effectiveProjectId ?? '',
        'projectImageUrl': projectImageUrl ?? '',
        'name': widget.buyerName,
        'email': widget.buyerEmail,
        'phone': widget.buyerPhone,
        'address': widget.buyerAddress,
        'status': 'payée',
        'price': widget.price,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 5) Agenda (non bloquant)
      if (widget.deliveryDate != null) {
        try {
          await _addGoogleCalendarEvent(widget.deliveryDate!, widget.buyerName);
        } catch (e) {
          debugPrint('ℹ️ Échec ajout agenda (non bloquant) : $e');
        }
      }
    } catch (e, st) {
      debugPrint('❌ finalizeProjectOrder: $e\n$st');
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

    await firestore
        .collection('messages')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': adminUid,
          'text': messageText,
          'createdAt': Timestamp.now(),
          'isRead': false,
        });

    await firestore.collection('messages').doc(chatId).set({
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
