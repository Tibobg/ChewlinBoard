import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static Future<void> saveOrder({
    required String skateboardId,
    required String buyerName,
    required String buyerEmail,
    required String buyerPhone,
    required String buyerAddress,
    required double price,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': user?.uid,
      'skateboardId': skateboardId,
      'name': buyerName,
      'email': buyerEmail,
      'phone': buyerPhone,
      'address': buyerAddress,
      'price': price,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'payée',
    });

    // Mise à jour du statut de la planche
    await FirebaseFirestore.instance
        .collection('skateboards')
        .doc(skateboardId)
        .update({'isSold': true});
  }
}
