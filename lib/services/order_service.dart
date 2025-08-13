import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewlin_board/core/firebase_refs.dart';

class OrderService {
  static Future<void> saveOrder({
    required String skateboardId,
    required String buyerName,
    required String buyerEmail,
    required String buyerPhone,
    required String buyerAddress,
    required double price,
  }) async {
    final user = firebaseAuth.currentUser;

    await firestore.collection('orders').add({
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
    await firestore.collection('skateboards').doc(skateboardId).update({
      'isSold': true,
    });
  }
}
