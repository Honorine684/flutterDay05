import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesScreen extends StatefulWidget {
  final String logementId;

  const ServicesScreen({super.key, required this.logementId});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _nomLogementController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> services = [
    "Nettoyage et entretien",
    "Réparations d'urgence",
    "Service de jardinage",
    "Dépannage électroménager",
    "Désinsectisation",
    "Déménagement assisté",
    "Installation d'équipements",
    "Peinture et rénovation légère",
    "Vérification technique",
  ];

  Future<void> envoyerDemandeService(String service) async {
    if (_nomLogementController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs avant d\'envoyer votre demande.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('demandes_services').add({
      'logementId': widget.logementId,
      'nomLogement': _nomLogementController.text,
      'service': service,
      'description': _descriptionController.text,
      'date': DateTime.now(),
      'statut': 'En attente',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demande de "$service" envoyée avec succès !'),
        backgroundColor: Colors.green,
      ),
    );

    _descriptionController.clear(); // Nettoyage du champ de description
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services à la demande', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomLogementController,
              decoration: const InputDecoration(
                labelText: 'Nom du logement',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description détaillée de la demande',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(services[index]),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await envoyerDemandeService(services[index]);
                        },
                        child: const Text('Demander'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}