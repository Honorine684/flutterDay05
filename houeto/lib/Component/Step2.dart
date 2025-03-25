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
  late final TextEditingController surfaceController;
  late final TextEditingController yearController;
  late Map<String, int> counters;

  static const Map<String, IconData> icons = {
    'chambres': Icons.bed,
    'salles_de_bain': Icons.bathtub,
    'cuisines': Icons.kitchen,
    'salons': Icons.weekend,
    'terrasses': Icons.deck,
    'balcons': Icons.balcony,
    'parking': Icons.local_parking,
    'etages': Icons.stairs,
  };

  static const Map<String, String> displayNames = {
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
    
    surfaceController = TextEditingController(
      text: widget.initialData?['surface']?.toString() ?? '',
    );
    
    yearController = TextEditingController(
      text: widget.initialData?['annee_construction']?.toString() ?? '',
    );

    counters = {
      'chambres': widget.initialData?['chambres'] ?? 0,
      'salles_de_bain': widget.initialData?['salles_de_bain'] ?? 0,
      'cuisines': widget.initialData?['cuisines'] ?? 0,
      'salons': widget.initialData?['salons'] ?? 0,
      'terrasses': widget.initialData?['terrasses'] ?? 0,
      'balcons': widget.initialData?['balcons'] ?? 0,
      'parking': widget.initialData?['parking'] ?? 0,
      'etages': widget.initialData?['etages'] ?? 0,
    };

    surfaceController.addListener(_updateData);
    yearController.addListener(_updateData);
  }

@override
void didUpdateWidget(covariant Step2 oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.initialData != oldWidget.initialData) {
    setState(() {
      surfaceController.text = widget.initialData?['surface']?.toString() ?? '';
      yearController.text = widget.initialData?['annee_construction']?.toString() ?? '';
      
      counters = {
        'chambres': widget.initialData?['chambres'] ?? 0,
        'salles_de_bain': widget.initialData?['salles_de_bain'] ?? 0,
        'cuisines': widget.initialData?['cuisines'] ?? 0,
        'salons': widget.initialData?['salons'] ?? 0,
        'terrasses': widget.initialData?['terrasses'] ?? 0,
        'balcons': widget.initialData?['balcons'] ?? 0,
        'parking': widget.initialData?['parking'] ?? 0,
        'etages': widget.initialData?['etages'] ?? 0,
      };
    });
  }
}


  @override
  void dispose() {
    surfaceController
      ..removeListener(_updateData)
      ..dispose();
    yearController
      ..removeListener(_updateData)
      ..dispose();
    super.dispose();
  }

  void _updateData() {
    final data = {
      'surface': double.tryParse(surfaceController.text),
      'annee_construction': int.tryParse(yearController.text),
      ...counters,
    };
    widget.onDataChanged(data);
  }

  Widget _buildCounterItem(String key) {
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
            Row(
              children: [
                Icon(icons[key], color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  displayNames[key]!,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Row(
              children: [
                // Bouton -
                InkWell(
                  onTap: () {
                    if (counters[key]! > 0) {
                      setState(() {
                        counters[key] = counters[key]! - 1;
                        _updateData();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove, size: 16),
                  ),
                ),
                // Valeur
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 24,
                  child: Text(
                    counters[key].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
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
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, size: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                      suffixIcon: Icon(Icons.square_foot),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une surface';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: yearController,
                    decoration: const InputDecoration(
                      labelText: "Année de construction",
                      labelStyle: TextStyle(fontSize: 13),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une année';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: counters.length,
                itemBuilder: (context, index) {
                  return _buildCounterItem(counters.keys.elementAt(index));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}