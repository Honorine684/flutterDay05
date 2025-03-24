// lib/auth/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: '1090102585003-g5lvh040fhb48edgn0jl4alosalkmr90.apps.googleusercontent.com',
        scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
      );
    } else {
      _googleSignIn = GoogleSignIn();
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
      debugPrint("Inscription réussie : ${userCredential.user?.email}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur lors de l'inscription : ${e.message}");
      throw e;
    }
  }

  
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      debugPrint("Connexion réussie : ${userCredential.user?.email}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur lors de la connexion : ${e.message}");
      throw e;
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
      debugPrint("Connexion Google réussie : ${userCredential.user?.displayName}");
      
    
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'nom': googleUser.displayName?.split(' ').last ?? '',
        'prenom': googleUser.displayName?.split(' ').first ?? '',
        'email': googleUser.email,
        'role': 'Client',
        'timestamp': Timestamp.now(),
      }, SetOptions(merge: true)); 
      
      return userCredential.user;
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
      throw e;
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