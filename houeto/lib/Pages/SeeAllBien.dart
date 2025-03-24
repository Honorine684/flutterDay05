import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Component/SeeAllBienWidget.dart';
import 'package:houeto/JsonModels/Logement.dart';
import 'package:houeto/Services/Firebase/FirestoreService.dart';
import 'dart:convert';

class Seeallbien extends StatefulWidget {
  const Seeallbien({super.key});

  @override
  State<Seeallbien> createState() => SeeallbienState();
}

class SeeallbienState extends State<Seeallbien> {
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
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          ),
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
                  showRoundedBottomSheet();
                },
                icon: const Icon(Icons.more_vert),
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
            mainAxisSize: MainAxisSize.min,
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
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "72 résultats trouvés",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w300),
                          ),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(CupertinoIcons.color_filter)),
                              Text(
                                "Filtrer",
                                style: TextStyle(fontSize: 14),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
SizedBox(
  height: 150, // Hauteur fixe de la liste
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: logements.length,
    itemBuilder: (context, index) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.88, // Largeur de la carte
        margin: const EdgeInsets.symmetric(horizontal: 8), // Marge entre les cartes
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white, // Fond blanc pour la carte
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
            // Image du logement (30% de la largeur)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: logements[index].photo1.isNotEmpty
                  ? Image.memory(
                      base64Decode(logements[index].photo1),
                      width: MediaQuery.of(context).size.width * 0.3, // 30% de la largeur
                      height: 150, // Hauteur fixe
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

            const SizedBox(width: 10), 

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${logements[index].titre} - ${logements[index].typeProperty}- En location",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      logements[index].adresse,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.bed,color: Colors.grey,),
                        Text("${logements[index].chambres.toString()} chambres",style: TextStyle(fontSize: 12,color: Colors.grey),)
                        ,SizedBox(width: 10,),
                        Icon(Icons.golf_course,color: Colors.grey,),
                        Text("${logements[index].superficie.toString()} m2")
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Loyer: ${logements[index].loyerMois} FCFA/mois",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  ),
),

                      
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
