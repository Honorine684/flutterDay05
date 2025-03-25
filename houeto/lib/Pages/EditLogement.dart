import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:houeto/Pages/ShowBien.dart';
import 'package:houeto/Services/Firebase/FirestoreService.dart';

class Editlogement extends StatefulWidget {
  final String logementId;
  const Editlogement({super.key, required this.logementId});

  @override
  State<Editlogement> createState() {
    return EditlogementState();
  }
}

class EditlogementState extends State<Editlogement> {
  bool isLoading = false;
  int initialStep = 0;
  Map<String, dynamic> logementData = {};
  Future<void> loadInitialData() async {
    print("Chargement des donnees initiales");
    try {
      final doc = await FirebaseFirestore.instance
          .collection('logement')
          .doc(widget.logementId)
          .get();

      if (doc.exists) {
        print("Document data: ${doc.data()}"); // Debug print

        List<Jourdisponibilite> jours = [];
        try {
          final joursSnapshot =
              await doc.reference.collection('joursDisponibles').get();
          jours = joursSnapshot.docs.map((d) {
            return Jourdisponibilite.fromMap(d.data());
          }).toList();
          print("Jours disponibles: $jours");
        } catch (e) {
          print("Erreur chargement jours disponibles: $e");
        }

        setState(() {
          logementData = {
            ...doc.data()!,
            'doctorAvailability': jours,
          };
          print("LogementData apres chargement: $logementData");
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des données: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement: ${e.toString()}")),
      );
    }
  }

  void getStep1Data(Map<String, dynamic> data) {
    logementData.addAll(data);
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
    loadInitialData();
    steps = [
      Step(
        title: Text("Informations de base"),
        content: Step1(
          onDataChanged: getStep1Data,
          initialData: logementData.isNotEmpty
              ? {
                  'titre': logementData['titre'],
                  'propertyType': logementData['propertyType'],
                }
              : null,
        ),
        isActive: true,
      ),
      Step(
        title: Text("Caractéristiques techniques"),
        content: Step2(
          onDataChanged: getStep2Data,
          initialData: logementData.isNotEmpty
              ? {
                  'surface': logementData['surface'],
                  'annee_construction': logementData['annee_construction'],
                  'chambres': logementData['chambres'],
                  'salles_de_bain': logementData['salles_de_bain'],
                  'cuisines': logementData['cuisines'],
                  'salons': logementData['salons'],
                  'terrasses': logementData['terrasses'],
                  'balcons': logementData['balcons'],
                }
              : null,
        ),
        isActive: true,
      ),
      Step(
        title: Text("Equipements"),
        content: Step3(
          onDataChanged: getStep3Data,
          initialData: logementData.isNotEmpty
              ? {
                  'estSanitaire': logementData['estSanitaire'],
                  'estMeuble': logementData['estMeuble'],
                  'estClimatise': logementData['estClimatise'],
                  'etat': logementData['etat'],
                }
              : null,
        ),
        isActive: true,
      ),
      Step(
        title: Text("Equipements"),
        content: Step4(
          onDataChanged: getStep4Data,
          initialData: logementData.isNotEmpty
              ? {
                  'avance': logementData['avance'],
                  'loyerMois': logementData['loyerMois'],
                  'caution': logementData['caution'],
                }
              : null,
        ),
        isActive: true,
      ),
      Step(
        title: Text("Jour et heure de visite(si possible)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Stephoraire(
          onDataChanged: getStep5Data,
          initialAvailability: logementData['doctorAvailability'] ?? [],
        ),
        isActive: true,
      ),
      Step(
        title: Text("Conditions de visite",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Step5(
          onDataChanged: getStep6Data,
          initialData: logementData.isNotEmpty
              ? {
                  'conditionAdmission': logementData['conditionAdmission'],
                  'typeDeBail': logementData['typeDeBail'],
                  'fraisVisite': logementData['fraisVisite'],
                }
              : null,
        ),
        isActive: true,
      ),
      Step(
        title: Text("Medias"),
        content: Step6(
          onDataChanged: getStep7Data,
          initialData: logementData.isNotEmpty
              ? {
                  'photo1': logementData['photo1'],
                  'photo2': logementData['photo2'],
                  'photo3': logementData['photo3'],
                  'photo4': logementData['photo4'],
                }
              : null,
        ),
        isActive: true,
      ),
      Step(
        title: Text("Coordonnées géographiques(Adresse réelle)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Stepdumaps(
          onDataChanged: getStep8Data,
          initialData: logementData.isNotEmpty
              ? {
                  'latitude': logementData['latitude'],
                  'longitude': logementData['longitude'],
                  'adresse': logementData['adresse'],
                }
              : null,
        ),
        isActive: true,
      ),
      Step(
        title: Text("Confirmation",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Step7(
          onDataChanged: getStep9Data,
          initialData: logementData.isNotEmpty
              ? {
                  'description': logementData['description'],
                }
              : null,
        ),
        isActive: true,
        state: StepState.complete,
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
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
                        if (initialStep > 0)
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
      if (logementData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Aucune modification détectée")),
        );
        return;
      }
      await FirestoreService().updateLogement(
        widget.logementId,
        titre: logementData['titre'],
        adresse: logementData['adresse'],
        propertyType: logementData['propertyType'],
        surface: double.tryParse(logementData['surface'].toString()),
        anneDeConstruction:
            int.tryParse(logementData['annee_construction'].toString()),
        nbreDeChambre: int.tryParse(logementData['chambres'].toString()),
        nbreDeCuisine: int.tryParse(logementData['cuisines'].toString()),
        nbreDeSalleDeBain:
            int.tryParse(logementData['salles_de_bain'].toString()),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logement modifié avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Showbien()));
    } catch (e) {
      print("Erreur lors de la modification du logement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Erreur lors de la modification: ${e.toString()}")),
      );
    }
  }
}
