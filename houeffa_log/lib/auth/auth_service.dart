import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  AuthService() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: '1090102585003-g5lvh040fhb48edgn0jl4alosalkmr90.apps.googleusercontent.com',
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
      );
    } else {
      _googleSignIn = GoogleSignIn();
    }

    // Écouter les changements de token FCM et les mettre à jour dans Firestore
    _messaging.onTokenRefresh.listen((newToken) {
      final user = _auth.currentUser;
      if (user != null) {
        _updateFcmToken(user.uid, newToken);
      }
    });
  }

  // Méthode pour mettre à jour le token FCM dans Firestore
  Future<void> _updateFcmToken(String uid, String? token) async {
    if (token != null) {
      try {
        await _firestore.collection('users').doc(uid).set(
          {'fcmToken': token},
          SetOptions(merge: true), // Fusionne avec les données existantes
        );
        debugPrint("Token FCM mis à jour pour l'utilisateur $uid : $token");
      } catch (e) {
        debugPrint("Erreur lors de la mise à jour du token FCM : $e");
      }
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    String role = 'Client',
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'nom': nom.trim(),
          'prenom': prenom.trim(),
          'email': email.trim(),
          'role': role,
          'timestamp': Timestamp.now(),
        });

        // Récupérer et enregistrer le token FCM
        String? fcmToken = await _messaging.getToken();
        await _updateFcmToken(user.uid, fcmToken);

        debugPrint("Utilisateur créé avec succès : ${user.uid}");
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur lors de la création de l'utilisateur : ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Erreur inattendue : $e");
      rethrow;
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        // Récupérer et enregistrer le token FCM
        String? fcmToken = await _messaging.getToken();
        await _updateFcmToken(user.uid, fcmToken);

        debugPrint("Inscription réussie : ${userCredential.user?.email}");
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur lors de l'inscription : ${e.message}");
      rethrow;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        // Récupérer et enregistrer le token FCM
        String? fcmToken = await _messaging.getToken();
        await _updateFcmToken(user.uid, fcmToken);

        debugPrint("Connexion réussie : ${userCredential.user?.email}");
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur lors de la connexion : ${e.message}");
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("Connexion Google annulée par l'utilisateur");
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'nom': googleUser.displayName?.split(' ').last ?? '',
          'prenom': googleUser.displayName?.split(' ').first ?? '',
          'email': googleUser.email,
          'role': 'Client',
          'timestamp': Timestamp.now(),
        }, SetOptions(merge: true));

        // Récupérer et enregistrer le token FCM
        String? fcmToken = await _messaging.getToken();
        await _updateFcmToken(user.uid, fcmToken);

        debugPrint("Connexion Google réussie : ${userCredential.user?.displayName}");
        return user;
      }
      return null;
    } catch (e) {
      debugPrint("Erreur lors de la connexion Google : $e");
      rethrow;
    }
  }

  Future<void> sendEmailVerificationLink(User user) async {
    try {
      await user.sendEmailVerification();
      debugPrint("Email de vérification envoyé à ${user.email}");
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur lors de l'envoi de l'email : ${e.message}");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      debugPrint("Déconnexion réussie");
    } catch (e) {
      debugPrint("Erreur lors de la déconnexion : $e");
      throw Exception("Erreur lors de la déconnexion : $e");
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}