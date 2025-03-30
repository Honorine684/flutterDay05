import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:houeto/JsonModels/Logement.dart';
import 'package:houeto/Pages/NotificationsPage.dart';
import 'package:houeto/Services/Firebase/FirestoreService.dart';

class PageGestion extends StatefulWidget {
  const PageGestion({super.key});

  @override
  State<PageGestion> createState() {
    return PageGestionState();
  }
}

class PageGestionState extends State<PageGestion> {
    StreamSubscription? _logementSubscription;
  StreamSubscription? _logementConfierSubscription;
  @override
void dispose() {
  _logementSubscription?.cancel();
  _logementConfierSubscription?.cancel();
  super.dispose();
}
  String getFirstTwoWords(String address) {
    List<String> words = address.split(' ');
    return words.length > 2 ? '${words[0]} ${words[1]}' : address;
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

  List<Logement> logements = [];

  void loadLogement() {
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

    print("Chargement des logements...");

   _logementSubscription = FirestoreService().getLogement(currentUser.uid).listen((snapshot) async {
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

            listeLogement.add(Logement(
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
              creneaux: creneauxList,
            ));
          }).catchError((error) {
            print(
                "Erreur lors du chargement des créneaux pour $logementId: $error");

            listeLogement.add(Logement(
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
              creneaux: [],
            ));
          });

          creneauxFutures.add(creneauxFuture);
        } catch (e) {
          print("Erreur sur un document logement: $e");
        }
      }

      await Future.wait(creneauxFutures);

    if(mounted) {
        setState(() {
          logements = listeLogement;
          print("Logements chargés: ${logements.length}");
        });
      }
    }, 
    onError: (error) {
      print("Erreur lors du chargement des logements: $error");
    }
  );
}

  @override
  void initState() {
    loadLogement();
    loadLogementConfier();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsPage()));
            },
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Abomey-Calavi',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Benin',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche par adresse, ville, ...',
                  hintStyle: TextStyle(fontSize: 13),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Bienvenue cher HoueTo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              SafeArea(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: <Widget>[
                      ButtonsTabBar(
                        backgroundColor: Colors.blue,
                        unselectedBackgroundColor: Colors.white,
                        unselectedLabelStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          Tab(text: "Gérer moi-même"),
                          Tab(text: "Confier"),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            cartePropriete(context),
                            carteProprieteConfier(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cartePropriete(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;
    if (logements.isEmpty) {
      return Center(
        child: Text("Aucun logement géré par vous-même"),
      );
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: ListView.builder(
          itemCount: logements.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {},
              child: Card(
                elevation: 8,
                child: SizedBox(
                  width: double.infinity,
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: logements[index].photo1.isNotEmpty
                            ? Image.memory(
                                base64Decode(logements[index].photo1),
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: 150,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  "4",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(67, 58, 58, 0.475),
                                  ),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(67, 58, 58, 0.475),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${logements[index].typeProperty}- ${logements[index].titre}",
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              getFirstTwoWords(logements[index].adresse),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.bed,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  logements[index].chambres.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(67, 58, 58, 0.475),
                                      fontSize: 10),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.019,
                                ),
                                Icon(
                                  Icons.home_max_outlined,
                                  color: Color.fromRGBO(28, 21, 21, 0.475),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  logements[index].surface.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(67, 58, 58, 0.475),
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.chair,
                                  color: Color.fromRGBO(28, 21, 21, 0.475),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  'Meuble :',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                /*Text(
                         bien['meuble'],
                         style: TextStyle(
                           fontWeight: FontWeight.bold,
                           color: Color.fromRGBO(67, 58, 58, 0.475),
                           fontSize: 10
                         ),
                       ),*/
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getFormattedPrice(logements[index]),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget carteProprieteConfier(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;
    if (logementsConfier.isEmpty) {
      return Center(
        child: Text("Aucun logement confier"),
      );
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: ListView.builder(
          itemCount: logementsConfier.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {},
              child: Card(
                elevation: 8,
                child: SizedBox(
                  width: double.infinity,
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: logementsConfier[index].photo1.isNotEmpty
                            ? Image.memory(
                                base64Decode(logementsConfier[index].photo1),
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: 150,
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  "4",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(67, 58, 58, 0.475),
                                  ),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(67, 58, 58, 0.475),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${logementsConfier[index].typeProperty}- ${logementsConfier[index].titre}",
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              getFirstTwoWords(logementsConfier[index].adresse),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.bed,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  logementsConfier[index].chambres.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(67, 58, 58, 0.475),
                                      fontSize: 10),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.019,
                                ),
                                Icon(
                                  Icons.home_max_outlined,
                                  color: Color.fromRGBO(28, 21, 21, 0.475),
                                ),
                                SizedBox(
                                  width: largeurEcran * 0.01,
                                ),
                                Text(
                                  logementsConfier[index].surface.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(67, 58, 58, 0.475),
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.chair,
                                  color: Color.fromRGBO(28, 21, 21, 0.475),
                                ),
                                SizedBox(width: largeurEcran * 0.01),
                                Text(
                                  'Meuble : ${logementsConfier[index].estMeuble != null ? (logementsConfier[index].estMeuble! ? "Oui" : "Non") : "Non spécifié"}',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getFormattedPrice(logementsConfier[index]),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple),
                                )
                              ],
                            ),
                            Text(
                              logementsConfier[index].gestionnaireNom ??
                                  "gerer par vous meme",
                              style: TextStyle(fontSize: 13),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  List<Logement> logementsConfier = [];

  void loadLogementConfier() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("Aucun utilisateur connecté");
      if (mounted) {
        setState(() {
          logementsConfier = [];
        });
      }
      return;
    }

    print("Chargement des logements confier...");

   _logementConfierSubscription= FirestoreService().getLogementForWithGestionnaire(currentUser.uid).listen(
        (snapshot) async {
      print("Données reçues: ${snapshot.docs.length} logements");
      List<Logement> listeLogement = [];
      List<Future<void>> creneauxFutures = [];

      for (var doc in snapshot.docs) {
        try {
          String mode = doc.get('mode') ?? 'mode non disponible';

          if (mode != 'Confier') continue;

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

            listeLogement.add(Logement(
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
              creneaux: creneauxList,
            ));
          }).catchError((error) {
            print(
                "Erreur lors du chargement des créneaux pour $logementId: $error");

            listeLogement.add(Logement(
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
              creneaux: [],
            ));
          });

          creneauxFutures.add(creneauxFuture);
        } catch (e) {
          print("Erreur sur un document logement: $e");
        }
      }

      await Future.wait(creneauxFutures);

      if (mounted) {
        setState(() {
          logementsConfier = listeLogement;
          print("Logements Confier chargés: ${logementsConfier.length}");
        });
      }
    },
    onError: (error) {
      print("Erreur lors du chargement des logements: $error");
    }
  );
}
}