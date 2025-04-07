import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GestionLocativeScreen extends StatelessWidget {
  final String userId;

  const GestionLocativeScreen({super.key, required this.userId});

  Future<void> effectuerPaiement(String locationId, BuildContext context, double montant) async {
    try {
      await FirebaseFirestore.instance.collection('paiements').add({
        'userId': userId,
        'locationId': locationId,
        'montant': montant,
        'date': DateTime.now(),
        'statut': 'Payé',
      });

      await FirebaseFirestore.instance.collection('locations').doc(locationId).update({
        'statut': 'Payé',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paiement effectué avec succès. Reçu envoyé par email !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du paiement : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void afficherContrat(BuildContext context, Map<String, dynamic> contrat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contrat de location", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text("• Avance : ${contrat['avance']} FCFA"),
              Text("• Caution : ${contrat['caution']} FCFA"),
              Text("• Durée : ${contrat['duree']} ${contrat['dureeType']}"),
              const SizedBox(height: 10),
              Text("📌 Composition du logement :"),
              ...((contrat['composition'] as Map<String, dynamic>).entries).map((e) => Text("• ${e.key} : ${e.value}")),
              const SizedBox(height: 10),
              Text("📋 Conditions spéciales :"),
              ...((contrat['conditionsSpeciales'] as List).map((e) => Text("✓ $e"))),
              const SizedBox(height: 10),
              Text("📅 Dates :"),
              Text("• Début : ${DateFormat('dd/MM/yyyy').format((contrat['dateDebut'] as Timestamp).toDate())}"),
              Text("• Fin : ${DateFormat('dd/MM/yyyy').format((contrat['dateFin'] as Timestamp).toDate())}"),
              const SizedBox(height: 10),
              Text("📍 Adresse : ${contrat['detailsLogement']['adresse']}"),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma gestion locative', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('locations')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, locationSnapshot) {
          if (locationSnapshot.hasError) {
            return const Center(child: Text('Erreur de chargement.'));
          }

          if (!locationSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var locations = locationSnapshot.data!.docs;

          if (locations.isEmpty) {
            return const Center(child: Text('Aucune location trouvée.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              var location = locations[index];
              var montant = (location['montant'] is int)
                  ? location['montant'].toDouble()
                  : location['montant'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: FirebaseFirestore.instance
                    .collection('contrats')
                    .where('locataireId', isEqualTo: userId)
                    .where('logementId', isEqualTo: location['logementId'])
                    .limit(1)
                    .get()
                    .then((snapshot) =>
                        snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null),
                builder: (context, contratSnapshot) {
                  if (contratSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var contrat = contratSnapshot.data;

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(location['nomLogement'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text("Loyer : ${montant.toStringAsFixed(0)} FCFA/mois"),
                          Text("Statut : ${location['statut']}"),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: location['statut'] == 'Payé'
                                    ? null
                                    : () => effectuerPaiement(location.id, context, montant),
                                icon: const Icon(Icons.payment),
                                label: const Text("Payer"),
                              ),
                              const SizedBox(width: 12),
                              if (contrat != null)
                                OutlinedButton.icon(
                                  onPressed: () => afficherContrat(context, contrat),
                                  icon: const Icon(Icons.description_outlined),
                                  label: const Text("Consulter contrat"),
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}