import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewlin_board/services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

FirebaseAuth? _auth;
FirebaseAuth get firebaseAuth => _auth ??= FirebaseAuth.instance;
set firebaseAuth(FirebaseAuth value) => _auth = value;

FirebaseFirestore? _fs;
FirebaseFirestore get firestore => _fs ??= FirebaseFirestore.instance;
set firestore(FirebaseFirestore value) => _fs = value;

AuthService? _authService;
AuthService get authService =>
    _authService ??= AuthService(auth: firebaseAuth, firestore: firestore);
set authService(AuthService value) => _authService = value;

FirebaseStorage storage = FirebaseStorage.instance;
