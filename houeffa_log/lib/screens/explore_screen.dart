import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _HousingMapPageState();
}

class _HousingMapPageState extends State<ExploreScreen> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(6.3703, 2.3912); // Exemple : Cotonou

  final List<Map<String, dynamic>> housingData = [
    {"name": "Appartement Luxe", "lat": 6.3703, "lng": 2.3912},
    {"name": "Villa avec Jardin", "lat": 6.3650, "lng": 2.3880},
    {"name": "Studio Meublé", "lat": 6.3755, "lng": 2.3950},
  ];

  Set<Marker> _createMarkers() {
    return housingData.map((house) {
      return Marker(
        markerId: MarkerId(house['name']),
        position: LatLng(house['lat'], house['lng']),
        infoWindow: InfoWindow(title: house['name']),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carte des logements')),
      body: GoogleMap(
        onMapCreated: (controller) => mapController = controller,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 14.0,
        ),
        markers: _createMarkers(),
        mapType: MapType.normal,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            const CameraPosition(target: LatLng(6.3703, 2.3912), zoom: 14.0),
          ),
        ),
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
