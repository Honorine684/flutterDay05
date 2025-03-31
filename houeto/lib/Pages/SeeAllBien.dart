import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Component/SeeAllBienWidget.dart';
import 'package:houeto/JsonModels/Logement.dart';
import 'package:houeto/Pages/PageDetails.dart';
import 'package:houeto/Services/Firebase/FirestoreService.dart';
import 'dart:convert';

class Seeallbien extends StatefulWidget {
  const Seeallbien({super.key});

  @override
  State<Seeallbien> createState() => SeeallbienState();
}

class SeeallbienState extends State<Seeallbien> {
  List<Logement> logements = [];
  List<Logement> filteredLogements = [];
  TextEditingController searchController = TextEditingController();
  StreamSubscription? _logementSubscription;

  void loadLogement() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("Aucun utilisateur connecté");
      if (mounted) {
        setState(() {
          logements = [];
        });
      }
      return;
    }

    print("Chargement des logements pour l'utilisateur ${currentUser.uid}...");

    _logementSubscription?.cancel();

    _logementSubscription = FirestoreService()
        .getLogement(currentUser.uid)
        .listen((snapshot) async {
      print("Données reçues: ${snapshot.docs.length} logements");
      List<Logement> listeLogement = [];
      List<Future<void>> creneauxFutures = [];

      for (var doc in snapshot.docs) {
        try {
          String logementId = doc.id;
          String titre = doc.get('titre') ?? 'Titre non disponible';
          String adresse = doc.get('adresse') ?? 'Adresse non disponible';
          String typeProperty =
              doc.get('propertyType') ?? 'Type non disponible';
          String photo1 = doc.get('photo1') ?? '';
          double surface = doc.get('surface') ?? 0.0;
          double latitude = doc.get('latitude') ?? 0.0;
          double longitude = doc.get('longitude') ?? 0.0;
          double loyerJour = doc.get('loyerJour') ?? 0.0;
          double loyerMois = doc.get('loyerMois') ?? 0.0;
          int chambres = doc.get('chambres') ?? 0;
          String statut = doc.get('statut') ?? 'statut non disponible';
          String mode = doc.get('mode') ?? 'mode non disponible';
          String photo2 = doc.get('photo2') ?? '';
          String photo3 = doc.get('photo3') ?? '';
          int salleDeBains = doc.get('salles_de_bain') ?? 0;
          int cuisines = doc.get('cuisines') ?? 0;
          int salons = doc.get('salons') ?? 0;
          int terrasses = doc.get('terrasses') ?? 0;
          int balcons = doc.get('balcons') ?? 0;
          int parking = doc.get('parking') ?? 0;
          int etages = doc.get('etages') ?? 0;
          String etat = doc.get('etat') ?? 'aucun etat';
          bool estSanitaire = doc.get('estSanitaire');
          bool estMeuble = doc.get('estMeuble');
          bool estClimatise = doc.get('estClimatise');
          double avance = doc.get('avance') ?? 0.0;
          String conditionAdmission =
              doc.get('conditionAdmission') ?? 'accepte tous le monde';
          String typeDeBail =
              doc.get('typeDeBail') ?? 'Aucun bail selectionner';
          double frais = doc.get('fraisVisite') ?? 0.0;
          String description =
              doc.get('description') ?? 'Aucune description ajouté';
          String gestionnaireNom =
              doc.get('gestionnaireNom') ?? 'geré par vous meme';
          Future<void> creneauxFuture = FirestoreService()
              .getCreneauxForLogement(logementId)
              .first
              .then((creneauxSnapshot) {
            List<Map<String, dynamic>> creneauxList = creneauxSnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            listeLogement.add(
              Logement(
                  id: logementId,
                  adresse: adresse,
                  titre: titre,
                  typeProperty: typeProperty,
                  latitude: latitude,
                  longitude: longitude,
                  photo1: photo1,
                  loyerJour: loyerJour,
                  loyerMois: loyerMois,
                  chambres: chambres,
                  surface: surface,
                  statut: statut,
                  balcons: balcons,
                  cuisines: cuisines,
                  etages: etages,
                  salleDeBains: salleDeBains,
                  parking: parking,
                  salons: salons,
                  fraisDeVisite: frais,
                  estClimatise: estClimatise,
                  estMeuble: estMeuble,
                  estSanitaire: estSanitaire,
                  typeDeBail: typeDeBail,
                  conditionAdmission: conditionAdmission,
                  description: description,
                  photo2: photo2,
                  photo3: photo3,
                  terrasses: terrasses,
                  avance: avance,
                  gestionnaireNom: gestionnaireNom,
                  etat: etat,
                  mode: mode,
                  creneaux: creneauxList),
            );
          }).catchError((error) {
            print(
                "Erreur lors du chargement des créneaux pour $logementId: $error");

            listeLogement.add(
              Logement(
                  id: logementId,
                  adresse: adresse,
                  titre: titre,
                  typeProperty: typeProperty,
                  latitude: latitude,
                  longitude: longitude,
                  photo1: photo1,
                  loyerJour: loyerJour,
                  loyerMois: loyerMois,
                  chambres: chambres,
                  surface: surface,
                  statut: statut,
                  balcons: balcons,
                  cuisines: cuisines,
                  etages: etages,
                  salleDeBains: salleDeBains,
                  parking: parking,
                  salons: salons,
                  fraisDeVisite: frais,
                  estClimatise: estClimatise,
                  estMeuble: estMeuble,
                  estSanitaire: estSanitaire,
                  typeDeBail: typeDeBail,
                  conditionAdmission: conditionAdmission,
                  description: description,
                  photo2: photo2,
                  photo3: photo3,
                  terrasses: terrasses,
                  avance: avance,
                  gestionnaireNom: gestionnaireNom,
                  etat: etat,
                  mode: mode,
                  creneaux: []),
            );
          });

          creneauxFutures.add(creneauxFuture);
        } catch (e) {
          print("Erreur sur un document logement: $e");
        }
      }

      await Future.wait(creneauxFutures);

      if (mounted) {
  setState(() {
    logements = listeLogement;
    filteredLogements = List.from(listeLogement); 
    print("Logements chargés: ${logements.length}");
  });
}
    }, onError: (error) {
      print("Erreur lors du chargement des logements: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    loadLogement();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    _logementSubscription?.cancel();
    super.dispose();
  }
   void onSearchChanged() {
    filterLogements();
  }
void filterLogements() {
  final query = searchController.text.toLowerCase();
  
  setState(() {
    filteredLogements = query.isEmpty
        ? List.from(logements)
        : logements.where((logement) {
            return logement.titre.toLowerCase().contains(query) ||
                   logement.adresse.toLowerCase().contains(query) ||
                   logement.typeProperty.toLowerCase().contains(query) ||
                   logement.statut.toLowerCase().contains(query);
          }).toList();
  });
}

String getFormattedPrice(Logement logement) {
    final hasMonthly = (logement.loyerMois) > 0;
    final hasDaily = (logement.loyerJour) > 0;

    if (hasMonthly && hasDaily) {
      return '${logement.loyerMois.toStringAsFixed(0)} Fcfa/mois\n'
          '${logement.loyerJour.toStringAsFixed(0)} Fcfa/jour';
    } else if (hasMonthly) {
      return '${logement.loyerMois.toStringAsFixed(0)} Fcfa/mois';
    } else if (hasDaily) {
      return '${logement.loyerJour.toStringAsFixed(0)} Fcfa/jour';
    } else {
      return 'Prix sur demande';
    }
  }
  @override
  Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
  title: TextField(
    controller: searchController,
    decoration: InputDecoration(
      hintText: 'Rechercher par titre, adresse...',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: searchController.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  searchController.clear();
                  filterLogements();
                });
              },
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    ),
    onChanged: (value) {
      filterLogements();
    },
  ),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Color(0xfff5f5f5),
        ),
        child: IconButton(
          onPressed: () {
            if (searchController.text.isEmpty) {
              filteredLogements = List.from(logements);
            }
            showRoundedBottomSheet();
          },
          icon: const Icon(Icons.filter_list),
        ),
      ),
    ),
  ],
),
      body: const SingleChildScrollView(
        child: Column(
          children: [SeeallbienwidgetMap()],
        ),
      ),
    );
  }

 void showRoundedBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${filteredLogements.length} résultats trouvés",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: filteredLogements.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageDetailsProprietaire(
                            logement: filteredLogements[index],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.88,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: filteredLogements[index].photo1.isNotEmpty
                                ? Image.memory(
                                    base64Decode(
                                        filteredLogements[index].photo1),
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${filteredLogements[index].titre} - ${filteredLogements[index].typeProperty} - ${filteredLogements[index].statut}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    filteredLogements[index].adresse,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[600]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.bed,
                                        color: Colors.grey,
                                      ),
                                      Text(
                                        "${filteredLogements[index].chambres.toString()} chambres",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.space_bar,
                                        color: Colors.grey,
                                      ),
                                      Text(
                                        "${filteredLogements[index].surface.toString()} m²",
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    getFormattedPrice(filteredLogements[index]),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}}