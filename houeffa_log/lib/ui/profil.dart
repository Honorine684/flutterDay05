import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:houeffa_log/auth/auth_service.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:houeffa_log/ui/pick_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();
  File? _localProfileImage;

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

  Future<File?> _compressImage(File file) async {
    final filePath = file.path;
    final lastIndex = filePath.lastIndexOf('.');
    final outPath = "${filePath.substring(0, lastIndex)}_compressed.jpg";

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 85, 
    );

    return compressedFile != null ? File(compressedFile.path) : file;
  }

  Future<void> _updateProfileImage() async {
    final pickedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PickImage()),
    );

    if (pickedImage != null && pickedImage is File) {
      setState(() {
        _localProfileImage = pickedImage;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw "Utilisateur non connecté";

        final compressedImage = await _compressImage(pickedImage);

     
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}.jpg');
        await storageRef.putFile(compressedImage!);
        final downloadUrl = await storageRef.getDownloadURL();

      
        await user.updatePhotoURL(downloadUrl);
        await user.reload();

        debugPrint("Photo de profil enregistrée : $downloadUrl");
        setState(() {});
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

    
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}.jpg');
      await storageRef.delete();

    
      await user.updatePhotoURL(null);
      await user.reload();

      setState(() {
        _localProfileImage = null;
      });
      debugPrint("Photo de profil supprimée");
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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement du profil"));
          }

          final User? user = snapshot.data;

          if (user == null) {
            return const Center(
              child: Text(
                "Veuillez vous connecter pour voir votre profil",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
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
                              backgroundImage: _localProfileImage != null
                                  ? FileImage(_localProfileImage!)
                                  : (user.photoURL != null
                                      ? NetworkImage(user.photoURL!)
                                      : const AssetImage('assets/default_profile.png')) as ImageProvider,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                                  onPressed: _updateProfileImage,
                                ),
                                if (user.photoURL != null || _localProfileImage != null)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.white),
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