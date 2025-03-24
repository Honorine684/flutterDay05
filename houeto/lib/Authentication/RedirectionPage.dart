import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:houeto/Authentication/Login.dart';
import 'package:houeto/Component/BottomBar.dart';
import 'package:houeto/Pages/Home.dart';
import 'package:houeto/Services/Firebase/auth.dart';

class Redirectionpage extends StatefulWidget {
  const Redirectionpage({super.key});

  @override
  State<Redirectionpage> createState() {
    return RedirectionpageState();
  }
}

class RedirectionpageState extends State<Redirectionpage> {
  // Méthode pour récupérer le rôle de l'utilisateur
  Future<String> getUserRole(String userId) async {
    DocumentSnapshot userRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    if (userRef.exists) {
      return userRef['role'];
    } else {
      return 'proprietaire'; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: const CircularProgressIndicator(),
          ); 
        } else if (snapshot.hasData) {
          
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return FutureBuilder(
              future: getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
            child: const CircularProgressIndicator(),
          ); 
                } else if (roleSnapshot.hasData) {
                  String role = roleSnapshot.data as String;
                  // Rediriger en fonction du rôle
                  if (role == 'proprietaire') {
                    return const Bottombar();
                  } else if (role == 'delegue') {
                    return const Home();
                  } else if (role == 'Gestionnaire') {
                    return const Bottombar();
                  } else {
                    return const ConnexionPage(); 
                  }
                } else {
                  return const ConnexionPage();
                }
              },
            );
          } else {
            return const ConnexionPage();
          }
        } else {
          return const ConnexionPage(); 
        }
      },
    );
  }
}