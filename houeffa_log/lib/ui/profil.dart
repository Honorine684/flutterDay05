import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:houeffa_log/auth/auth_service.dart';
import 'package:houeffa_log/ui/pick_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();
  String? _base64ProfileImage;

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      debugPrint("Déconnexion réussie");
    } catch (e) {
      debugPrint("Erreur lors de la déconnexion : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la déconnexion : $e")),
      );
    }
  }

  Future<void> _updateProfileImage() async {
    final base64Image = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PickImage()),
    );

    if (base64Image != null && base64Image is String) {
      setState(() {
        _base64ProfileImage = base64Image;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw "Utilisateur non connecté";

        
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'profileImage': base64Image,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint("Image Base64 enregistrée dans Firestore");
      } catch (e) {
        debugPrint("Erreur lors de l’enregistrement : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      } finally {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "Utilisateur non connecté";

      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profileImage': FieldValue.delete(),
      });

      setState(() {
        _base64ProfileImage = null;
      });
      debugPrint("Image de profil supprimée");
    } catch (e) {
      debugPrint("Erreur lors de la suppression : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (authSnapshot.hasError) {
            return const Center(child: Text("Erreur de chargement du profil"));
          }

          final User? user = authSnapshot.data;

          if (user == null) {
            return const Center(
              child: Text(
                "Veuillez vous connecter pour voir votre profil",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
            builder: (context, firestoreSnapshot) {
              if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = firestoreSnapshot.data?.data() as Map<String, dynamic>?;
              final String? storedBase64Image = data?['profileImage'];

              
              if (storedBase64Image != null && _base64ProfileImage == null) {
                _base64ProfileImage = storedBase64Image;
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        "Profil",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.deepOrangeAccent, Colors.orangeAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  backgroundImage: _base64ProfileImage != null
                                      ? MemoryImage(base64Decode(_base64ProfileImage!))
                                      : const AssetImage('assets/default_profile.png') as ImageProvider,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.camera_alt, color: Colors.black),
                                      onPressed: _updateProfileImage,
                                    ),
                                    if (_base64ProfileImage != null)
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.black),
                                        onPressed: _deleteProfileImage,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProfileItem(
                                    Icons.person,
                                    "Nom",
                                    user.displayName ?? "Non défini",
                                  ),
                                  _buildProfileItem(
                                    Icons.email,
                                    "Email",
                                    user.email ?? "Non défini",
                                  ),
                                  _buildProfileItem(
                                    Icons.calendar_today,
                                    "Compte créé le",
                                    user.metadata.creationTime != null
                                        ? "${user.metadata.creationTime!.day}/${user.metadata.creationTime!.month}/${user.metadata.creationTime!.year}"
                                        : "Inconnu",
                                  ),
                                  _buildProfileItem(
                                    Icons.access_time,
                                    "Dernière connexion",
                                    user.metadata.lastSignInTime != null
                                        ? "${user.metadata.lastSignInTime!.day}/${user.metadata.lastSignInTime!.month}/${user.metadata.lastSignInTime!.year}"
                                        : "Inconnu",
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _signOut(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Se déconnecter"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrangeAccent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}