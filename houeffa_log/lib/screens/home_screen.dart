import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:houeffa_log/screens/logementDetailsPage.dart';

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
      final snapshot =
          await FirebaseFirestore.instance.collection('logement').get();
      setState(() {
        logements = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<DocumentSnapshot> getFilteredLogements() {
    if (selectedType == 'Tous') return logements;
    return logements
        .where((logement) => logement['propertyType'] == selectedType)
        .toList();
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
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Chargement des données...',
                      style: TextStyle(color: Colors.orange))
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
                          const PopupMenuItem(value: 'Appartement', child: Text('Appartement')),
                          const PopupMenuItem(value: 'Maison', child: Text('Maison')),
                          const PopupMenuItem(value: 'Boutique', child: Text('Boutique')),
                          const PopupMenuItem(value: 'Duplexe', child: Text('Duplexe')),
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: logement['photo1'] != null &&
                                    logement['photo1'].isNotEmpty
                                ? Image.memory(
                                    base64Decode(logement['photo1']),
                                    width: MediaQuery.of(context).size.width * 0.3,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: MediaQuery.of(context).size.width * 0.3,
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          title: Text(
                            logement['titre'] ?? 'Sans titre',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${logement['adresse'] ?? 'Non spécifiée'}', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              Text('${logement['annee_construction'] ?? 'N/A'}', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              Text('${logement['chambres'] ?? 0} chambres', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              Text('${logement['loyerMois'] ?? 0} FCFA/mois', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              Text('${logement['caution'] ?? 0} caution', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              Text('${logement['conditionAdmission'] ?? 'Non spécifiée'}', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              Text('${logement['description'] ?? 'Aucune description'}', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              Text('${logement['etat'] ?? 'Non spécifié'}', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              Text('${logement['fraisVisite'] ?? 0} FCFA frais de visite', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                            ],
                          ),
                          trailing: TextButton(
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
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}