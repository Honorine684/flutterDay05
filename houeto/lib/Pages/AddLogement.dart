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
import 'package:houeto/JsonModels/JourDisponibilite.dart';
import 'package:houeto/Services/Firebase/FirestoreService.dart';

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
  void getStep9Data(Map<String, dynamic> data) {
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
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Bouton Annuler
                        if (initialStep >
                            0) // Afficher le bouton Annuler seulement si ce n'est pas la première étape
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
                        // Bouton Continuer ou Confirmer
                        ElevatedButton(
                          onPressed: initialStep == steps.length - 1
                              ? () async {
                                  print("Données collectées: $logementData");
                                  logementData.forEach((key, value) {
                                    print(
                                        '$key: $value (${value.runtimeType})');
                                  });
                                  addLogement();
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

  Future<void> addLogement() async {
    try {
      // Récupération et conversion des données
      String titre = logementData['titre'] ?? '';
      String adresse = logementData['adresse'] ?? '';
      String propertyType = logementData['propertyType'] ?? '';
      double surface =
          double.tryParse(logementData['surface'].toString()) ?? 0.0;
      int anneDeConstruction =
          int.tryParse(logementData['annee_construction'].toString()) ?? 0;
      int nbreDeChambre =
          int.tryParse(logementData['chambres'].toString()) ?? 0;
      int nbreDeCuisine =
          int.tryParse(logementData['cuisines'].toString()) ?? 0;
      int nbreDeSalleDeBain =
          int.tryParse(logementData['salles_de_bain'].toString()) ?? 0;
      int nbreDeSalons = int.tryParse(logementData['salons'].toString()) ?? 0;
      int nbreDeTerrasse =
          int.tryParse(logementData['terrasses'].toString()) ?? 0;
      int nbreDeBalcon = int.tryParse(logementData['balcons'].toString()) ?? 0;
      int nbreDeParking = int.tryParse(logementData['parking'].toString()) ?? 0;
      bool estSanitaire = logementData['estSanitaire'] ?? false;
      bool estMeuble = logementData['estMeuble'] ?? false;
      bool estClimatise = logementData['estClimatise'] ?? false;
      String etat = logementData['etat'] ?? '';
      double avance = double.tryParse(logementData['avance'].toString()) ?? 0.0;
      double loyerMois =
          double.tryParse(logementData['loyerMois'].toString()) ?? 0.0;
      double loyerJour =
          double.tryParse(logementData['loyerJour'].toString()) ?? 0.0;
      double caution =
          double.tryParse(logementData['caution'].toString()) ?? 0.0;
      List<Jourdisponibilite> jours = logementData['doctorAvailability'] ?? [];
      String conditionAdmission = logementData['conditionAdmission'] ?? '';
      String typeDeBail = logementData['typeDeBail'] ?? '';
      double fraisVisite =
          double.tryParse(logementData['fraisVisite'].toString()) ?? 0.0;
      String photo1 = logementData['photo1'] ?? '';
      String photo2 = logementData['photo2'] ?? '';
      String photo3 = logementData['photo3'] ?? '';
      String photo4 = logementData['photo4'] ?? '';
      String description = logementData['description'] ?? '';
      double latitude = double.tryParse(logementData['latitude'].toString()) ?? 0.0;
      double longitude = double.tryParse(logementData['longitude'].toString()) ?? 0.0;

      // Ajout du logement
      await FirestoreService().addLogement(
        titre,
        adresse,
        propertyType,
        surface,
        anneDeConstruction,
        nbreDeChambre,
        nbreDeCuisine,
        nbreDeSalleDeBain,
        nbreDeSalons,
        nbreDeTerrasse,
        nbreDeBalcon,
        nbreDeParking,
        estSanitaire,
        estMeuble,
        estClimatise,
        etat,
        avance,
        loyerMois,
        loyerJour,
        caution,
        jours,
        conditionAdmission,
        typeDeBail,
        fraisVisite,
        photo1,
        photo2,
        photo3,
        photo4,
        description,
        latitude,
        longitude
      );

      print("Logement ajouté avec succès !");
    } catch (e) {
      print("Erreur lors de l'ajout du logement: $e");
    }
  }
}
