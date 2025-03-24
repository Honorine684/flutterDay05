import 'package:flutter/material.dart';

class Step4 extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  const Step4({super.key, required this.onDataChanged});

  @override
  State<Step4> createState() {
    return Step4State();
  }
}

class Step4State extends State<Step4> {
  final avance = TextEditingController();
  final caution = TextEditingController();
  final total = TextEditingController();
  final loyerMois = TextEditingController();
  final loyerJour = TextEditingController();
  final int nbreDeMoisAvance = 3;

  @override
  void initState() {
    super.initState();
    avance.addListener(calculAvance);
    caution.addListener(calculAvance);
    loyerMois.addListener(calculAvance);
    loyerJour.addListener(calculAvance);
  }

  @override
  void dispose() {
    avance.removeListener(calculAvance);
    caution.removeListener(calculAvance);
    loyerMois.removeListener(calculAvance);
    loyerJour.removeListener(calculAvance);
    super.dispose();
  }

  void calculAvance() {
    if (avance.text.isNotEmpty) {
      try {
        double montantAvance =
            avance.text.isNotEmpty ? double.parse(avance.text) : 0;
        double montantCaution =
            caution.text.isNotEmpty ? double.parse(caution.text) : 0;
        double montantLoyerMois =
            loyerMois.text.isNotEmpty ? double.parse(loyerMois.text) : 0;
        double montantLoyerJour =
            loyerJour.text.isNotEmpty ? double.parse(loyerJour.text) : 0;

        double montantTotal = montantAvance * nbreDeMoisAvance;
        total.text = montantTotal.toStringAsFixed(2);

        widget.onDataChanged({
          'avance': montantAvance,
          'caution': montantCaution,
          'loyerMois': montantLoyerMois,
          'loyerJour': montantLoyerJour,
          'nbreDeMoisAvance': nbreDeMoisAvance,
          'total': montantTotal,
        });
      } catch (e) {
        print('Erreur lors du calcul: $e');
        total.text = '';
      }
    } else {
      total.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: avance,
                decoration: const InputDecoration(
                  labelText: 'Avance (Montant)',
                  labelStyle: TextStyle(fontSize: 13)
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: total,
                decoration: const InputDecoration(
                  labelText: 'Total',
                  labelStyle: TextStyle(fontSize: 13)
                ),
                keyboardType: TextInputType.number,
                readOnly: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: loyerMois,
                decoration: const InputDecoration(
                  labelText: 'Loyer/mois',
                  labelStyle: TextStyle(fontSize: 13)
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: loyerJour,
                decoration: const InputDecoration(
                  labelText: 'Loyer/Jour',
                  labelStyle: TextStyle(fontSize: 13)
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: caution,
                decoration: const InputDecoration(
                  labelText: 'Caution',
                  labelStyle: TextStyle(fontSize: 13)
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
