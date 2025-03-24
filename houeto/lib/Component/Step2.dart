import 'package:flutter/material.dart';

class Step2 extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic>? initialData;
  final Map<String, dynamic> initialValues;


  const Step2({
    super.key,
    required this.onDataChanged,
    this.initialData,
    this.initialValues = const{}
  });

  @override
  Step2State createState() => Step2State();
}

class Step2State extends State<Step2> {
  final TextEditingController surfaceController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

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

    if (widget.initialData != null) {
      surfaceController.text = widget.initialData!['surface']?.toString() ?? '';
      yearController.text = widget.initialData!['annee_construction']?.toString() ?? '';

      for (String key in counters.keys) {
        if (widget.initialData!.containsKey(key)) {
          counters[key] = widget.initialData![key];
        }
      }
    }

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
    double surface = double.tryParse(surfaceController.text) ?? 0.0;
    int anneeConstruction = int.tryParse(yearController.text) ?? 0;
    Map<String, dynamic> data = {
    'surface': surface, 
    'annee_construction': anneeConstruction, 
    ...counters, 
  };

  
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
            Expanded(
              child: TextFormField(
                controller: surfaceController,
                decoration: const InputDecoration(
                  labelText: "Surface (m²)", 
                  labelStyle: TextStyle(fontSize: 13),
                  suffixIcon:Icon(Icons.square_foot),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10,),
              Expanded(
              child: TextFormField(
                controller: yearController,
                decoration: const InputDecoration(
                  labelText: "Année de construction",
                  labelStyle: TextStyle(fontSize: 13),
                  suffixIcon:Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
                
              ],
            ),

            SizedBox(height: 10),

            SizedBox(
              height: 300,
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