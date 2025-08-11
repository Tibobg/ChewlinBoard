import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  static String? lastErrorMessage;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  /// Inscription d'un nouvel utilisateur
  Future<User?> signUp(String email, String password, String pseudo) async {
    try {
      lastErrorMessage = null;
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Enregistrer le pseudo en base
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'pseudo': pseudo,
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print("Erreur lors de l'inscription: ${e.message}");
      if (e.code == 'email-already-in-use') {
        lastErrorMessage = 'Cet email est déjà utilisé.';
      } else if (e.code == 'invalid-email') {
        lastErrorMessage = 'Email invalide.';
      } else if (e.code == 'weak-password') {
        lastErrorMessage = 'Le mot de passe est trop faible.';
      } else {
        lastErrorMessage = e.message;
      }
      return null;
    }
  }

  /// Connexion d'un utilisateur existant
  Future<User?> signIn(String email, String password) async {
    try {
      lastErrorMessage = null;
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Erreur lors de la connexion: ${e.code} - ${e.message}");

      switch (e.code) {
        case 'user-not-found':
          lastErrorMessage = "Aucun compte n'existe avec cet email.";
          break;
        case 'wrong-password':
          lastErrorMessage = "Mot de passe incorrect.";
          break;
        case 'invalid-email':
          lastErrorMessage = "L'email est mal formaté.";
          break;
        case 'too-many-requests':
          lastErrorMessage =
              "Trop de tentatives, veuillez réessayer plus tard.";
          break;
        case 'network-request-failed':
          lastErrorMessage = "Problème de connexion réseau.";
          break;
        case 'invalid-credential':
          lastErrorMessage = "Email ou mot de passe incorrect.";
          break;
        default:
          lastErrorMessage = "Erreur inconnue (${e.code}) : ${e.message}";
      }

      return null;
    } catch (e) {
      lastErrorMessage = "Erreur inattendue : ${e.toString()}";
      return null;
    }
  }

  /// Déconnexion
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print("Erreur lors de la déconnexion: ${e.toString()}");
      return null;
    }
  }

  /// Réinitialisation du mot de passe
  Future sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print("Erreur lors de la réinitialisation du mot de passe: ${e.message}");
      rethrow;
    }
  }

  /// Accès à l'utilisateur connecté
  User? get currentUser => _auth.currentUser;
}
