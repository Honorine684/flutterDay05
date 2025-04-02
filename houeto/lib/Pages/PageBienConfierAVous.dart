import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:houeto/JsonModels/Logement.dart';
import 'dart:convert';
import 'package:houeto/Pages/PageDetails.dart';

class GestionLogementsPage extends StatefulWidget {
  const GestionLogementsPage({super.key});

  @override
  State<GestionLogementsPage> createState() => _GestionLogementsPageState();
}

class _GestionLogementsPageState extends State<GestionLogementsPage> {
  late Future<List<Logement>> _logementsGeres;
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

  @override
  void initState() {
    super.initState();
    _logementsGeres = _fetchLogementsGeres();
  }

  Future<List<Logement>> _fetchLogementsGeres() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('logement')
          .where('gestionnaireId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => Logement.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur récupération logements gérés: $e');
      return [];
    }
  }

  Widget _buildImage(String base64Image) {
    if (base64Image.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Icon(Icons.home, size: 60, color: Colors.grey[400]),
      );
    }
    return Image.memory(
      base64Decode(base64Image),
      fit: BoxFit.cover,
      errorBuilder: (ctx, error, stack) => Container(
        color: Colors.grey[200],
        child: Icon(Icons.broken_image, size: 60, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildLogementCard(Logement logement) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> PageDetailsProprietaire(logement: logement)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16/9,
                child: _buildImage(logement.photo1),
              ),
            ),
            // Détails
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logement.titre,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    logement.adresse,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(
                        icon: Icons.king_bed,
                        text: '${logement.chambres} chambres',
                      ),
                      _buildInfoChip(
                        icon: Icons.aspect_ratio,
                        text: '${logement.surface} m²',
                      ),
                      _buildInfoChip(
                        icon: logement.statut == 'Occuper' 
                            ? Icons.lock 
                            : Icons.lock_open,
                        text: logement.statut,
                        color: logement.statut == 'Occuper' 
                            ? Colors.red[100] 
                            : Colors.green[100],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getFormattedPrice(logement),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue[800],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard gestionnaire'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Logement>>(
        future: _logementsGeres,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucun logement géré',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Les logements dont vous êtes gestionnaire apparaîtront ici',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final logements = snapshot.data!;
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _logementsGeres = _fetchLogementsGeres();
              });
            },
            child: ListView.builder(
              itemCount: logements.length,
              itemBuilder: (context, index) {
                return _buildLogementCard(logements[index]);
              },
            ),
          );
        },
      ),
    );
  }
}