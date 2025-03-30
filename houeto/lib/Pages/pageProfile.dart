import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Authentication/Login.dart';
import 'package:houeto/Pages/PageFacture.dart';
import 'package:houeto/Pages/ParametresPage.dart';
import 'package:houeto/Pages/pageInfos.dart';
import 'package:houeto/Services/Firebase/auth.dart';
import 'package:image_picker/image_picker.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({super.key});

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  bool light = true;
  String nom = '';
  String prenom = '';
  String email = '';
  String uid = '';
  String photoBase64 = '';  
  File? imageFile;
  Future<void> getUserData() async {
    try {
      final User? currentUser = Auth().currentUser;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          //uid = userDoc.get('uid');
          nom = userDoc.get('nom') ?? '';
          prenom = userDoc.get('prenom') ?? '';
          email = currentUser.email ?? '';
        });
      }
    } catch (e) {
      print("erreur lors de la recupération de l'user $e");
    }
  }

void showChangePasswordDialog() {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  bool showOldPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Modifier le mot de passe'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPasswordController,
                    obscureText: !showOldPassword,
                    decoration: InputDecoration(
                      labelText: 'Ancien mot de passe',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showOldPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            showOldPassword = !showOldPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: !showNewPassword,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showNewPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            showNewPassword = !showNewPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !showConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le nouveau mot de passe',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            showConfirmPassword = !showConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newPasswordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Les mots de passe ne correspondent pas')),
                    );
                    return;
                  }

                  if (newPasswordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Le mot de passe doit faire au moins 6 caractères')),
                    );
                    return;
                  }

                  try {
                    final user = Auth().currentUser;
                    if (user != null) {
                      final cred = EmailAuthProvider.credential(
                        email: user.email!,
                        password: oldPasswordController.text,
                      );

                      await user.reauthenticateWithCredential(cred);
                      await user.updatePassword(newPasswordController.text);

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Mot de passe changé avec succès'),
                            backgroundColor: Colors.green,
                            ),
                            
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    String errorMessage;
                    switch (e.code) {
                      case 'wrong-password':
                        errorMessage = 'Ancien mot de passe incorrect';
                        break;
                      case 'weak-password':
                        errorMessage = 'Le mot de passe est trop faible';
                        break;
                      default:
                        errorMessage = 'Une erreur est survenue: ${e.message}';
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e')),
                      
                    );
                  }
                },
                child: const Text('Valider'),
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,  
      maxHeight: 800,
      imageQuality: 85,  
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    if (imageFile == null) return;

    try {
      final bytes = await imageFile!.readAsBytes();
      
      String base64Image = base64Encode(bytes);
      
      if (base64Image.length > 1048576) { 
        throw Exception("L'image est trop grande (max 1MB)");
      }

      final User? currentUser = Auth().currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'photo': base64Image});

        setState(() {
          photoBase64 = base64Image;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo de profil mise à jour avec succès'),backgroundColor: Colors.green,),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour de la photo: $e')),
      );
    }
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;
    final hauteurEcran = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: hauteurEcran * 0.05,
            ),
            Stack(
              children: [
                Row(
                  children: [
                    SizedBox(width: largeurEcran * 0.3),
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey,
                      backgroundImage: photoBase64.isNotEmpty
                          ? MemoryImage(base64Decode(photoBase64))
                          : null,
                      child: photoBase64.isEmpty
                          ? Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 1,
                  right: largeurEcran * 0.3,
                  child: IconButton(
                    onPressed: pickImage,
                    icon: Icon(Icons.edit, size: 35, color: Colors.blue),
                  ),
                ),
              ],
            ),
            Text(
              '$nom $prenom',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(
              height: hauteurEcran * 0.05,
            ),
            Divider(
              color: Colors.grey.shade700.withOpacity(0.2),
            ),
            SizedBox(
              height: hauteurEcran * 0.04,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PageInfos()));
              },
              child: Row(
                children: [
                  Card(
                    elevation: 4,
                    child: Icon(
                      Icons.person,
                      size: 32,
                    ),
                  ),
                  SizedBox(
                    width: largeurEcran * 0.03,
                  ),
                  Text('Infos personnelles',
                      style: TextStyle(
                        fontSize: 16,
                      )),
                  SizedBox(width: largeurEcran * 0.235),
                  Icon(
                    Icons.chevron_right,
                    size: 35,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: hauteurEcran * 0.04,
            ),
            GestureDetector(
              onTap: () {
                showChangePasswordDialog();
              },
              child: Row(
                children: [
                  Card(
                    elevation: 4,
                    child: Icon(
                      Icons.lock,
                      size: 33,
                    ),
                  ),
                  SizedBox(
                    width: largeurEcran * 0.03,
                  ),
                  Text(
                    'Modifier mot de passe',
                    style: TextStyle(fontSize: 16,)
                  ),
                  SizedBox(width: largeurEcran * 0.15),
                  Icon(
                    Icons.chevron_right,
                    size: 35,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: hauteurEcran * 0.04,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EcranParametres()));
              },
              child: Row(
                children: [
                  Card(
                    elevation: 4,
                    child: Icon(
                      Icons.settings,
                      size: 33,
                    ),
                  ),
                  SizedBox(
                    width: largeurEcran * 0.03,
                  ),
                  Text(
                    'Paramètres',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: largeurEcran * 0.385),
                  Icon(
                    Icons.chevron_right,
                    size: 35,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: hauteurEcran * 0.04,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FactureLoyer()));
              },
              child: Row(
                children: [
                  Card(
                    elevation: 4,
                    child: Icon(
                      Icons.wallet_giftcard,
                      size: 33,
                    ),
                  ),
                  SizedBox(
                    width: largeurEcran * 0.03,
                  ),
                  Text(
                    'Détails factures',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(width: largeurEcran * 0.28),
                  Icon(
                    Icons.chevron_right,
                    size: 35,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: hauteurEcran * 0.04,
            ),
            Row(
              children: [
                Card(
                  elevation: 4,
                  child: Icon(
                    Icons.info,
                    size: 33,
                  ),
                ),
                SizedBox(
                  width: largeurEcran * 0.03,
                ),
                Text(
                  'FAQ',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: largeurEcran * 0.54),
                Icon(
                  Icons.chevron_right,
                  size: 35,
                ),
              ],
            ),
            SizedBox(
              height: hauteurEcran * 0.03,
            ),
            Divider(
              color: Colors.grey.shade600.withOpacity(0.2),
            ),
            Row(
              children: [
                Switch(
                  value: light,
                  activeColor: Colors.black,
                  onChanged: (bool value) {
                    setState(() {
                      light = value;
                    });
                  },
                ),
                SizedBox(
                  width: largeurEcran * 0.005,
                ),
                Text(
                  'Mode Sombre/Clair',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: largeurEcran * 0.21),
                Icon(
                  Icons.chevron_right,
                  size: 35,
                ),
              ],
            ),
            SizedBox(
              height: hauteurEcran * 0.02,
            ),
            GestureDetector(
              onTap: () {
                Auth().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const ConnexionPage()),
                  (route) => false,
                );
              },
              child: Container(
                  width: double.infinity,
                  height: hauteurEcran * 0.06,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8)),
                  child: Center(
                    child: Text('Deconnexion',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
