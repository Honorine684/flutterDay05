import 'package:flutter/material.dart';
class TypeSelector extends StatefulWidget {
  final Function(String) onTypeSelected;
  final String? initialValue;

  const TypeSelector({
    super.key,
    required this.onTypeSelected,
    this.initialValue,
  });

  @override
  TypeSelectorState createState() => TypeSelectorState();
}

class TypeSelectorState extends State<TypeSelector> {
  String? selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialValue;
  }

  final List<Map<String, dynamic>> propertyTypes = [
    {
      'type': 'appartement',
      'icon': Icons.apartment,
      'label': 'Appartement',
      'color': Colors.blue,
    },
    {
      'type': 'Maison',
      'icon': Icons.home,
      'label': 'Maison',
      'color': Colors.green,
    },
    {
      'type': 'Studio',
      'icon': Icons.business,
      'label': 'Studio',
      'color': Colors.amber,
    },
    {
      'type': 'Duplex',
      'icon': Icons.store,
      'label': 'Duplex',
      'color': Colors.purple,
    },
    {
      'type': 'Villa',
      'icon': Icons.terrain,
      'label': 'Villa',
      'color': Colors.brown,
    },
  ];

@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          'Type de bien',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      // Limiter la hauteur de la GridView
      SizedBox(
        height: 200, // Ajustez cette valeur selon vos besoins
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Nombre de colonnes
            childAspectRatio: 1.1, // Ratio largeur/hauteur des éléments
            crossAxisSpacing: 10, // Espacement horizontal
            mainAxisSpacing: 10, // Espacement vertical
          ),
          itemCount: propertyTypes.length,
          itemBuilder: (context, index) {
            final type = propertyTypes[index];
            final isSelected = selectedType == type['type'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedType = type['type'];
                });
                widget.onTypeSelected(type['type']);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSelected
                      ? type['color'].withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? type['color']
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type['icon'],
                      size: 32,
                      color: isSelected
                          ? type['color']
                          : Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          type['label'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? type['color']
                                : Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}}
class Step1 extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  const Step1({super.key, required this.onDataChanged});

  @override
  State<Step1> createState() => Step1State();
}

class Step1State extends State<Step1> {
  final formKey = GlobalKey<FormState>();
  final titre = TextEditingController();
  final adresse = TextEditingController();
  String? selectedPropertyType;

  void updateData() {
    widget.onDataChanged({
      'titre': titre.text,
      'adresse': adresse.text,
      'propertyType': selectedPropertyType,
    });
  }

  @override
  void initState() {
    super.initState();
    titre.addListener(updateData);
    adresse.addListener(updateData);
  }

  @override
  void dispose() {
    titre.removeListener(updateData);
    adresse.removeListener(updateData);
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // titre
          Container(
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
              controller: titre,
              decoration: const InputDecoration(
                icon: Icon(Icons.title),
                border: InputBorder.none,
                hintText: "Titre propriété",
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "le titre est obligatoire";
                } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(titre.text)) {
                  return "Le titre ne peut contenir que des lettres";
                }
                return null;
              },
            ),
          ),
          // adresse
          Container(
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
              controller: adresse,
              decoration: const InputDecoration(
                icon: Icon(Icons.location_on),
                border: InputBorder.none,
                hintText: "Adresse(optionnel)",
              ),
            ),
          ),
          // type de bien
          Container(
            margin: const EdgeInsets.all(8),
            child: TypeSelector(
              initialValue: selectedPropertyType,
              onTypeSelected: (type) {
                setState(() {
                  selectedPropertyType = type;
                });
                updateData(); // Mettre à jour les données quand le type change
              },
            ),
          ),
        ],
      ),
    ),
  );
}}