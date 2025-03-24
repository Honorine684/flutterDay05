import 'package:flutter/material.dart';
import 'package:houeto/JsonModels/Logement.dart';
import 'package:houeto/Pages/EditLogement.dart';
import 'package:houeto/Services/Firebase/FirestoreService.dart';

class Showbien extends StatefulWidget {
  const Showbien({super.key});

  @override
  State<Showbien> createState() {
    return ShowbienState();
  }
}

class ShowbienState extends State<Showbien> {
void showAlertDialogConfirmDelete(String id) {
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmation"),
        content: Text("Êtes-vous sûr de vouloir supprimer ce produit ?"),
        actions: [
          
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child: Text("Non"),
          ),
          TextButton(
            onPressed: () async {
                FirestoreService().deleteLogement(id);
                Navigator.of(context).pop();
            },
            child: Text("Confirmer"),
          ),
        ],
      );
    },
  );
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
    print("Chargement des logements...");

    FirestoreService().getLogement().listen((snapshot) {
      print("Données reçues: ${snapshot.docs.length} logements");
      List<Logement> listeLogement = [];

      for (var doc in snapshot.docs) {
        try {
          String logementId = doc.id;
          String titre = doc.get('titre') ?? 'Titre non disponible';
          String adresse = doc.get('adresse') ?? 'Adresse non disponible';
          String typeProperty =
              doc.get('propertyType') ?? 'Type non disponible';
          String photo1 = doc.get('photo1') ?? '';
          double superficie = doc.get('surface') ?? 0.0;
          double latitude = doc.get('latitude') ?? 0.0;
          double longitude = doc.get('longitude') ?? 0.0;
          double loyerJour = doc.get('loyerJour') ?? 0.0;
          double loyerMois = doc.get('loyerMois') ?? 0.0;
          int chambres = doc.get('chambres') ?? 0;

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
              superficie: superficie,
            ),
          );
        } catch (e) {
          print("Erreur sur un document logement: $e");
        }
      }
      setState(() {
        logements = listeLogement;
        print("Logements chargés: ${logements.length}");
      });
    }, onError: (error) {
      print("Erreur lors du chargement des logements: $error");
    });
  }

  @override
  void initState() {
    loadLogement();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;
    final hauteurEcran = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(
              width: largeurEcran * 0.25,
            ),
            const Text(
              "HoueTo",
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.filter))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  "Mes biens",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Row(
              children: [
                Text(
                  "Ajoutez votre bien immobilier et commencez à\n bénéficier de ce dernier.",
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
            SizedBox(height: hauteurEcran * 0.03),
            SizedBox(
              height: hauteurEcran * 0.7,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: logements.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      color: Colors.white,
                      child: SizedBox(
                        width: largeurEcran * 0.85,
                        height: hauteurEcran * 0.22,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    logements[index].typeProperty,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getFirstTwoWords(logements[index].adresse),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          showAlertDialogConfirmDelete(logements[index].id
                                          );
                                        },
                                        icon:
                                            const Icon(Icons.delete, size: 30),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=> Editlogement(logementId: logements[index].id)));
                                        },
                                        icon: const Icon(Icons.edit, size: 30),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "Voir plus",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "Prix",
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      Text(
                                        getFormattedPrice(logements[index]),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
