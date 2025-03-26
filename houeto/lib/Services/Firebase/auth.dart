import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
   User? get currentUser =>_firebaseAuth.currentUser;
  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
 Future<void> createUserWithEmailAndPassword({
  required String nom, 
  required String prenom,
  required String email,
  String? photo = '',
  required String password,
  String role = 'proprietaire' ,
  double solde = 0.0,
}) async {
  try {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    
    if (userCredential.user != null) {
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'photo': photo, 
        'role': role,
        'solde':solde,
        'timestamp': Timestamp.now()
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
      password: password
    );
    
    // Met à jour le FCM Token après connexion
    if (userCredential.user != null) {
      await saveFCMToken(userCredential.user!.uid);
    }
  } catch (e) {
    print("Erreur de connexion: $e");
    rethrow;
  }
}
// logout
Future<void> logout()async{
  await _firebaseAuth.signOut();
}

// logout
Future<void> sendEmailVerificationLink()async{
  try {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  } catch (e){
    print(e.toString());
  }
}
Future<void> signInWithGoogle() async {
  (String, String) parseDisplayName(String? displayName) {
  // Si displayName est null, retourne des chaînes vides
  if (displayName == null || displayName.trim().isEmpty) {
    return ('', '');
  }

  // Diviser le nom en parties
  final nameParts = displayName.trim().split(' ');
  
  // Si aucune partie, retourne des chaînes vides
  if (nameParts.isEmpty) {
    return ('', '');
  }

  // Si une seule partie, utiliser comme prénom
  if (nameParts.length == 1) {
    return (nameParts[0], '');
  }

  // Plusieurs parties : première partie comme prénom, reste comme nom de famille
  return (
    nameParts.first, 
    nameParts.skip(1).join(' ')
  );
}
  try {
    // Démarrer le processus de connexion
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    
    if (googleUser == null) {
      print('La connexion Google a été annulée');
      return;
    }
    
    final (firstName, lastName) = parseDisplayName(googleUser.displayName);

    // Obtenir les détails d'authentification de la requête
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    // Créer un nouveau identifiant pour l'utilisateur
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // Se connecter avec les identifiants
    UserCredential result = await _firebaseAuth.signInWithCredential(credential);

    if (result.additionalUserInfo?.isNewUser == true) {
      var user = _firebaseAuth.currentUser?.uid;
      var email = googleUser.email ;
      var avatar = googleUser.photoUrl ?? '';
      
      if (user != null) {
        await _addGoogleUser(user, firstName, lastName, email, avatar);
      }
    }
  } catch (e) {
    print('Erreur de connexion Google : $e');
  }
}

Future<void> _addGoogleUser(
  String userID, 
  String firstName, 
  String lastName, 
  String email, 
  String avatar,
  {String role = 'proprietaire'}
) async {
  try {
    await firestore.collection('users').doc(userID).set({
      'nom': firstName.isNotEmpty ? firstName : 'Non spécifié',
      'prenom': lastName.isNotEmpty ? lastName : 'Non spécifié',
      'email': email.isNotEmpty ? email : 'Non disponible',
      'photo': avatar.isNotEmpty ? avatar : 'URL par défaut',
      'role': role,
      'solde': 0.0,
      'timestamp': Timestamp.now()
    });

    // Sauvegarde le FCM Token
    await saveFCMToken(userID);
  } catch (e) {
    print('Erreur : $e');
    rethrow;
  }
}
Future<List<Map<String, dynamic>>> getProprietairesSansCurrentUser() async {
  try {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
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
           // 'fcmToken': data['fcmToken'] ?? '',
          };
        })
        .toList();
  } catch (e) {
    print("Erreur lors de la récupération des propriétaires: $e");
    return [];
  }
}


  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Génère et sauvegarde le FCM Token pour l'utilisateur connecté
  Future<void> saveFCMToken(String userId) async {
    try {
      // Demande les permissions (iOS)
      await _firebaseMessaging.requestPermission();
      
      // Récupère le token
      String? token = await _firebaseMessaging.getToken();
      
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({'fcmToken': token}, SetOptions(merge: true)); 
        print("✅ FCM Token enregistré pour $userId");
      }
    } catch (e) {
      print("❌ Erreur FCM Token: $e");
    }
  }

  Future<void> updateAllExistingUsers() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    for (final doc in users.docs) {
      await saveFCMToken(doc.id);
    }
  }
}
