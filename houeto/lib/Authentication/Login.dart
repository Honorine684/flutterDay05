import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Authentication/Signup.dart';
import 'package:houeto/Component/BottomBar.dart';
import 'package:houeto/Services/Firebase/auth.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionpageState();
}

class _ConnexionpageState extends State<ConnexionPage> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final passWord = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: size.height * 0.05),
            Image.asset(
              "assets/images/sign1.jpg",
              height: size.height * 0.25,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              "Content de vous revoir !",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Connectez-vous pour accéder à votre compte HoueTo",
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passWord,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() {
                          showPassword = !showPassword;
                        }),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Mot de passe obligatoire';
                      }
                      if (value.length < 6) {
                        return 'Minimum 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              try {
                                await Auth().signinWithEmailAndPassword(
                                    email.text, passWord.text);
                              } on FirebaseAuthException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.message ?? 'Erreur de connexion'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => isLoading = false);
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Ou continuer avec'),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
                   SizedBox(
  height: 50,
  child: OutlinedButton(
    onPressed: () async {
      
      try {
        await Auth().signInWithGoogle();


        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const Bottombar())
        );
      } catch (e) {
        print("voici le probleme $e");
        /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion : ${e.toString()}'),
            
            backgroundColor: Colors.red,
          ),
        );*/
      }
    },
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: BorderSide(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/google.jpg', 
          height: 24,
          width: 24,
        ),
        const SizedBox(width: 10),
        const Text('Connexion avec Google'),
      ],
    ),
  ),
),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Nouveau sur HoueTo ?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Signup()),
                    );
                  },
                  child: const Text('Créer un compte'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}