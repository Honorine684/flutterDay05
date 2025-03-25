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
              logement['photo1'] != null && logement['photo1'].isNotEmpty
                  ? Image.memory(
                      base64Decode(logement['photo1']),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
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
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.phone, color: Colors.white),
                label: const Text("Contacter l'agence"),
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