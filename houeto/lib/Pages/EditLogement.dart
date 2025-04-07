import 'package:flutter/material.dart';
import 'package:houeto/Component/Step1.dart';
import 'package:houeto/Component/Step2.dart';
import 'package:houeto/Component/Step3.dart';
import 'package:houeto/Component/Step4.dart';
import 'package:houeto/Component/Step5.dart';
import 'package:houeto/Component/Step6.dart';
import 'package:houeto/Component/Step7.dart';
import 'package:houeto/Component/StepDuMaps.dart';
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
  bool _minDelayElapsed = false;
  List<Step> steps = [];
  @override
  void initState() {
    super.initState();
    steps = []; 
    loadInitialData();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _minDelayElapsed = true);
      }
    });
  }

  Future<void> loadInitialData() async {
    setState(() => isLoading = true);

    try {
      final doc = await FirestoreService().getLogementById(widget.logementId);

      if (doc != null && doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};

        setState(() {
          logementData = data; 
          initializeSteps();
        });
      }
    } catch (e) {
      print("Erreur lors du chargement: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

/*Future<void> loadInitialData() async {
  print("Chargement des donnees initiales");
  try {
    final doc = await FirestoreService().getLogementById(widget.logementId);

    if (doc != null && doc.exists) {
      print("Document data: ${doc.data()}"); // Debug print

      List<Jourdisponibilite> jours = [];
      try {
        final joursSnapshot = await FirestoreService().getJoursDisponibles(widget.logementId);
        jours = joursSnapshot.docs.map((d) {
          return Jourdisponibilite.fromMap(d.data() as Map<String, dynamic>);
        }).toList();
        print("Jours disponibles: $jours");
      } catch (e) {
        print("Erreur chargement jours disponibles: $e");
      }

      setState(() {
        logementData = {
          ...doc.data() as Map<String, dynamic>,
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
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}*/
  void initializeSteps() {
    final newSteps = [
      Step(
        title: Text("Informations de base"),
        content: Step1(
          onDataChanged: getStep1Data,
          initialData: logementData.isNotEmpty
              ? {
                  'titre': logementData['titre'] ?? '',
                  'propertyType': logementData['propertyType'] ?? '',
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
                  'parking': logementData['parking'],
                  'etages': logementData['etages']
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
        title: Text("Informations financiers"),
        content: Step4(
          onDataChanged: getStep4Data,
          initialData: logementData.isNotEmpty
              ? {
                  'avance': logementData['avance'],
                  'loyerMois': logementData['loyerMois'],
                  'loyerJour': logementData['loyerJour'],
                  'caution': logementData['caution'],
                }
              : null,
        ),
        isActive: true,
      ),
      /*  Step(
  title: const Text("Jour et heure de visite(si possible)"),
  content: Stephoraire(
    onDataChanged: getStep5Data,
    initialAvailability: logementData.isNotEmpty && logementData['doctorAvailability'] != null
        ? (logementData['doctorAvailability'] as List)
            .map((e) => Jourdisponibilite.fromJson(e as Map<String, dynamic>))
            .toList()
        : [],
  ),
  isActive: true,
),*/
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
    if (mounted) {
      setState(() {
        steps = newSteps;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || steps.isEmpty) {
      return LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        title: Text("Modifier un logement",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: Stepper(
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
                if (initialStep > 0)
                  ElevatedButton(
                    onPressed: details.onStepCancel,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

                          updateLogement();

                          print("Logement modifié avec succès!");
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
        titre: logementData['titre'] ?? '',
        adresse: logementData['adresse'] ?? '',
        propertyType: logementData['propertyType'] ?? '',
        surface: double.tryParse(logementData['surface']?.toString() ?? '0'),
        anneDeConstruction:
            int.tryParse(logementData['annee_construction']?.toString() ?? '0'),
        nbreDeChambre:
            int.tryParse(logementData['chambres']?.toString() ?? '0'),
        nbreDeCuisine:
            int.tryParse(logementData['cuisines']?.toString() ?? '0'),
        nbreDeSalleDeBain:
            int.tryParse(logementData['salles_de_bain']?.toString() ?? '0'),
        nbreDeSalons: int.tryParse(logementData['salons']?.toString() ?? '0'),
        nbreDeTerrasse:
            int.tryParse(logementData['terrasses']?.toString() ?? '0'),
        nbreDeBalcon: int.tryParse(logementData['balcons']?.toString() ?? '0'),
        nbreDeParking: int.tryParse(logementData['parking']?.toString() ?? '0'),
        nbreEtages: int.tryParse(logementData['etages']?.toString() ?? '0'),
        estSanitaire: logementData['estSanitaire'] ?? false,
        estMeuble: logementData['estMeuble'] ?? false,
        estClimatise: logementData['estClimatise'] ?? false,
        etat: logementData['etat'] ?? '',
        avance: double.tryParse(logementData['avance']?.toString() ?? '0'),
        loyerMois:
            double.tryParse(logementData['loyerMois']?.toString() ?? '0'),
        loyerJour:
            double.tryParse(logementData['loyerJour']?.toString() ?? '0'),
        caution: double.tryParse(logementData['caution']?.toString() ?? '0'),
        jours: logementData['doctorAvailability'] ?? [],
        conditionAdmission: logementData['conditionAdmission'] ?? '',
        typeDeBail: logementData['typeDeBail'] ?? '',
        fraisVisite:
            double.tryParse(logementData['fraisVisite']?.toString() ?? '0'),
        photo1: logementData['photo1'] ?? '',
        photo2: logementData['photo2'] ?? '',
        photo3: logementData['photo3'] ?? '',
        photo4: logementData['photo4'] ?? '',
        description: logementData['description'] ?? '',
        latitude: double.tryParse(logementData['latitude']?.toString() ?? '0'),
        longitude:
            double.tryParse(logementData['longitude']?.toString() ?? '0'),
      );
      print("Logement modifié avec succès !");

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Showbien()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logement modifié avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Erreur lors de la modification du logement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Erreur lors de la modification: ${e.toString()}")),
      );
    }
  }

  Widget LoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation avec effet de pulsation
            TweenAnimationBuilder(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade600,
                          ),
                          strokeWidth: 6,
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.home_rounded,
                        size: 50,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Texte avec effet de fondu
            AnimatedOpacity(
              opacity: _minDelayElapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  Text(
                    "Chargement...",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Veuillez patienter",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
