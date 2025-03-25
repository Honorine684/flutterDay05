import 'package:flutter/material.dart';
import 'package:houeto/Component/Step3Widget/EtatChoice.dart';

class Step3 extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  final Map<String, dynamic>? initialData;
  
  const Step3({
    super.key,
    required this.onDataChanged,
    this.initialData,
  });

  @override
  Step3State createState() => Step3State();
}

class Step3State extends State<Step3> {
  late String selectedEtat;
  late bool isSanitaire;
  late bool isMeuble;
  late bool estClimatise;

  void sendDataToParent() {
    Map<String, dynamic> data = {
      'estSanitaire': isSanitaire,
      'estMeuble': isMeuble,
      'estClimatise': estClimatise,
      'etat': selectedEtat
    };

    widget.onDataChanged(data); 
  }

  @override
  void initState() {
    selectedEtat = widget.initialData?['etat'] ?? 'Neuf';
    isSanitaire = widget.initialData?['estSanitaire'] ?? false;
    isMeuble = widget.initialData?['estMeuble'] ?? false;
    estClimatise = widget.initialData?['estClimatise'] ?? false;
    
    super.initState();
    sendDataToParent();
  }

  @override
  void didUpdateWidget(covariant Step3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      setState(() {
        selectedEtat = widget.initialData?['etat'] ?? 'Neuf';
        isSanitaire = widget.initialData?['estSanitaire'] ?? false;
        isMeuble = widget.initialData?['estMeuble'] ?? false;
        estClimatise = widget.initialData?['estClimatise'] ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), 
      child: Column(
        children: [
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sanitaire?", style: TextStyle(fontSize: 14)),
              Row(
                children: [
                  Text(
                    isSanitaire ? "Oui" : "Non",
                    style: TextStyle(
                      fontSize: 14,
                      color: isSanitaire ? Colors.blue : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8), 
                  Switch(
                    value: isSanitaire,
                    onChanged: (value) {
                      setState(() {
                        isSanitaire = value;
                        sendDataToParent();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Meublé?", style: TextStyle(fontSize: 14)),
              Row(
                children: [
                  Text(
                    isMeuble ? "Oui" : "Non",
                    style: TextStyle(
                      fontSize: 14,
                      color: isMeuble ? Colors.blue : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  Switch(
                    value: isMeuble,
                    onChanged: (value) {
                      setState(() {
                        isMeuble = value;
                        sendDataToParent();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Est climatisé?", style: TextStyle(fontSize: 14)),
              Row(
                children: [
                  Text(
                    estClimatise ? "Oui" : "Non",
                    style: TextStyle(
                      fontSize: 14,
                      color: estClimatise ? Colors.blue : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  Switch(
                    value: estClimatise,
                    onChanged: (value) {
                      setState(() {
                        estClimatise = value;
                        sendDataToParent();
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Etatchoice(
            selectedEtat: selectedEtat,
            onEtatChanged: (String etat) {
              setState(() {
                selectedEtat = etat;
                sendDataToParent();
              });
            },
          ), 
        ],
      ),
    );
  }
}