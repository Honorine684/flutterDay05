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
  @override
void didUpdateWidget(covariant TypeSelector oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.initialValue != oldWidget.initialValue) {
    setState(() {
      selectedType = widget.initialValue;
    });
  }
}


  final List<Map<String, dynamic>> propertyTypes = [
    {
      'type': 'appartement',
      'icon': Icons.apartment,
      'label': 'Appartement',
    },
    {
      'type': 'Maison',
      'icon': Icons.home,
      'label': 'Maison',
    },
    {
      'type': 'Studio',
      'icon': Icons.business,
      'label': 'Studio',
    },
    {
      'type': 'Duplex',
      'icon': Icons.store,
      'label': 'Duplex',
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
        Wrap(
          spacing: 10, 
          runSpacing: 10, 
          children: propertyTypes.map((type) {
            final isSelected = selectedType == type['type'];
            
            return InkWell(
              onTap: () {
                setState(() {
                  selectedType = type['type'];
                });
                widget.onTypeSelected(type['type']);
              },
              child: SizedBox(
                width: 100, 
                height: 80, 
                child: Card(
                  color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type['icon'],
                          size: 24,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        SizedBox(height: 4),
                        Text(
                          type['label'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class Step1 extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final Map<String, dynamic>? initialData;

  const Step1({
    super.key, 
    required this.onDataChanged,
    this.initialData,
  });

  @override
  State<Step1> createState() => Step1State();
}

class Step1State extends State<Step1> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titre;
  String? selectedPropertyType;

  @override
  void initState() {
    super.initState();
    
    titre = TextEditingController(text: widget.initialData?['titre'] ?? '');
    selectedPropertyType = widget.initialData?['propertyType'];
    
    titre.addListener(updateData);
  }

  @override
void didUpdateWidget(covariant Step1 oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.initialData != oldWidget.initialData) {
    setState(() {
      titre.text = widget.initialData?['titre'] ?? '';
      selectedPropertyType = widget.initialData?['propertyType'];
    });
  }
}


  void updateData() {
    widget.onDataChanged({
      'titre': titre.text,
      'propertyType': selectedPropertyType,
    });
  }

  @override
  void dispose() {
    titre.removeListener(updateData);
    titre.dispose();
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
            // Champ Titre
            TextFormField(
              controller: titre,
              decoration: const InputDecoration(
                labelText: 'Titre propriété',
                labelStyle: TextStyle(fontSize: 13),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un titre';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Sélecteur de type
            Container(
              margin: const EdgeInsets.all(8),
              height: MediaQuery.of(context).size.height * 0.3,
              child: TypeSelector(
                initialValue: selectedPropertyType,
                onTypeSelected: (type) {
                  setState(() {
                    selectedPropertyType = type;
                  });
                  updateData();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
