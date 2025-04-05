import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:houeffa_log/ui/demandelogement.dart';
import 'dart:convert';

import 'package:houeffa_log/ui/reservation.dart';

class LogementDetailsPage extends StatelessWidget {
  final DocumentSnapshot logement;

  const LogementDetailsPage({super.key, required this.logement});

  Widget _buildInfoCard(IconData icon, String label, dynamic value) {
    return value != null && value.toString().trim().isNotEmpty
        ? Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "$label : $value",
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        )
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    List<String> photos =
        [
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
              // Affichage des photos
              photos.isNotEmpty
                  ? Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          itemCount: photos.length,
                          itemBuilder:
                              (context, index) => Image.memory(
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      logement['titre'] ?? 'Sans titre',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "${logement['loyerMois'] ?? 0} FCFA/mois",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const Divider(),

              // Détails du logement
              _buildInfoCard(
                Icons.description,
                "Description",
                logement['description'],
              ),
              _buildInfoCard(Icons.location_on, "Adresse", logement['adresse']),
              _buildInfoCard(
                Icons.calendar_today,
                "Année de construction",
                logement['annee_construction']?.toString(),
              ),
              _buildInfoCard(
                Icons.bed,
                "Chambres",
                logement['chambres']?.toString(),
              ),
              _buildInfoCard(
                Icons.attach_money,
                "Loyer",
                "${logement['loyerMois'] ?? 0} FCFA/mois",
              ),
              _buildInfoCard(
                Icons.security,
                "Caution",
                "${logement['caution'] ?? 0} FCFA",
              ),
              _buildInfoCard(
                Icons.rule,
                "Conditions d'admission",
                logement['conditionAdmission'],
              ),
              _buildInfoCard(
                Icons.check_circle_outline,
                "État",
                logement['etat'],
              ),
              _buildInfoCard(
                Icons.payment,
                "Frais de visite",
                "${logement['fraisVisite'] ?? 0} FCFA",
              ),
              _buildInfoCard(
                Icons.balcony,
                "Balcons",
                logement['balcons']?.toString(),
              ),
              _buildInfoCard(
                Icons.ac_unit,
                "Climatisé",
                logement['estClimatise'] == true ? 'Oui' : 'Non',
              ),
              _buildInfoCard(
                Icons.chair,
                "Meublé",
                logement['estMeuble'] == true ? 'Oui' : 'Non',
              ),
              _buildInfoCard(
                Icons.bathtub,
                "Sanitaire",
                logement['estSanitaire'] == true ? 'Oui' : 'Non',
              ),
              _buildInfoCard(
                Icons.person,
                "Nom du propriétaire",
                logement['nomProprietaire'],
              ),
              _buildInfoCard(
                Icons.local_parking,
                "Parking",
                logement['parking']?.toString(),
              ),
              _buildInfoCard(
                Icons.shower,
                "Salles de bain",
                logement['salles_de_bain']?.toString(),
              ),
              _buildInfoCard(
                Icons.chair_alt,
                "Salons",
                logement['salons']?.toString(),
              ),
              _buildInfoCard(Icons.info, "Statut", logement['statut']),
              _buildInfoCard(
                Icons.square_foot,
                "Surface",
                logement['surface']?.toString(),
              ),
              _buildInfoCard(
                Icons.terrain,
                "Terrasses",
                logement['terrasses']?.toString(),
              ),
              _buildInfoCard(
                Icons.article,
                "Type de bail",
                logement['typeDeBail'],
              ),

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => Reservation(logementId: logement.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: const Text("Demandez une location"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DemandeLogement(logementId: logement.id),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
