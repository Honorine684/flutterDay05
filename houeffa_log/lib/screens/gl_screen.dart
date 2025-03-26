import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion locative', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('locations')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Une erreur est survenue, veuillez réessayer.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var locations = snapshot.data!.docs;

          // Vérification si aucune location n'est trouvée
          if (locations.isEmpty) {
            return const Center(
              child: Text('Aucune location trouvée.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
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
    );
  }
}