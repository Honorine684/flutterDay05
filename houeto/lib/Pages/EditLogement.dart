import 'package:flutter/material.dart';
import 'package:houeto/Component/Step1.dart';
import 'package:houeto/Component/Step2.dart';
import 'package:houeto/Component/Step3.dart';
import 'package:houeto/Component/Step4.dart';
import 'package:houeto/Component/Step5.dart';
import 'package:houeto/Component/Step6.dart';
import 'package:houeto/Component/Step7.dart';
import 'package:houeto/Component/StepDuMaps.dart';
import 'package:houeto/Component/Stephoraire.dart';
import 'package:houeto/Pages/ShowBien.dart';
import 'package:houeto/Services/Firebase/FirestoreService.dart';

class Editlogement extends StatefulWidget {
  final String logementId;
  const Editlogement({super.key,required this.logementId});

  @override
  State<Editlogement> createState() {
    return EditlogementState();
  }
}

class EditlogementState extends State<Editlogement> {
  int initialStep = 0;
  Map<String, dynamic> logementData = {};

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
  void getStep9Data(Map<String, dynamic> data) {
    logementData.addAll(data);
  }

  late List<Step> steps;

  @override
  void initState() {
    super.initState();
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
        title: Text(
            "Medias(Ajouter des photos et vidéos pour valoriser le logement)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Step6(onDataChanged: getStep7Data),
        isActive: true,
      ),
      Step(
        title: Text(
            "Coordonnées géographiques(Adresse réelle)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Stepdumaps(onDataChanged: getStep8Data),
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
    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        title: Text("Modifier un logement",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
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
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (initialStep >
                            0) 
                          ElevatedButton(
                            onPressed: details.onStepCancel,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              'Annuler',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: initialStep == steps.length - 1
                              ? () async {
                                  print("Données collectées: $logementData");
                               
                                  await updateLogement();
                                  print("Logement ajouté avec succès!");
                                }
                              : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: Text(
                            initialStep == steps.length - 1
                                ? 'Confirmer'
                                : 'Continuer',
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

  Future<void> updateLogement() async {
  try {
    await FirestoreService().updateLogement(
      widget.logementId, 
      titre: logementData['titre'],
      adresse: logementData['adresse'],
      propertyType: logementData['propertyType'],
      surface: double.tryParse(logementData['surface'].toString()),
      anneDeConstruction: int.tryParse(logementData['annee_construction'].toString()),
      nbreDeChambre: int.tryParse(logementData['chambres'].toString()),
      nbreDeCuisine: int.tryParse(logementData['cuisines'].toString()),
      nbreDeSalleDeBain: int.tryParse(logementData['salles_de_bain'].toString()),
      nbreDeSalons: int.tryParse(logementData['salons'].toString()),
      nbreDeTerrasse: int.tryParse(logementData['terrasses'].toString()),
      nbreDeBalcon: int.tryParse(logementData['balcons'].toString()),
      nbreDeParking: int.tryParse(logementData['parking'].toString()),
      estSanitaire: logementData['estSanitaire'],
      estMeuble: logementData['estMeuble'],
      estClimatise: logementData['estClimatise'],
      etat: logementData['etat'],
      avance: double.tryParse(logementData['avance'].toString()),
      loyerMois: double.tryParse(logementData['loyerMois'].toString()),
      loyerJour: double.tryParse(logementData['loyerJour'].toString()),
      caution: double.tryParse(logementData['caution'].toString()),
      jours: logementData['doctorAvailability'],
      conditionAdmission: logementData['conditionAdmission'],
      typeDeBail: logementData['typeDeBail'],
      fraisVisite: double.tryParse(logementData['fraisVisite'].toString()),
      photo1: logementData['photo1'],
      photo2: logementData['photo2'],
      photo3: logementData['photo3'],
      photo4: logementData['photo4'],
      description: logementData['description'],
      latitude: double.tryParse(logementData['latitude'].toString()),
      longitude: double.tryParse(logementData['longitude'].toString()),
    );

    print("Logement modifié avec succès !");
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Showbien()));
  } catch (e) {
    print("Erreur lors de la modification du logement: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur lors de la modification: ${e.toString()}")),
    );
  }
}
}
