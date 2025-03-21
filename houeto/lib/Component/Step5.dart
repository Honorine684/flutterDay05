import 'package:flutter/material.dart';
import 'package:houeto/Component/Step5Widget/BailChoice.dart';

class Step5 extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  const Step5({super.key, required this.onDataChanged});

  @override
  State<Step5> createState() {
    return Step5State();
  }
}

class Step5State extends State<Step5> {
  String selectedBail = 'Mensuel';
  final condition = TextEditingController();
  final fraisVisite = TextEditingController();

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
    condition.addListener(sendDataToParent);
    fraisVisite.addListener(sendDataToParent);
  }

  @override
  void dispose() {
    condition.removeListener(sendDataToParent);
    fraisVisite.removeListener(sendDataToParent);
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
                  sendDataToParent();
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
                onChanged: (value) {
                  sendDataToParent();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}