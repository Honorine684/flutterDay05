import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:houeffa_log/screens/logementDetailsPage.dart';
import 'package:houeffa_log/ui/notificationpush.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  List<DocumentSnapshot> logements = [];
  String selectedType = 'Tous';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('logement').get();
      setState(() {
        logements = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement des logements : $e')),
      );
    }
  }

  List<DocumentSnapshot> getFilteredLogements() {
    if (selectedType == 'Tous') return logements;
    return logements.where((logement) => logement['propertyType'] == selectedType).toList();
  }

  // Fonction pour récupérer une notification de visite acceptée (exemple)
  Future<String?> _fetchAcceptedVisiteNotificationId() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('visiteNotification')
          .where('statut', isEqualTo: 'Acceptée') 
          .limit(1) 
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id; 
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des notifications : $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Votre logement idéal à portée de main',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () async {
              
              final visiteId = await _fetchAcceptedVisiteNotificationId();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(
                    title: "Notifications",
                    body: "Consultez vos dernières notifications ici.",
                    logementId: null, 
                  ),
                ),
              );
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    'Chargement des données...',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  color: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Rechercher...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: PopupMenuButton<String>(
                        icon: const Icon(Icons.filter_list),
                        onSelected: (value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'Tous', child: Text('Tous')),
                          const PopupMenuItem(value: 'appartement', child: Text('Appartement')),
                          const PopupMenuItem(value: 'Maison', child: Text('Maison')),
                          const PopupMenuItem(value: 'Boutique', child: Text('Boutique')),
                          const PopupMenuItem(value: 'Duplex', child: Text('Duplex')),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: getFilteredLogements().length,
                    itemBuilder: (context, index) {
                      final logement = getFilteredLogements()[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: logement['photo1'] != null && logement['photo1'].isNotEmpty
                                  ? Image.memory(
                                      base64Decode(logement['photo1']),
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: double.infinity,
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    logement['titre'] ?? 'Sans titre',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${logement['adresse'] ?? 'Non spécifiée'}',
                                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                  ),
                                  Text(
                                    '${(logement['description'] ?? 'Aucune description').length > 60 ? logement['description'].substring(0, 60) : logement['description']}...',
                                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.bed, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text('${logement['chambres'] ?? 0} ch.'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.square_foot, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text('${logement['surface'] ?? 'N/D'} m²'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.info, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(logement['statut'] ?? 'N/D'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LogementDetailsPage(logement: logement),
                                          ),
                                        );
                                      },
                                      child: const Text('Voir plus'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}