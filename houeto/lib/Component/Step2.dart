import 'package:flutter/material.dart';

class Step2 extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic>? initialData;

  const Step2({
    super.key,
    required this.onDataChanged,
    this.initialData,
  });

  @override
  Step2State createState() => Step2State();
}

class Step2State extends State<Step2> {
  // Contrôleurs pour la surface et l'année de construction
  final TextEditingController surfaceController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  // Compteurs pour les différentes pièces
  Map<String, int> counters = {
    'chambres': 0,
    'salles_de_bain': 0,
    'cuisines': 0,
    'salons': 0,
    'terrasses': 0,
    'balcons': 0,
    'parking': 0,
    'etages': 0,
  };

  // Liste des icônes associées à chaque type de pièce
  final Map<String, IconData> icons = {
    'chambres': Icons.bed,
    'salles_de_bain': Icons.bathtub,
    'cuisines': Icons.kitchen,
    'salons': Icons.weekend,
    'terrasses': Icons.deck,
    'balcons': Icons.balcony,
    'parking': Icons.local_parking,
    'etages': Icons.stairs,
  };

  // Noms d'affichage pour chaque type
  final Map<String, String> displayNames = {
    'chambres': 'Chambres',
    'salles_de_bain': 'Salles de bain',
    'cuisines': 'Cuisines',
    'salons': 'Salons',
    'terrasses': 'Terrasses',
    'balcons': 'Balcons',
    'parking': 'Parking',
    'etages': 'Étages',
  };

  @override
  void initState() {
    super.initState();

    // Initialiser les données si elles sont fournies
    if (widget.initialData != null) {
      surfaceController.text = widget.initialData!['surface']?.toString() ?? '';
      yearController.text = widget.initialData!['annee_construction']?.toString() ?? '';

      // Initialiser les compteurs
      for (String key in counters.keys) {
        if (widget.initialData!.containsKey(key)) {
          counters[key] = widget.initialData![key];
        }
      }
    }

    // Ajouter des écouteurs
    surfaceController.addListener(_updateData);
    yearController.addListener(_updateData);
  }

  @override
  void dispose() {
    surfaceController.removeListener(_updateData);
    yearController.removeListener(_updateData);
    surfaceController.dispose();
    yearController.dispose();
    super.dispose();
  }

  void _updateData() {
    // Créer un Map avec toutes les données
    Map<String, dynamic> data = {
      'surface': surfaceController.text.isNotEmpty ? int.tryParse(surfaceController.text) : null,
      'annee_construction': yearController.text.isNotEmpty ? int.tryParse(yearController.text) : null,
      ...counters,
    };

    // Transmettre les données au parent
    widget.onDataChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Surface
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: TextFormField(
                      controller: surfaceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.square_foot),
                        border: InputBorder.none,
                        hintText: "Surface (m²)",
                      ),
                    ),
                  ),
                ),

                // Année de construction
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: TextFormField(
                      controller: yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        border: InputBorder.none,
                        hintText: "Année de construction",
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            // Liste des compteurs pour les différentes pièces
            SizedBox(
              height: 300, // Hauteur fixe pour la ListView
              child: ListView.builder(
                itemCount: counters.length,
                itemBuilder: (context, index) {
                  String key = counters.keys.elementAt(index);
                  int value = counters[key]!;
                  String displayName = displayNames[key]!;
                  IconData icon = icons[key]!;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icône et nom
                          Row(
                            children: [
                              Icon(icon, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                displayName,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),

                          // Contrôles + et -
                          Row(
                            children: [
                              // Bouton -
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (counters[key]! > 0) {
                                      counters[key] = counters[key]! - 1;
                                      _updateData();
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.remove, size: 16),
                                ),
                              ),

                              // Valeur actuelle
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                width: 24,
                                child: Text(
                                  value.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              // Bouton +
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    counters[key] = counters[key]! + 1;
                                    _updateData();
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.add, size: 16, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ],
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