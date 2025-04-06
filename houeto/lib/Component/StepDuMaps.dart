import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class Stepdumaps extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  final Map<String, dynamic>? initialData;
  
  const Stepdumaps({
    super.key, 
    required this.onDataChanged,
    this.initialData,
  });

  @override
  State<Stepdumaps> createState() => MapsState();
}

class MapsState extends State<Stepdumaps> {
  late double latitude;
  late double longitude;
  late String locationAddress;
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> nearbyPlaces = [];
  double _zoomLevel = 15;
  Timer? _debounceTimer;
  late final MapController _mapController;
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    latitude = widget.initialData?['latitude'] ?? 6.3676953;
    longitude = widget.initialData?['longitude'] ?? 2.4252507;
    locationAddress = widget.initialData?['adresse'] ?? "Cliquer ici pour choisir une adresse";
  }

  @override
  void dispose() {
    _mapController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Stepdumaps oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      setState(() {
        latitude = widget.initialData?['latitude'] ?? 6.3676953;
        longitude = widget.initialData?['longitude'] ?? 2.4252507;
        locationAddress = widget.initialData?['adresse'] ?? "Cliquer ici pour choisir une adresse";
      });
      if (_mapInitialized && widget.initialData != null && widget.initialData!['latitude'] != null) {
        _mapController.move(LatLng(latitude, longitude), _zoomLevel);
      }
    }
  }



  Future<List<Map<String, dynamic>>> getAddress(String query) async {
    if (query.length < 3) return [];

    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'),
        headers: {
          'User-Agent':
              'houeto/1.0 (https://houeto.com; contact@houeto.com)' 'houeto'
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((item) {
          return {
            'adresse': item['display_name'],
            'latitude': double.parse(item['lat']),
            'longitude': double.parse(item['lon']),
            'type': item['type'] ?? 'unknown',
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Erreur de recherche d'adresse: $e");
      return [];
    }
  }

    Future<void> getNearbyPlaces() async {
    setState(() {
      isLoading = true;
    });

    try {
      final addressResponse = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1'),
        headers: {
          'User-Agent':
              'houeto/1.0 (https://houeto.com; contact@houeto.com)' 'houeto'
        },
      );

      if (addressResponse.statusCode == 200) {
        final addressData = json.decode(addressResponse.body);
        final address = addressData['display_name'];

        setState(() {
          searchController.text = address;
        });
      }

      final poi = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=amenity&viewbox=${longitude - 0.02},${latitude - 0.02},${longitude + 0.02},${latitude + 0.02}&bounded=1&limit=10'),
        headers: {'User-Agent': 'YourAppName'},
      );

      if (poi.statusCode == 200) {
        List<dynamic> poiData = json.decode(poi.body);
        setState(() {
          nearbyPlaces = poiData.map<Map<String, dynamic>>((item) {
            return {
              'nom': item['display_name'].toString().split(',')[0],
              'latitude': double.parse(item['lat']),
              'longitude': double.parse(item['lon']),
              'type': item['type'] ?? 'amenity',
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Erreur de récupération des lieux proches: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Icon getPlaceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'restaurant':
      case 'cafe':
      case 'bar':
      case 'fast_food':
        return const Icon(Icons.restaurant, color: Colors.orange);
      case 'hotel':
      case 'hostel':
      case 'guest_house':
        return const Icon(Icons.hotel, color: Colors.blue);
      case 'supermarket':
      case 'shop':
      case 'convenience':
      case 'mall':
        return const Icon(Icons.shopping_cart, color: Colors.green);
      case 'school':
      case 'university':
      case 'college':
      case 'library':
        return const Icon(Icons.school, color: Colors.amber);
      case 'hospital':
      case 'pharmacy':
      case 'doctors':
      case 'clinic':
        return const Icon(Icons.local_hospital, color: Colors.red);
      case 'building':
      case 'house':
      case 'apartments':
      case 'residential':
        return const Icon(Icons.home, color: Colors.brown);
      case 'bank':
      case 'atm':
        return const Icon(Icons.account_balance, color: Colors.indigo);
      case 'parking':
      case 'fuel':
        return const Icon(Icons.local_parking, color: Colors.blueGrey);
      case 'park':
      case 'garden':
        return const Icon(Icons.park, color: Colors.lightGreen);
      case 'cinema':
      case 'theatre':
      case 'arts_centre':
        return const Icon(Icons.theaters, color: Colors.purple);
      default:
        return const Icon(Icons.place, color: Colors.deepPurple);
    }
  }

   @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: locationAddress,
        labelStyle: const TextStyle(color: Colors.blue),
        suffixIcon: IconButton(
          onPressed: () => showModal(context),
          icon: const Icon(Icons.location_pin, color: Colors.red),
        ),
      ),
      onTap: () => showModal(context),
    );
  }

  void showModal(BuildContext context) {
    searchController.text = locationAddress != "Cliquer ici pour choisir une adresse"
        ? locationAddress
        : "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 80,
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(latitude, longitude),
                            initialZoom: _zoomLevel,
                            onMapReady: () {
                              _mapInitialized = true;
                              if (widget.initialData != null && widget.initialData!['latitude'] != null) {
                                _mapController.move(LatLng(latitude, longitude), _zoomLevel);
                              }
                            },
                            onTap: (tapPosition, tapPoint) async {
                              setModalState(() {
                                latitude = tapPoint.latitude;
                                longitude = tapPoint.longitude;
                              });

                              try {
                                final response = await http.get(
                                  Uri.parse(
                                    'https://nominatim.openstreetmap.org/reverse?format=json&lat=${tapPoint.latitude}&lon=${tapPoint.longitude}&zoom=18&addressdetails=1'),
                                  headers: {'User-Agent': 'YourAppName'},
                                );

                                if (response.statusCode == 200) {
                                  final data = json.decode(response.body);
                                  final address = data['display_name'];
                                  setModalState(() {
                                    searchController.text = address;
                                  });

                                  _debounceTimer?.cancel();
                                  _debounceTimer = Timer(
                                    const Duration(milliseconds: 500), 
                                    () => getNearbyPlaces()
                                  );
                                } else {
                                  setModalState(() {
                                    searchController.text = 
                                      "Latitude: ${tapPoint.latitude}, Longitude: ${tapPoint.longitude}";
                                  });
                                }
                              } catch (e) {
                                setModalState(() {
                                  searchController.text = 
                                    "Latitude: ${tapPoint.latitude}, Longitude: ${tapPoint.longitude}";
                                });
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.houeto.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  width: 40,
                                  height: 40,
                                  point: LatLng(latitude, longitude),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.place,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: nearbyPlaces.map((place) {
                                return Marker(
                                  width: 40,
                                  height: 40,
                                  point: LatLng(place['latitude'], place['longitude']),
                                  child: getPlaceIcon(place['type']),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: TypeAheadField(
                      controller: searchController,
                      hideOnEmpty: true,
                      hideOnLoading: false,
                      debounceDuration: const Duration(milliseconds: 500),
                      suggestionsCallback: (pattern) async {
                        return await getAddress(pattern);
                      },
                      itemBuilder: (context, Map<String, dynamic> suggestion) {
                        return ListTile(
                          leading: getPlaceIcon(suggestion['type']),
                          title: Text(
                            suggestion['adresse'].toString().split(',')[0],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            suggestion['adresse']
                                .toString()
                                .split(',')
                                .sublist(1)
                                .join(','),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                      onSelected: (Map<String, dynamic> suggestion) {
                        setModalState(() {
                          latitude = suggestion['latitude'];
                          longitude = suggestion['longitude'];
                          searchController.text = suggestion['adresse'];
                          _zoomLevel = 17; 
                        });
                        
                        
                        _mapController.move(
                          LatLng(suggestion['latitude'], suggestion['longitude']), 
                          _zoomLevel
                        );

                        if (_debounceTimer?.isActive ?? false) {
                          _debounceTimer!.cancel();
                        }
                        _debounceTimer =
                            Timer(const Duration(milliseconds: 500), () {
                          getNearbyPlaces();
                        });
                      },
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Rechercher une adresse',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        );
                      },
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Annuler"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (searchController.text.isNotEmpty) {
                                    locationAddress = searchController.text;
                                  } else {
                                    locationAddress =
                                        "Lat: $latitude, Lng: $longitude";
                                  }
                                });

                                widget.onDataChanged({
                                  'latitude': latitude,
                                  'longitude': longitude,
                                  'adresse': searchController.text.isNotEmpty
                                      ? searchController.text
                                      : "Lat: $latitude, Lng: $longitude",
                                });

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("Confirmer"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 90,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          "Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}