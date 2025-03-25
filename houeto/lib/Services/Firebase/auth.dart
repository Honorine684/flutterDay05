import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    }
  } catch (e) {
    print("Erreur lors de la création de l'utilisateur: $e");
  }
}

Future<void> signinWithEmailAndPassword(String email,String password) async{
  await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
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
) {
  return firestore
    .collection('users')
    .doc(userID)
    .set({
      'nom': firstName.isNotEmpty ? firstName : 'Non spécifié',
      'prenom': lastName.isNotEmpty ? lastName : 'Non spécifié',
      'email': email.isNotEmpty ? email : 'Non disponible',
      'photo': avatar.isNotEmpty ? avatar : 'URL par défaut',
      'role': role,
      'solde':0.0,
      'Timestamp': Timestamp.now()
    })
    .then((value) => print('Utilisateur ajouté'))
    .catchError((error) => print('Erreur : $error'));
}
}