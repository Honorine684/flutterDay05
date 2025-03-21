import 'package:flutter/material.dart';
import 'package:houeto/Component/Step1.dart';
import 'package:houeto/Component/Step2.dart';
import 'package:houeto/Component/Step3.dart';
import 'package:houeto/Component/Step4.dart';
import 'package:houeto/Component/Step5.dart';
import 'package:houeto/Component/Step6.dart';
import 'package:houeto/Component/Step7.dart';
import 'package:houeto/Component/Stephoraire.dart';

class Addlogement extends StatefulWidget {
  const Addlogement({super.key});

  @override
  State<Addlogement> createState() {
    return AddlogementState();
  }
}

class AddlogementState extends State<Addlogement> {
  int initialStep = 0;
  Map<String, dynamic> logementData = {};

  // Collecter les données de chaque étape
  void getStep1Data(Map<String, dynamic> data) {
    setState(() {
      logementData.addAll(data);
    });
  }

  void getStep2Data(Map<String, dynamic> data) {
    logementData.addAll(data);
  }

  void getStep3Data(Map<String, dynamic> data) {
    logementData.addAll(data);
  }
  void getStep4Data(Map<String, dynamic> data) {
    logementData.addAll(data);
  }

  void getStep5Data(Map<String, dynamic> data) {
    logementData.addAll(data);
  }
  void getStep6Data(Map<String, dynamic> data) {
    logementData.addAll(data);
  }
  void getStep7Data(Map<String, dynamic> data) {
    logementData.addAll(data);
  }
  void getStep8Data(Map<String, dynamic> data) {
    logementData.addAll(data);
  }
  late List<Step> steps;

  @override
  void initState() {
    super.initState();
    // Initialisation des étapes
    steps = [
      Step(
        title: Text("Informations de base",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Step1(onDataChanged: getStep1Data),
        ),
        isActive: true,
      ),
      Step(
        title: Text("Caractéristiques techniques",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Step2(onDataChanged: getStep2Data),
        ),
        isActive: true,
      ),
      Step(
        title: Text("Equipements",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Step3(onDataChanged: getStep3Data),
        ),
        isActive: true,
      ),
      Step(
        title: Text("Informations financières",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Step4(onDataChanged: getStep4Data),
        ),
        isActive: true,
      ),
      Step(
        title: Text("Jour et heure de visite(si possible)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Stephoraire(onDataChanged: getStep5Data),
        isActive: true,
      ),
      Step(
        title: Text("Conditions de visite",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Step5(onDataChanged: getStep6Data),
        isActive: true,
      ),
    Step(
        title: Text("Medias(Ajouter des photos et vidéos pour valoriser le logement)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Step6(onDataChanged: getStep7Data),
        isActive: true,
      ),
    Step(
        title: Text("Confirmation",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Step7(onDataChanged: getStep8Data),
        isActive: true,
        state: StepState.complete,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
   // final hauteurEcran = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        title: Text("Ajouter un logement",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Utilisation d'Expanded pour permettre le défilement du contenu
          Expanded(
            child: SingleChildScrollView(
              child: Stepper(
                currentStep: initialStep,
                type: StepperType.vertical,
                steps: steps,
                onStepTapped: (value) {
                  setState(() {
                    initialStep = value;
                  });
                },
                onStepContinue: () {
                  setState(() {
                    if (initialStep < steps.length - 1) {
                      initialStep = initialStep + 1;
                    } else {
                      print("Données collectées: $logementData");
                    }
                  });
                },
                onStepCancel: () {
                  setState(() {
                    if (initialStep > 0) {
                      initialStep = initialStep - 1;
                    } else {
                      initialStep = 0;
                    }
                  });
                },
                controlsBuilder: (BuildContext context, ControlsDetails details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Bouton Annuler
                        if (initialStep > 0) // Afficher le bouton Annuler seulement si ce n'est pas la première étape
                          ElevatedButton(
                            onPressed: details.onStepCancel,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              'Annuler',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        // Bouton Continuer ou Confirmer
                        ElevatedButton(
                          onPressed: initialStep == steps.length - 1
                              ? () async {
                                 print("Données collectées: $logementData");
                                  print("Logement ajouté avec succès!");
                                }
                              : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            initialStep == steps.length - 1 ? 'Confirmer' : 'Continuer',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}