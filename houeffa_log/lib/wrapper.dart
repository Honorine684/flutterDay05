import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeffa_log/auth/login.dart';
import 'dart:developer' as developer;
import 'package:houeffa_log/auth/verification.dart';
import 'package:houeffa_log/screens/home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        developer.log("Wrapper appelé");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Erreur lors de la connexion")));
        } else {
          if (snapshot.data == null) {
            return const LoginScreen(); 
          } else {
            User user = snapshot.data!;
            if (user.emailVerified) {
              return const HomeScreen();
            } else {
              return VerificationScreen(user: user);
            }
          }
        }
      },
    );
  }
}