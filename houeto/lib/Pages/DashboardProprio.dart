import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Pages/AddLogement.dart';
import 'package:houeto/Pages/NotificationsPage.dart';
import 'package:houeto/Pages/PageDemandeLocation.dart';
import 'package:houeto/Pages/ShowBien.dart';
import 'package:houeto/Pages/pageVisite.dart';
import 'package:houeto/Services/Firebase/auth.dart';

class ProprioDashboard extends StatefulWidget {
  const ProprioDashboard({super.key});

  @override
  State<ProprioDashboard> createState() => _ProprioDashboardState();
}

class _ProprioDashboardState extends State<ProprioDashboard> {
  String nom = '';
  String prenom = '';
  String email = '';
  int nbProprietes = 0;
  int nbLocataires = 0;
  double revenus = 0;
  int plaintesNonLues = 0;

  Future<void> getUserData() async {
    try {
      final User? currentUser = Auth().currentUser;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
          
      if (userDoc.exists) {
        // Récupération des stats
        var stats = await _getProprioStats(currentUser.uid);
        
        setState(() {
          nom = userDoc.get('nom') ?? '';
          prenom = userDoc.get('prenom') ?? '';
          email = currentUser.email ?? '';
          nbProprietes = stats['nbProprietes'];
          nbLocataires = stats['nbLocataires'];
          revenus = stats['revenus'];
          plaintesNonLues = stats['plaintesNonLues'];
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des données: $e");
    }
  }

 Future<Map<String, dynamic>> _getProprioStats(String userId) async {
  return {
    'nbProprietes': 5,
    'nbLocataires': 3,
    'revenus': 125000.0, 
    'plaintesNonLues': 2
  };
}

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;

    final List<Map<String, dynamic>> quickActions = [
      {
        'icon': Icons.add_home_work,
        'title': 'Ajouter un logement',
        'color': Colors.blue,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Addlogement())),
      },
      {
        'icon': Icons.manage_history,
        'title': 'Gérer',
        'color': Colors.pink,
        'onTap': () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const Showbien()));
        },
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Demandes visite',
        'color': Colors.green,
        'onTap': () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const PageVisites()));

        },
      },
      {
        'icon': Icons.rectangle_outlined,
        'title': 'Demandes location',
        'color': Colors.blue,
        'onTap': () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const Pagedemandelocation()));

        },
      },
      {
        'icon': Icons.assignment,
        'title': 'Contrats',
        'color': Colors.green,
        'onTap': () {/* Navigation vers contrats */},
      },
      {
        'icon': Icons.payment,
        'title': 'Paiements',
        'color': Colors.orange,
        'onTap': () {/* Navigation vers paiements */},
      },
      {
        'icon': Icons.report_problem,
        'title': 'Plaintes ($plaintesNonLues)',
        'color': Colors.red,
        'onTap': () {/* Navigation vers plaintes */},
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Tableau de bord",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            }, 
            icon: Icon(Icons.notifications_active),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section Bienvenue
            Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bonjour, $prenom",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Section Statistiques
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard("Propriétés", nbProprietes.toString(), Colors.blue, Icons.home),
                      _buildStatCard("Locataires", nbLocataires.toString(), Colors.green, Icons.people),
                      _buildStatCard("Revenus", "${revenus.toStringAsFixed(0)} FCFA", Colors.orange, Icons.attach_money),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Section Actions Rapides
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Accès rapide",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
  height: 120,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: quickActions.length,
    itemBuilder: (context, index) {
      final action = quickActions[index];
      return _buildQuickAction(
        action['icon'], 
        action['title'], 
        action['color'],
        action['onTap'],
        largeurEcran * 0.25,
      );
    },
  ),
),

            SizedBox(height: 20),

            // Section Plaintes
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Plaintes récentes",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (plaintesNonLues > 0)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$plaintesNonLues nouvelles",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildPlainteItem("Problème de plomberie", "Appartement B12", "Hier"),
                    _buildPlainteItem("Ascenseur en panne", "Résidence Les Jardins", "Il y a 3 jours"),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: TextButton(
                        onPressed: () {/* Voir toutes les plaintes */},
                        child: Text("Voir toutes les plaintes"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildStatCard(String title, String value, Color color, IconData icon) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 4),
    padding: EdgeInsets.all(8),
    constraints: BoxConstraints(minWidth: 80), 
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2, 
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
          maxLines: 2, 
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

Widget _buildQuickAction(IconData icon, String title, Color color, VoidCallback onTap, double width) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: MediaQuery.of(context).size.width*0.3,
      margin: EdgeInsets.only(left: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 30),
              SizedBox(height: 8),
              Flexible( 
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildPlainteItem(String titre, String logement, String date) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.warning, color: Colors.red),
      ),
      title: Text(titre, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(logement),
      trailing: Text(date, style: TextStyle(color: Colors.grey)),
      onTap: () {/* Voir les détails de la plainte */},
    );
  }
}