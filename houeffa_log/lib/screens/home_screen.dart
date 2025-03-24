import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  List<DocumentSnapshot> logements = [];
  String selectedType = 'Tous';

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
      });
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
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
        title: const Text('Cherchez votre idéal !'),
        actions: [
          DropdownButton<String>(
            value: selectedType,
            items: ['Tous', 'Maison', 'Appartement', 'Boutique']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedType = value!;
              });
            },
          ),
        ],
      ),
      body: logements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                    title: Text(logement['titre'] ?? 'Sans titre'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Adresse: ${logement['adresse'] ?? 'Non spécifiée'}'),
                        Text('Année de construction: ${logement['annee_construction'] ?? 'N/A'}'),
                        Text('Chambres: ${logement['chambres'] ?? 0}'),
                        Text('Loyer: ${logement['loyerMois'] ?? 0} FCFA/mois'),
                        Text('Caution: ${logement['caution'] ?? 0}'),
                        Text('Condition d\'admission: ${logement['conditionAdmission'] ?? 'Non spécifiée'}'),
                        Text('Description: ${logement['description'] ?? 'Aucune description'}'),
                        Text('État: ${logement['etat'] ?? 'Non spécifié'}'),
                        Text('Frais de visite: ${logement['fraisVisite'] ?? 0} FCFA'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}