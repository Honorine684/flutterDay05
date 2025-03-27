import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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

  final mapController = MapController();
  double latitude = 6.3676953;
  double longitude = 2.4252507;
  double zoomLevel = 15.0;
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

    latitude = logements.map((l) => l.latitude).reduce((a, b) => a + b) /
        logements.length;
    longitude = logements.map((l) => l.longitude).reduce((a, b) => a + b) /
        logements.length;

    double maxDistance = 0;
    for (var i = 0; i < logements.length; i++) {
      for (var j = i + 1; j < logements.length; j++) {
        double distance = calculateDistance(
            logements[i].latitude,
            logements[i].longitude,
            logements[j].latitude,
            logements[j].longitude);
        maxDistance = max(maxDistance, distance);
      }
    }

    if (maxDistance <= 0.5) {
      zoomLevel = 16.0;
    } else if (maxDistance <= 1) {
      zoomLevel = 15.0;
    } else if (maxDistance <= 2) {
      zoomLevel = 14.0;
    } else {
      zoomLevel = 13.0;
    }

    print('Centre calculé: $latitude, $longitude');
    print('Zoom calculé: $zoomLevel');
    print('Distance maximale entre logements: $maxDistance km');
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

      // Wait for all creneaux to be loaded
      await Future.wait(creneauxFutures);

      setState(() {
        logements = listeLogement;
        print("Logements chargés: ${logements.length}");
      });
    }, onError: (error) {
      print("Erreur lors du chargement des logements: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Nombre total de logements: ${logements.length}");

    List<Marker> markers = [];
    for (var logement in logements) {
      markers.add(
        Marker(
          point: LatLng(logement.latitude, logement.longitude),
          width: 120,
          height: 80,
          child: buildCustomMarker(logement),
        ),
      );
    }

    print("Nombre de marqueurs créés: ${markers.length}");

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 500,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: zoomLevel,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
              markers: markers,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogementDetails(BuildContext context, Logement logement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(logement.titre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Adresse: ${logement.adresse}"),
            Text("Type: ${logement.typeProperty}"),
            Text("Superficie: ${logement.surface} m²"),
            Text("Loyer/jour: ${logement.loyerJour} FCFA"),
            Text("Loyer/mois: ${logement.loyerMois} FCFA"),
            Text("Chambres: ${logement.chambres}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  Widget buildCustomMarker(Logement logement) {
    return GestureDetector(
      child: SizedBox(
          width: 63,
          height: 15,
          child: Card(
              elevation: 6,
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    logement.typeProperty,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  Text(
                    getFormattedPrice(logement),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ))),
      onTap: () => _showLogementDetails(context, logement),
    );
  }
}
