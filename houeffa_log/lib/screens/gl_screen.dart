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

  void showContratDetails(BuildContext context, Map<String, dynamic> contrat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(contrat['detailsLogement']['titre'] ?? 'Détails du contrat'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("🏠 Adresse : ${contrat['detailsLogement']['adresse']}"),
              Text("💰 Avance : ${contrat['avance']} FCFA"),
              Text("🔐 Caution : ${contrat['caution']} FCFA"),
              Text("📅 Début : ${DateFormat.yMMMd().format(contrat['dateDebut'].toDate())}"),
              Text("📅 Fin : ${DateFormat.yMMMd().format(contrat['dateFin'].toDate())}"),
              const SizedBox(height: 10),
              Text("🛋️ Composition :"),
              ...contrat['composition'].entries.map<Widget>((entry) =>
                  Text("- ${entry.key} : ${entry.value}")),
              const SizedBox(height: 10),
              Text("📌 Conditions spéciales :"),
              ...List.from(contrat['conditionsSpeciales'] ?? [])
                  .map<Widget>((e) => Text("• $e")),
              const SizedBox(height: 10),
              Text("📐 Surface : ${contrat['detailsLogement']['surface']} m²"),
              Text("💸 Mode de paiement : ${contrat['modePaiement']}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Fermer'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationsStream = FirebaseFirestore.instance
        .collection('locations')
        .where('userId', isEqualTo: userId)
        .snapshots();

    final contratsStream = FirebaseFirestore.instance
        .collection('contrats')
        .where('locataireId', isEqualTo: userId)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion locative', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: locationsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text('Erreur lors du chargement des locations.');
                if (!snapshot.hasData) return const CircularProgressIndicator();

                var locations = snapshot.data!.docs;

                if (locations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Aucune location trouvée.'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    var location = locations[index];
                    var montant = (location['montant'] is int)
                        ? location['montant'].toDouble()
                        : location['montant'];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(location['nomLogement'],
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Loyer mensuel : ${montant.toStringAsFixed(2)} FCFA'),
                            Text('Statut : ${location['statut']}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: location['statut'] == 'Payé'
                              ? null
                              : () => effectuerPaiement(
                                    location.id,
                                    context,
                                    montant,
                                  ),
                          child: const Text('Payer'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const Divider(thickness: 2),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('📄 Contrats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder(
              stream: contratsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text('Erreur lors du chargement des contrats.');
                if (!snapshot.hasData) return const CircularProgressIndicator();

                var contrats = snapshot.data!.docs;

                if (contrats.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Aucun contrat disponible.'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: contrats.length,
                  itemBuilder: (context, index) {
                    var contrat = contrats[index].data() as Map<String, dynamic>;
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(contrat['detailsLogement']['titre'] ?? 'Contrat'),
                        subtitle: Text("Durée : ${contrat['duree']} ${contrat['dureeType']}"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () => showContratDetails(context, contrat),
                          child: const Text("Consulter"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}