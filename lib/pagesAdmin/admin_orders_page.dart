import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import '../pagesAdmin/admin_order_details_page.dart';
import 'package:chewlin_board/core/firebase_refs.dart';

class AdminOrder {
  final String id;
  final String name;
  final String address;
  final String status;
  final double price;
  final String? imageUrl;
  final DateTime timestamp;
  AdminOrder({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.price,
    this.imageUrl,
    required this.timestamp,
  });
}

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});
  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  String? _normalizeStorageUrl(String? raw) {
    if (raw == null) return null;
    final url = raw.trim();
    if (url.isEmpty) return null;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('gs://')) {
      final withoutScheme = url.substring(5);
      final firstSlash = withoutScheme.indexOf('/');
      if (firstSlash == -1) return null;
      final bucket = withoutScheme.substring(0, firstSlash);
      final path = withoutScheme.substring(firstSlash + 1);
      final encodedPath = Uri.encodeComponent(path);
      return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media';
    }

    const defaultBucket = 'chewlinboard-7a16f.firebasestorage.app';
    if (!url.contains('://') && url.contains('/')) {
      final encodedPath = Uri.encodeComponent(url);
      return 'https://firebasestorage.googleapis.com/v0/b/$defaultBucket/o/$encodedPath?alt=media';
    }

    return url;
  }

  Future<String?> _resolveOrderImageUrl(Map<String, dynamic> data) async {
    // 1) Priorité au champ ajouté dans SuccessPage pour projets custom
    final projectImage = data['projectImageUrl'];
    final normalizedProjectImage = _normalizeStorageUrl(
      projectImage as String?,
    );
    if (normalizedProjectImage != null) return normalizedProjectImage;

    // 2) Champs standards dans la commande
    final direct =
        data['imageUrl'] ??
        data['customImageUrl'] ??
        data['finalImageUrl'] ??
        data['coverUrl'];
    final normalizedDirect = _normalizeStorageUrl(direct as String?);
    if (normalizedDirect != null) return normalizedDirect;

    // 2.5) Fallback spécial "customProject" via projectId -> projects/{projectId}
    if (data['skateboardId'] == 'customProject' &&
        data['projectId'] is String &&
        (data['projectId'] as String).isNotEmpty) {
      final projDoc =
          await firestore
              .collection('projects')
              .doc(data['projectId'] as String)
              .get();

      if (projDoc.exists) {
        final p = projDoc.data() ?? {};
        String? raw;

        // ton schéma actuel : imagePaths est un tableau, on prend le premier élément
        if (p['imagePaths'] is List && (p['imagePaths'] as List).isNotEmpty) {
          raw = (p['imagePaths'] as List).first as String?;
        } else if (p['finalImageUrl'] is String) {
          raw = p['finalImageUrl'] as String?;
        } else if (p['imageUrl'] is String) {
          raw = p['imageUrl'] as String?;
        } else if (p['coverUrl'] is String) {
          raw = p['coverUrl'] as String?;
        } else if (p['images'] is List && (p['images'] as List).isNotEmpty) {
          raw = (p['images'] as List).first as String?;
        }

        final normalized = _normalizeStorageUrl(raw);
        if (normalized != null) return normalized;
      }
    }

    // 3) Sinon, via le skateboard lié
    final skateboardId = data['skateboardId'];
    if (skateboardId != null &&
        skateboardId is String &&
        skateboardId.isNotEmpty) {
      final boardDoc =
          await firestore.collection('skateboards').doc(skateboardId).get();
      if (boardDoc.exists) {
        final b = boardDoc.data() ?? {};
        final fromBoard = b['imageUrl'] ?? b['coverUrl'];
        final normalizedBoard = _normalizeStorageUrl(fromBoard as String?);
        if (normalizedBoard != null) return normalizedBoard;

        final images = b['images'];
        if (images is List && images.isNotEmpty && images.first is String) {
          return _normalizeStorageUrl(images.first as String);
        }
      }
    }

    return null;
  }

  Future<List<AdminOrder>> fetchOrders() async {
    final snap =
        await firestore
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .get();

    final futures = snap.docs.map((doc) async {
      final data = doc.data();

      DateTime ts;
      final rawTs = data['timestamp'];
      if (rawTs is Timestamp) {
        ts = rawTs.toDate();
      } else if (rawTs is DateTime) {
        ts = rawTs;
      } else {
        ts = DateTime.now();
      }

      final resolvedUrl = await _resolveOrderImageUrl(data);

      return AdminOrder(
        id: doc.id,
        name: (data['name'] ?? 'Inconnu') as String,
        address: (data['address'] ?? 'Adresse inconnue') as String,
        status: (data['status'] ?? 'payée') as String,
        price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
        imageUrl: resolvedUrl,
        timestamp: ts,
      );
    });

    return Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Commandes',
          style: TextStyle(
            fontFamily: 'ReginaBlack',
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.beige,
      ),
      body: FutureBuilder<List<AdminOrder>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }
          final orders = snapshot.data ?? const <AdminOrder>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              ...orders.map((order) {
                final formattedDate = DateFormat(
                  'dd/MM/yyyy à HH:mm',
                ).format(order.timestamp);
                return GestureDetector(
                  onTap: () async {
                    final orderDoc =
                        await firestore
                            .collection('orders')
                            .doc(order.id)
                            .get();
                    if (!orderDoc.exists) return;
                    final data = orderDoc.data()!..['id'] = order.id;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminOrderDetailsPage(orderData: data),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [AppColors.green, AppColors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child:
                                (order.imageUrl != null &&
                                        order.imageUrl!.trim().isNotEmpty)
                                    ? Image.network(
                                      order.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.broken_image,
                                            ),
                                          ),
                                    )
                                    : Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.name,
                                style: const TextStyle(
                                  color: AppColors.beige,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                'Statut : ${order.status}',
                                style: const TextStyle(
                                  color: AppColors.beige,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                'Prix : ${order.price} €',
                                style: const TextStyle(
                                  color: AppColors.beige,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                'Commandé le : $formattedDate',
                                style: const TextStyle(
                                  color: AppColors.beige,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
