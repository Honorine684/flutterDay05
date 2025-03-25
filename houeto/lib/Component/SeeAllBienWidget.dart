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

    latitude = logements.map((l) => l.latitude).reduce((a, b) => a + b) / logements.length;
    longitude = logements.map((l) => l.longitude).reduce((a, b) => a + b) / logements.length;

    double maxDistance = 0;
    for (var i = 0; i < logements.length; i++) {
      for (var j = i + 1; j < logements.length; j++) {
        double distance = calculateDistance(
          logements[i].latitude, 
          logements[i].longitude, 
          logements[j].latitude, 
          logements[j].longitude
        );
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
    
    var a = sin(dLat/2) * sin(dLat/2) +
            cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * 
            sin(dLon/2) * sin(dLon/2);
    
    var c = 2 * atan2(sqrt(a), sqrt(1-a));
    
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

  FirestoreService().getLogement(currentUser.uid).listen((snapshot) {
    print("Données reçues: ${snapshot.docs.length} logements");
    List<Logement> listeLogement = [];

    for (var doc in snapshot.docs) {
      try {
        String logementId = doc.id;
        String titre = doc.get('titre') ?? 'Titre non disponible';
        String adresse = doc.get('adresse') ?? 'Adresse non disponible';
        String typeProperty = doc.get('propertyType') ?? 'Type non disponible';
        String photo1 = doc.get('photo1') ?? '';
        double surface = doc.get('surface') ?? 0.0;
        double latitude = doc.get('latitude') ?? 0.0;
        double longitude = doc.get('longitude') ?? 0.0;
        double loyerJour = doc.get('loyerJour') ?? 0.0;
        double loyerMois = doc.get('loyerMois') ?? 0.0;
        int chambres = doc.get('chambres') ?? 0;

        print('Logement trouvé:');
        print('Titre: $titre');
        print('Latitude: $latitude');
        print('Longitude: $longitude');

        if (latitude != 0.0 && longitude != 0.0) {
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
            ),
          );
        } else {
          print('Coordonnées invalides pour $titre');
        }
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
      width: 60,
      height: 15,
      child: Card(
      elevation: 6,
      color: Colors.white
      ,
      child: 
          Row(
            children: [
              Icon(Icons.home_mini_rounded,color: Colors.red,),
              SizedBox(width: 4,),
              Text(
            logement.titre,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.black
            ),
            textAlign: TextAlign.center,
          ),
      
            ],
          )
      
    ),
    ),
    onTap: () => _showLogementDetails(context, logement),
  );
}
}