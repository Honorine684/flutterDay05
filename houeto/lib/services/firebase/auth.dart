
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
   User? get currentUser =>_firebaseAuth.currentUser;
  Stream<User?> get authStateChange => _firebaseAuth.authStateChanges();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void> createUserWithEmailAndPassword(
    String nom, String prenom,String email,String password,{String role = 'proprietaire'})async {
      
    try{
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      if(userCredential.user!= null){
        await firestore.collection('users').doc(userCredential.user!.uid).set(
          {
            'nom':nom,
            'prenom': prenom,
            'email':email,
            'role':role,
            'timestamp':Timestamp.now()
          }
        );
      }
    }catch(e){
      print("Erreur lors de la creation de l'user $e");
    }
  }  

Future<void> SigninWithEmailAndPassword(String email,String password) async{
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
}