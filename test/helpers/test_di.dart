import 'package:chewlin_board/core/firebase_refs.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void injectFakes() {
  firebaseAuth = MockFirebaseAuth();
  firestore = FakeFirebaseFirestore();
  authService = AuthService(auth: firebaseAuth, firestore: firestore);
}
