import 'package:flutter/material.dart';
import 'package:houeto/Component/Step3Widget/EtatChoice.dart';

class Step3 extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  const Step3({super.key,required this.onDataChanged});

  @override
  Step3State createState() => Step3State();
}

class Step3State extends State<Step3> {
  String selectedEtat = 'Neuf';
  bool isSanitaire = false;
  bool isMeuble = false;
  bool estClimatise = false;
    void sendDataToParent() {
    Map<String, dynamic> data = {
      'estSanitaire': isSanitaire,
      'estMeuble': isMeuble,
      'estClimatise':estClimatise,
      'etat':selectedEtat
    };

    widget.onDataChanged(data); // Appel du callback avec les données
  }
@override
  void initState() {
    sendDataToParent();
    super.initState();
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
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16,),
      Etatchoice(
          selectedEtat: selectedEtat,
          onEtatChanged: (String etat) {
            setState(() {
              selectedEtat = etat;
            });
            sendDataToParent(); // Envoie des données après modification de l'atet
          },
        ),
        ],
      ),
    );
  }
}