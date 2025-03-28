import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeffa_log/wrapper.dart';

class VerificationScreen extends StatefulWidget {
  final User user;

  const VerificationScreen({super.key, required this.user});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _auth = AuthService();
  late Timer timer;

  @override
  void initState() {
    super.initState();

    _auth.sendEmailVerificationLink(widget.user);

    timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        timer.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Wrapper()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification - HouefFa Toit"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              "Un email de vérification a été envoyé à ${widget.user.email}.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _auth.sendEmailVerificationLink(widget.user);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Email de vérification renvoyé")),
                );
              },
              child: const Text("Renvoyer l'email"),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthService {
  Future<void> sendEmailVerificationLink(User user) async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      print("Erreur lors de l'envoi de l'email : $e");
    }
  }
}