import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeffa_log/auth/auth_service.dart';
import 'package:houeffa_log/auth/login.dart';
import 'package:houeffa_log/wrapper.dart'; 

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });
    try {
      User? user = await _auth.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        
        await _auth.sendEmailVerificationLink(user);
        
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Wrapper()));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Erreur d'inscription")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inscription - HouefFa Toit"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      "Créer un compte sur HouefFa Toit",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 40),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Entrer votre email",
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: "Entrer votre mot de passe",
                        labelText: "Mot de passe",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        backgroundColor: Colors.deepOrangeAccent,
                      ),
                      child: Text("S'inscrire", style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Déjà un compte ? "),
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                          },
                          child: Text(
                            "Se connecter",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}