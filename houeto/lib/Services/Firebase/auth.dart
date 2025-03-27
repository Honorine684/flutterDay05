import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();

  Future<void> createUserWithEmailAndPassword({
    required String nom, 
    required String prenom,
    required String email,
    String? photo = '',
    required String password,
    String role = 'proprietaire',
    double solde = 0.0,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'photo': photo,
          'role': role,
          'solde': solde,
          'timestamp': Timestamp.now(),
        });

        await saveFCMToken(userCredential.user!.uid);
      }
    } catch (e) {
      print("Erreur lors de la création de l'utilisateur: $e");
      rethrow;
    }
  }

  Future<void> signinWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await saveFCMToken(userCredential.user!.uid);
      }
    } catch (e) {
      print("Erreur de connexion: $e");
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Connexion Google annulée');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _firebaseAuth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        if (result.additionalUserInfo?.isNewUser == true) {
          await _addGoogleUser(
            userID: user.uid,
            email: googleUser.email,
            firstName: googleUser.displayName?.split(' ').first ?? '',
            lastName: googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
            avatar: googleUser.photoUrl ?? '',
          );
        }

      
        await saveFCMToken(user.uid);
      }
    } catch (e) {
      print('Erreur connexion Google : $e');
    }
  }

  Future<void> _addGoogleUser({
    required String userID,
    required String firstName,
    required String lastName,
    required String email,
    required String avatar,
    String role = 'proprietaire',
  }) async {
    try {
      await firestore.collection('users').doc(userID).set({
        'nom': firstName.isNotEmpty ? firstName : 'Non spécifié',
        'prenom': lastName.isNotEmpty ? lastName : 'Non spécifié',
        'email': email.isNotEmpty ? email : 'Non disponible',
        'photo': avatar.isNotEmpty ? avatar : '',
        'role': role,
        'solde': 0.0,
        'timestamp': Timestamp.now(),
      });

      await saveFCMToken(userID);
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'utilisateur Google: $e');
    }
  }

  Future<void> logout() async {
    try {
      if (currentUser != null) {
        await removeFCMToken(currentUser!.uid);
      }
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut(); 
    } catch (e) {
      print("Erreur lors de la déconnexion: $e");
    }
  }

  Future<void> removeFCMToken(String userId) async {
    try {
      await firestore.collection('users').doc(userId).update({'fcmToken': FieldValue.delete()});
      print("Token supprimé pour $userId");
    } catch (e) {
      print("Erreur suppression FCM Token: $e");
    }
  }

  Future<void> saveFCMToken(String userId) async {
    try {
      await _firebaseMessaging.requestPermission();
      String? newToken = await _firebaseMessaging.getToken();

      if (newToken != null) {
        DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();
        String? oldToken = userDoc.exists ? (userDoc.data() as Map<String, dynamic>)['fcmToken'] : null;

        if (oldToken != newToken) {
          await firestore.collection('users').doc(userId).set({'fcmToken': newToken}, SetOptions(merge: true));
          print("FCM Token mis à jour pour $userId");
        } else {
          print("⚠️ FCM Token inchangé pour $userId");
        }
      }
    } catch (e) {
      print( "Erreur mise à jour FCM Token: $e");
    }
  }

  Future<void> updateAllExistingUsers() async {
    final users = await firestore.collection('users').get();
    for (final doc in users.docs) {
      await saveFCMToken(doc.id);
    }
  }

  Future<List<Map<String, dynamic>>> getProprietairesSansCurrentUser() async {
    try {
      final currentUserId = _firebaseAuth.currentUser?.uid;
      if (currentUserId == null) return [];

      final snapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'proprietaire')
          .get();

      return snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) {
            final data = doc.data();
            return {
              'uid': doc.id,
              'email': data['email'] ?? 'Pas d\'email',
              'nomComplet': '${data['prenom'] ?? ''} ${data['nom'] ?? ''}'.trim(),
            };
          })
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des propriétaires: $e");
      return [];
    }
  }
  Future<String?> getUserFCMToken(String userId) async {
  try {
    DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      return (userDoc.data() as Map<String, dynamic>)['fcmToken'] as String?;
    }
  } catch (e) {
    print(" Erreur lors de la récupération du FCM Token: $e");
  }
  return null;
}

}
