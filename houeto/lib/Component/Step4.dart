import 'package:flutter/material.dart';

class Step4 extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  final Map<String, dynamic>? initialData;
  
  const Step4({
    super.key, 
    required this.onDataChanged,
    this.initialData,
  });

  @override
  State<Step4> createState() => Step4State();
}

class Step4State extends State<Step4> {
  late final TextEditingController avance;
  late final TextEditingController caution;
  late final TextEditingController total;
  late final TextEditingController loyerMois;
  late final TextEditingController loyerJour;
  final int nbreDeMoisAvance = 3;

  @override
  void initState() {
    super.initState();
    
    avance = TextEditingController(text: widget.initialData?['avance']?.toString() ?? '');
    caution = TextEditingController(text: widget.initialData?['caution']?.toString() ?? '');
    loyerMois = TextEditingController(text: widget.initialData?['loyerMois']?.toString() ?? '');
    loyerJour = TextEditingController(text: widget.initialData?['loyerJour']?.toString() ?? '');
    total = TextEditingController(text: widget.initialData?['total']?.toString() ?? '');

    avance.addListener(calculAvance);
    caution.addListener(calculAvance);
    loyerMois.addListener(calculAvance);
    loyerJour.addListener(calculAvance);
  }

  @override
  void didUpdateWidget(covariant Step4 oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialData != oldWidget.initialData) {
      setState(() {
        if (widget.initialData?['avance']?.toString() != avance.text) {
          avance.text = widget.initialData?['avance']?.toString() ?? '';
        }
        if (widget.initialData?['caution']?.toString() != caution.text) {
          caution.text = widget.initialData?['caution']?.toString() ?? '';
        }
        if (widget.initialData?['loyerMois']?.toString() != loyerMois.text) {
          loyerMois.text = widget.initialData?['loyerMois']?.toString() ?? '';
        }
        if (widget.initialData?['loyerJour']?.toString() != loyerJour.text) {
          loyerJour.text = widget.initialData?['loyerJour']?.toString() ?? '';
        }
        if (widget.initialData?['total']?.toString() != total.text) {
          total.text = widget.initialData?['total']?.toString() ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    avance.removeListener(calculAvance);
    caution.removeListener(calculAvance);
    loyerMois.removeListener(calculAvance);
    loyerJour.removeListener(calculAvance);
    
    avance.dispose();
    caution.dispose();
    total.dispose();
    loyerMois.dispose();
    loyerJour.dispose();
    
    super.dispose();
  }

  void calculAvance() {
    try {
      double montantAvance = double.tryParse(avance.text) ?? 0;
      double montantCaution = double.tryParse(caution.text) ?? 0;
      double montantLoyerMois = double.tryParse(loyerMois.text) ?? 0;
      double montantLoyerJour = double.tryParse(loyerJour.text) ?? 0;

      double montantTotal = montantAvance * nbreDeMoisAvance;

      setState(() {
        total.text = montantTotal.toStringAsFixed(2);
      });

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
      setState(() {
        total.text = '';
      });
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
                  labelStyle: TextStyle(fontSize: 13),
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
                  labelStyle: TextStyle(fontSize: 13),
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
                  labelStyle: TextStyle(fontSize: 13),
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
                  labelStyle: TextStyle(fontSize: 13),
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
                  labelStyle: TextStyle(fontSize: 13),
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
