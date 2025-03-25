import 'package:flutter/material.dart';
import 'package:houeto/Component/Step5Widget/BailChoice.dart';

class Step5 extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  final Map<String, dynamic>? initialData;
  
  const Step5({
    super.key, 
    required this.onDataChanged,
    this.initialData,
  });

  @override
  State<Step5> createState() => Step5State();
}

class Step5State extends State<Step5> {
  late String selectedBail;
  late final TextEditingController condition;
  late final TextEditingController fraisVisite;

  void sendDataToParent() {
    double fraisVisiteValue = double.tryParse(fraisVisite.text) ?? 0.0;

    Map<String, dynamic> data = {
      'fraisVisite': fraisVisiteValue,
      'conditionAdmission': condition.text,
      'typeDeBail': selectedBail,
    };

    widget.onDataChanged(data);
  }

  @override
  void initState() {
    super.initState();
    selectedBail = widget.initialData?['typeDeBail'] ?? 'Mensuel';
    condition = TextEditingController(text: widget.initialData?['conditionAdmission'] ?? '');
    fraisVisite = TextEditingController(text: widget.initialData?['fraisVisite']?.toString() ?? '');

    // Ajout des écouteurs
    condition.addListener(sendDataToParent);
    fraisVisite.addListener(sendDataToParent);
  }

  @override
  void didUpdateWidget(covariant Step5 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mise à jour seulement si les données initiales changent
    if (widget.initialData != oldWidget.initialData) {
      setState(() {
        selectedBail = widget.initialData?['typeDeBail'] ?? 'Mensuel';
        condition.text = widget.initialData?['conditionAdmission'] ?? '';
        fraisVisite.text = widget.initialData?['fraisVisite']?.toString() ?? '';
      });
    }
  }

  @override
  void dispose() {
    // Nettoyage des écouteurs
    condition.removeListener(sendDataToParent);
    fraisVisite.removeListener(sendDataToParent);
    condition.dispose();
    fraisVisite.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: condition,
          decoration: const InputDecoration(
            labelText: 'Conditions (Entrez vos conditions d\'admission)',
            labelStyle: TextStyle(fontSize: 13),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Bailchoice(
                selectedBail: selectedBail,
                onEtatChanged: (String bail) {
                  setState(() {
                    selectedBail = bail;
                  });
                  sendDataToParent(); // Envoie des données après chaque sélection
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: fraisVisite,
                decoration: const InputDecoration(
                  labelText: 'Frais de visite',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
