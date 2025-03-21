import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Login.dart';
import 'package:houeto/services/firebase/auth.dart';

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
  bool showConfirmPassword = false;
  bool isLoading = false;
  // verification email
  String? validateEmail(String? value) {
    const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'+/=?^_`{|}~-]+)|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])")@(?:(?:[a-z0-9](?:[a-z0-9-]'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
    final regex = RegExp(pattern);
    if (value!.isNotEmpty && !regex.hasMatch(value)) {
      return "Entrez un email valide";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;

    final hauteurEcran = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          spacing: 20,
          children: [
            SizedBox(
              height: hauteurEcran * 0.02,
            ),
            Container(
              width: largeurEcran * 0.9,
              height: hauteurEcran * 0.20,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/sign1.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Text(
              'Ravi de vous revoir cher Houeto. Connectez-vous ici !',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Form(
                key: formKey,
                child: Column(
                  spacing: 30,
                  children: [
                    TextFormField(
                      controller: email,
                      validator: validateEmail,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.blue),
                              borderRadius: BorderRadius.circular(8)),
                          labelText: 'Entrez votre email valide',
                          hintText: 'ex : elisha@gmail.com'),
                    ),
                    TextFormField(
                      controller: passWord,
                      // pour verifier si le champ est bien rempli
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Mot de passe obligatoire";
                        } else if ((passWord.text).length < 6) {
                          return "Le mot de passe doit contenir plus de 6 caractères";
                        } else if (!RegExp(r'[a-zA-Z]')
                            .hasMatch(passWord.text)) {
                          return "Le mot de passe doit contenir des lettres";
                        } else if (!RegExp(r'\d').hasMatch(passWord.text)) {
                          return "Le mot de passe doit contenir des nombres";
                        } else if ((passWord.text).contains(' ')) {
                          return "Le mot de passe ne peut contenir d'espace";
                        }
                        return null;
                      },
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.blue),
                              borderRadius: BorderRadius.circular(8)),
                          hintText: "Entrez votre mot de passe",
                          suffixIcon: IconButton(
                            onPressed: () => setState(() {
                              showPassword = !showPassword;
                            }),
                            icon: Icon(showPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                          )),
                    ),
                    Container(
                      width: largeurEcran * 0.88,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blue),
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                if (formKey.currentState!.validate()) {
                                  // Logique de connexion
                                  try {
                                    Auth().SigninWithEmailAndPassword(
                                        email.text, passWord.text);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    // message d'erreur
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("${e.message}"),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Color(0xffE9494F),
                                        showCloseIcon: true,
                                      ),
                                    );
                                  }
                                  // naviguer vers la page home
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ConnexionPage()));
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                "Se connecter",
                                style: TextStyle(
                                    fontSize: largeurEcran * 0.04,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){},
                      child: Container(
                        width: largeurEcran * 0.9,
                        height: hauteurEcran * 0.07,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          spacing: 10,
                          children: [
                            Image.asset(
                              'assets/images/google.jpg',
                              height: hauteurEcran * 0.6,
                              width: largeurEcran*0.2,
                            ),
                            Text('Continuer avec Google', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                    ),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.black),
                              height: 1,
                            ),
                          ),
                          Text(
                            "OU",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.black),
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  ],
                )),
                GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                      },
                      child: Container(
                        width: largeurEcran * 0.9,
                        height: hauteurEcran * 0.07,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Créer un compte', style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
