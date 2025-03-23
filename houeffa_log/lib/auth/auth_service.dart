import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

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

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e; 
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; 
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw Exception("Erreur lors de la connexion Google : $e");
    }
  }

  Future<void> sendEmailVerificationLink(User user) async {
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception("Erreur lors de la déconnexion : $e");
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}