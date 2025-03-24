import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; 
import 'package:houeto/JsonModels/Logement.dart';
import 'package:houeto/Services/Firebase/FirestoreService.dart';

class SeeallbienwidgetMap extends StatefulWidget {
  const SeeallbienwidgetMap({super.key});

  @override
  State<SeeallbienwidgetMap> createState() => SeeallbienwidgetMapState();
}

class SeeallbienwidgetMapState extends State<SeeallbienwidgetMap> {
  List<Logement> logements = [];
  double latitude = 6.3676953;
  double longitude = 2.4252507;
  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    loadLogement();
  }

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
          String typeProperty = doc.get('propertyType') ?? 'Type non disponible';
          String photo1 = doc.get('photo1') ?? '';
          double superficie = doc.get('superficie') ?? 0.0;
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
  Widget build(BuildContext context) {
    List<Marker> markers = [];
    for (var logement in logements) {
      markers.add(
        Marker(
          point: LatLng(logement.latitude, logement.longitude),
          child: GestureDetector(
            onTap: () => _showLogementDetails(context, logement),
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 500,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: 15.0,
            onTap: (_, __) {
            },
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
            Text("Superficie: ${logement.superficie} m²"),
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
}