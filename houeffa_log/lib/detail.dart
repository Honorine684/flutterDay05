import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String? imageUrl; 

 
  final String houseDetails = "Maison avec garage - 100m²";
  final String location = "Abidjan, Cocody";

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

 
  Future<void> _loadImage() async {
    try {
      final ref = FirebaseStorage.instance.ref().child('houses/maison1.jpg'); 
      final url = await ref.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print("Erreur lors du chargement de l'image : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du logement'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: imageUrl == null
                ? Center(child: CircularProgressIndicator()) 
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover, 
                  ),
          ),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  Row(
                    children: [
                      Icon(Icons.home, color: Colors.deepOrangeAccent),
                      SizedBox(width: 8),
                      Text(
                        houseDetails,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Lieu
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.deepOrangeAccent),
                      SizedBox(width: 8),
                      Text(
                        location,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}