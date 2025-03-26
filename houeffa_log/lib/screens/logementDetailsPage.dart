import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class LogementDetailsPage extends StatelessWidget {
  final DocumentSnapshot logement;

  const LogementDetailsPage({super.key, required this.logement});

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label : ${value ?? 'Non spécifié'}",
              style: TextStyle(color: Colors.black.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> photos = [
  logement['photo1'],
  logement['photo2'],
  logement['photo3'],
  ].whereType<String>().where((photo) => photo.isNotEmpty).toList();


    return Scaffold(
      appBar: AppBar(
        title: Text(logement['titre'] ?? 'Détails du logement'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              photos.isNotEmpty
                  ? Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            itemCount: photos.length,
                            itemBuilder: (context, index) => Image.memory(
                              base64Decode(photos[index]),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            photos.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
              const SizedBox(height: 16),
              Text(
                logement['titre'] ?? 'Sans titre',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildInfoRow(Icons.location_on, "Adresse", logement['adresse']),
              _buildInfoRow(Icons.calendar_today, "Année de construction", logement['annee_construction']?.toString()),
              _buildInfoRow(Icons.bed, "Chambres", logement['chambres']?.toString()),
              _buildInfoRow(Icons.attach_money, "Loyer", "${logement['loyerMois'] ?? 0} FCFA/mois"),
              _buildInfoRow(Icons.security, "Caution", "${logement['caution'] ?? 0} FCFA"),
              _buildInfoRow(Icons.description, "Description", logement['description']),
              _buildInfoRow(Icons.rule, "Conditions d'admission", logement['conditionAdmission']),
              _buildInfoRow(Icons.check_circle_outline, "État", logement['etat']),
              _buildInfoRow(Icons.payment, "Frais de visite", "${logement['fraisVisite'] ?? 0} FCFA"),
              _buildInfoRow(Icons.balcony, "Balcons", logement['balcons']?.toString()),
              _buildInfoRow(Icons.ac_unit, "Climatisé", logement['estClimatise'] == true ? 'Oui' : 'Non'),
              _buildInfoRow(Icons.chair, "Meublé", logement['estMeuble'] == true ? 'Oui' : 'Non'),
              _buildInfoRow(Icons.bathtub, "Sanitaire", logement['estSanitaire'] == true ? 'Oui' : 'Non'),
              _buildInfoRow(Icons.person, "Nom du propriétaire", logement['nomProprietaire']),
              _buildInfoRow(Icons.local_parking, "Parking", logement['parking']?.toString()),
              _buildInfoRow(Icons.shower, "Salles de bain", logement['salles_de_bain']?.toString()),
              _buildInfoRow(Icons.chair_alt, "Salons", logement['salons']?.toString()),
              _buildInfoRow(Icons.info, "Statut", logement['statut']),
              _buildInfoRow(Icons.square_foot, "Surface", logement['surface']?.toString()),
              _buildInfoRow(Icons.terrain, "Terrasses", logement['terrasses']?.toString()),
              _buildInfoRow(Icons.article, "Type de bail", logement['typeDeBail']),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: const Text("Prendre un rendez-vous"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Action à définir (Appel ou message)
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}