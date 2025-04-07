import 'package:flutter/material.dart';

class ContractPage extends StatelessWidget {
  final Map<String, dynamic> contratData;

  const ContractPage({super.key, required this.contratData});

  @override
  Widget build(BuildContext context) {
    final details = contratData['detailsLogement'];
    final composition = contratData['composition'];
    final conditions = contratData['conditionsSpeciales'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du contrat"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              details['titre'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSection("📍 Adresse", details['adresse']),
            _buildSection("🧾 Type de bail", contratData['typeBail']),
            _buildSection("📅 Durée", "${contratData['duree']} ${contratData['dureeType']}"),
            _buildSection("💵 Mode de paiement", contratData['modePaiement']),
            _buildSection("📆 Date de début", contratData['dateDebut'].toString()),
            _buildSection("📆 Date de fin", contratData['dateFin'].toString()),
            const Divider(height: 32),
            _buildSection("🏠 Composition", 
              "Chambres: ${composition['chambres']}, "
              "Salons: ${composition['salons']}, "
              "Cuisines: ${composition['cuisines']}, "
              "Salles de bain: ${composition['sallesBain']}, "
              "Parking: ${composition['parking']}"
            ),
            const SizedBox(height: 10),
            _buildSection("🪑 Conditions spéciales", 
              conditions.join("\n")
            ),
            const Divider(height: 32),
            _buildSection("💲 Loyer mensuel", "${contratData['loyerMois']} FCFA"),
            _buildSection("💲 Avance", "${contratData['avance']} FCFA"),
            _buildSection("💲 Caution", "${contratData['caution']} FCFA"),
            _buildSection("💰 Total initial à payer", "${contratData['totalInitial']} FCFA"),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(
                      montant: contratData['totalInitial'],
                      contratId: contratData['locationId'],
                    ),
                  ),
                );
              },
              child: const Text(
                "Passer au paiement",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  final int montant;
  final String contratId;

  const PaymentPage({super.key, required this.montant, required this.contratId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement")),
      body: Center(
        child: Text(
          "Montant à payer : $montant FCFA\nContrat ID : $contratId",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}