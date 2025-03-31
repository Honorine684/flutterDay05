import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:houeto/Pages/PageDetails.dart';
import 'package:latlong2/latlong.dart';
import 'package:houeto/JsonModels/Logement.dart';
import 'package:houeto/Services/Firebase/FirestoreService.dart';
import 'dart:math';
import 'dart:math' show sin, cos, sqrt, atan2;

class SeeallbienwidgetMap extends StatefulWidget {
  const SeeallbienwidgetMap({super.key});

  @override
  State<SeeallbienwidgetMap> createState() => SeeallbienwidgetMapState();
}

class SeeallbienwidgetMapState extends State<SeeallbienwidgetMap> {
  List<Logement> logements = [];
  bool isLoading = true;

  final mapController = MapController();
  double latitude = 6.3676953;
  double longitude = 2.4252507;
  double zoomLevel = 15.0;
  
  // Limites pour le calcul du cadrage de la carte
  double minLat = 90.0;
  double maxLat = -90.0;
  double minLng = 180.0;
  double maxLng = -180.0;
  
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

  void calculateMapCenter() {
    if (logements.isEmpty) {
      latitude = 6.3676953;
      longitude = 2.4252507;
      zoomLevel = 15.0;
      return;
    }

    if (logements.length == 1) {
      latitude = logements.first.latitude;
      longitude = logements.first.longitude;
      zoomLevel = 16.0;
      return;
    }

    // Réinitialiser les limites
    minLat = 90.0;
    maxLat = -90.0;
    minLng = 180.0;
    maxLng = -180.0;

    // Calculer les limites de tous les logements
    for (var logement in logements) {
      if (logement.latitude < minLat) minLat = logement.latitude;
      if (logement.latitude > maxLat) maxLat = logement.latitude;
      if (logement.longitude < minLng) minLng = logement.longitude;
      if (logement.longitude > maxLng) maxLng = logement.longitude;
    }
    
    // Calculer le centre de la carte
    latitude = (minLat + maxLat) / 2;
    longitude = (minLng + maxLng) / 2;

    // Ajouter une marge pour s'assurer que tous les marqueurs sont visibles
    double latPadding = (maxLat - minLat) * 0.1;
    double lngPadding = (maxLng - minLng) * 0.1;
    
    // Recalculer les limites avec la marge
    minLat -= latPadding;
    maxLat += latPadding;
    minLng -= lngPadding;
    maxLng += lngPadding;
    
    // Calculer la distance maximale en degrés
    double latDist = maxLat - minLat;
    double lngDist = maxLng - minLng;
    
    // Calculer le niveau de zoom approprié
    if (max(latDist, lngDist) < 0.01) {
      zoomLevel = 16.0;
    } else if (max(latDist, lngDist) < 0.05) {
      zoomLevel = 14.0;
    } else if (max(latDist, lngDist) < 0.1) {
      zoomLevel = 13.0;
    } else if (max(latDist, lngDist) < 0.5) {
      zoomLevel = 11.0;
    } else {
      zoomLevel = 10.0;
    }
    
    print('Limites de la carte: Lat($minLat, $maxLat), Lng($minLng, $maxLng)');
    print('Centre calculé: $latitude, $longitude');
    print('Zoom calculé: $zoomLevel');
  }

  // Centrer la carte pour montrer tous les logements
  void centerMapOnAllProperties() {
    calculateMapCenter();
    mapController.move(LatLng(latitude, longitude), zoomLevel);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;

    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  double max(double a, double b) => a > b ? a : b;
  
  @override
  void initState() {
    super.initState();
    loadLogement();
  }

  void loadLogement() {
    setState(() {
      isLoading = true;
    });
    
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("Aucun utilisateur connecté");
      if (mounted) {
        setState(() {
          logements = [];
          isLoading = false;
        });
      }
      return;
    }

    print("Chargement des logements...");

    FirestoreService().getLogement(currentUser.uid).listen((snapshot) async {
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
          print('Logement trouvé:');
          print('Titre: $titre');
          print('Latitude: $latitude');
          print('Longitude: $longitude');

          if (latitude != 0.0 && longitude != 0.0) {
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
          } else {
            print('Coordonnées invalides pour $titre');
          }
        } catch (e) {
          print("Erreur sur un document logement: $e");
        }
      }

      await Future.wait(creneauxFutures);

      if (mounted) {
        setState(() {
          logements = listeLogement;
          isLoading = false;
          calculateMapCenter(); // Recalcule le centre après chargement des logements
          
          // Centrer automatiquement la carte après chargement
          WidgetsBinding.instance.addPostFrameCallback((_) {
            centerMapOnAllProperties();
          });
          
          print("Logements chargés: ${logements.length}");
        });
      }
    }, onError: (error) {
      print("Erreur lors du chargement des logements: $error");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Widget buildCustomMarker(Logement logement) {
    return GestureDetector(
      child: SizedBox(
        width: 140, 
        height: 55, 
        child: Card(
          elevation: 6,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  logement.typeProperty,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  getFormattedPrice(logement),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () => _showLogementDetails(context, logement),
    );
  }

 void _showLogementDetails(BuildContext context, Logement logement) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(logement.titre),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (logement.photo1.isNotEmpty)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: _getImageProvider(logement.photo1),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 10),
            Text("Adresse: ${logement.adresse}"),
            Text("Type: ${logement.typeProperty}"),
            Text("Superficie: ${logement.surface} m²"),
            Text("Loyer/jour: ${logement.loyerJour} FCFA"),
            Text("Loyer/mois: ${logement.loyerMois} FCFA"),
            Text("Chambres: ${logement.chambres}"),
            if (logement.description.isNotEmpty) 
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Description: ${logement.description}"),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Fermer"),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> PageDetailsProprietaire(logement: logement)));
          },
          child: const Text("Voir plus"),
        ),
      ],
    ),
  );
}
ImageProvider _getImageProvider(String imageData) {
  if (imageData.startsWith('http')) {
    return NetworkImage(imageData);
  } else {
    try {
 
      String base64String = imageData;
      if (base64String.contains(',')) {
        base64String = base64String.split(',')[1];
      }
      
      final bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (e) {
      print('Erreur de décodage de l\'image: $e');
      return AssetImage('assets/images/placeholder.png');
    
    }
  }
}
  @override
  Widget build(BuildContext context) {
    print("Nombre total de logements: ${logements.length}");
    
    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 500,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(latitude, longitude),
                initialZoom: zoomLevel,
                onMapReady: () {
                  mapController.move(LatLng(latitude, longitude), zoomLevel);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.houeto',
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 100,
                    size: const Size(60, 60), // Taille des clusters
                    markers: logements.map((logement) {
                      return Marker(
                        point: LatLng(logement.latitude, logement.longitude),
                        width: 140,
                        height: 70,
                        child: buildCustomMarker(logement),
                      );
                    }).toList(),
                    builder: (context, markers) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    polygonOptions: const PolygonOptions(
                      borderColor: Colors.blueAccent,
                      color: Colors.black12,
                      borderStrokeWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bouton pour centrer la carte sur tous les logements
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            heroTag: "centerMapBtn",
            onPressed: centerMapOnAllProperties,
            tooltip: "Voir tous les logements",
            child: Icon(Icons.center_focus_strong),
          ),
        ),
        // Afficher un indicateur de chargement
        if (isLoading)
          Container(
            width: MediaQuery.of(context).size.width,
            height: 500, 
            color: Colors.black12,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        if (!isLoading && logements.isEmpty)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 500,
            child: Center(
              child: Text(
                "Aucun logement disponible",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }
}