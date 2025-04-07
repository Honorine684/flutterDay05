import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Services/Firebase/FirestoreService.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Gestioncontrat extends StatefulWidget {
  const Gestioncontrat({super.key});

  @override
  GestioncontratState createState() => GestioncontratState();
}

class GestioncontratState extends State<Gestioncontrat> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryColor = Color(0xFF2A3647);
  final Color secondaryColor = Color(0xFFF6F5F5);
  final Color accentColor = Color(0xFFF05454);
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: Text('Gestion Locative', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.document_scanner), text: 'Contrats'),
            Tab(icon: Icon(Icons.people), text: 'Locataires'),
            Tab(icon: Icon(Icons.home), text: 'Biens'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Contrats
          _buildContractsTab(),
          
          // Onglet Locataires
          _buildTenantsTab(),
          
          // Onglet Biens
          _buildPropertiesTab(),
        ],
      ));
  }

Widget _buildContractsTab() {
  // Récupérer l'ID de l'utilisateur connecté
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  print("ID utilisateur connecté: $userId");
  
  return StreamBuilder<QuerySnapshot>(
    stream: FirestoreService().getContratActif(userId),
    builder: (context, snapshot) {
      // Afficher l'état de la connexion pour débogage
      print("ConnectionState: ${snapshot.connectionState}");
      
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        print("ERREUR: ${snapshot.error}");
        return Center(child: Text('Erreur: ${snapshot.error}'));
      }
      
      if (!snapshot.hasData) {
        print("Pas de données disponibles");
        return Center(child: Text('Aucune donnée disponible'));
      }
      
      print("Nombre de contrats: ${snapshot.data!.docs.length}");
      
      if (snapshot.data!.docs.isEmpty) {
        return Center(child: Text('Aucun contrat actif trouvé'));
      }
      final contracts = snapshot.data!.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Ajouter des prints pour débugger
        print("Contrat ID: ${doc.id}");
        print("État du contrat: ${data['etat']}");
        print("ID Logement: ${data['logementId']}");
        
        return {
          'id': doc.id,
          'status': data['etat'],
          'tenant': data['nomDemandeur'] ?? 'Non spécifié',
          'property': data['detailsLogement']?['titre'] ?? 'Non spécifié',
          'start': _formatDate(data['dateDebut']),
          'end': _formatDate(data['dateFin']),
          'rent': data['loyerMois']?.toString() ?? '0',
        };
      }).toList();
      
      print("Contrats formatés: ${contracts.length}");
      
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contract = contracts[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        contract['id'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: contract['status'] == 'actif' 
                            ? Colors.green[100] 
                            : Colors.orange[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          contract['status'] == 'actif' ? 'Actif' : 'Inactif',
                          style: TextStyle(
                            color: contract['status'] == 'actif' 
                              ? Colors.green[800] 
                              : Colors.orange[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Divider(height: 1),
                  SizedBox(height: 12),
                  Text(
                    'Locataire: ${contract['tenant']}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bien: ${contract['property']}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Période: ${contract['start']} - ${contract['end']}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Loyer: ${contract['rent']} CFA/mois',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          iconColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: accentColor.withOpacity(0.1),
                        ),
                          onPressed: () async {
    // Récupérer les données complètes du contrat
    final docSnapshot = await FirebaseFirestore.instance
        .collection('contrats')
        .doc(contract['id'])
        .get();
    
    if (docSnapshot.exists) {
      await generateContractPDF(docSnapshot.data()!);
    }
  },
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.picture_as_pdf, size: 18),
      SizedBox(width: 4),
      Text('Générer PDF'),
    ],
  ),

                      ),
                      SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          iconColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: primaryColor.withOpacity(0.1),
                        ),
                        onPressed: () {
                          // Voir détails
                        },
                        child: Text('Détails'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

String _formatDate(dynamic dateTimestamp) {
  if (dateTimestamp == null) return 'Non spécifié';
  
  try {
    // Si c'est un Timestamp
    if (dateTimestamp is Timestamp) {
      DateTime dateTime = dateTimestamp.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    // Si c'est déjà une chaîne
    if (dateTimestamp is String) {
      return dateTimestamp;
    }
    return 'Format inconnu';
  } catch (e) {
    print("Erreur de formatage de date: $e");
    return 'Erreur de date';
  }
}

  Widget _buildTenantsTab() {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  
  return StreamBuilder<QuerySnapshot>(
    stream: FirestoreService().getContratActif(userId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        print("Erreur dans la récupération des contrats: ${snapshot.error}");
        return Center(child: Text('Erreur: ${snapshot.error}'));
      }
      
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('Aucun locataire trouvé'));
      }
      
      final contrats = snapshot.data!.docs;
      
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _getTenantsData(contrats),
        builder: (context, tenantsSnapshot) {
          if (tenantsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (tenantsSnapshot.hasError) {
            return Center(child: Text('Erreur: ${tenantsSnapshot.error}'));
          }
          
          if (!tenantsSnapshot.hasData || tenantsSnapshot.data!.isEmpty) {
            return Center(child: Text('Aucune information sur les locataires trouvée'));
          }
          
          final tenants = tenantsSnapshot.data!;
          
          return GridView.count(
            padding: EdgeInsets.all(16),
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: tenants.map((tenant) {
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          color: primaryColor.withOpacity(0.1),
                          image: DecorationImage(
                            image: AssetImage("assets/images/images.png"),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              print('Erreur de chargement de l\'image');
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tenant['name'] ?? 'Nom inconnu',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              tenant['property'] ?? 'Logement inconnu',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone, size: 14, color: primaryColor),
                                SizedBox(width: 4),
                                Text(
                                  tenant['phone'] ?? 'Téléphone inconnu',
                                  style: TextStyle(fontSize: 12),
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
            }).toList(),
          );
        },
      );
    },
  );
}

Future<List<Map<String, dynamic>>> _getTenantsData(List<QueryDocumentSnapshot> contrats) async {
  List<Map<String, dynamic>> tenantsData = [];
  
  for (var contrat in contrats) {
    final data = contrat.data() as Map<String, dynamic>;
    
    final String? locataireId = data['locataireId'];
    final String? logementId = data['logementId'];
    final String? typeDemande = data['typeDemande'];
    final String propertyName = data['detailsLogement']?['titre'] ?? 'Logement inconnu';
    
    if (locataireId == null) continue;
    
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(locataireId)
          .get();
      
      if (!userSnapshot.exists) continue;
      
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final String nom = userData['nom'] ?? '';
      final String prenom = userData['prenom'] ?? '';
      String telephone = '';
      
      if (typeDemande == 'visite') {
        QuerySnapshot visiteSnapshot = await FirebaseFirestore.instance
            .collection('visite')
            .where('locataireId', isEqualTo: locataireId)
            .where('logementId', isEqualTo: logementId)
            .limit(1)
            .get();
        
        if (visiteSnapshot.docs.isNotEmpty) {
          telephone = (visiteSnapshot.docs.first.data() as Map<String, dynamic>)['telephone'] ?? '';
        }
      } else if (typeDemande == 'Demande location') {
        QuerySnapshot demandeSnapshot = await FirebaseFirestore.instance
            .collection('demandes_logement')
            .where('locataire_id', isEqualTo: locataireId)
            .where('logement_id', isEqualTo: logementId)
            .limit(1)
            .get();
        
        if (demandeSnapshot.docs.isNotEmpty) {
          telephone = (demandeSnapshot.docs.first.data() as Map<String, dynamic>)['telephone'] ?? '';
        }
      }
      
      tenantsData.add({
        'name': '$prenom $nom',
        'property': propertyName,
        'phone': telephone,
        'photo': 'assets/images/images.png', 
        'id': locataireId
      });
    } catch (e) {
      print('Erreur lors de la récupération des informations du locataire: $e');
    }
  }
  
  return tenantsData;
}
Future<List<Map<String, dynamic>>> getPropertiesFromContracts() async {
  final List<DocumentSnapshot> contracts = await FirebaseFirestore.instance
      .collection('contrats')
      .where('etat', isEqualTo: 'actif')
      .get()
      .then((snapshot) => snapshot.docs);
  
  List<Map<String, dynamic>> propertyList = [];
  
  for (var contract in contracts) {
    final contractData = contract.data() as Map<String, dynamic>;
    
    final logementDoc = await FirebaseFirestore.instance
        .collection('logement')
        .doc(contractData['logementId'])
        .get();
    
    if (logementDoc.exists) {
      final logementData = logementDoc.data() as Map<String, dynamic>;
      
      propertyList.add({
        'id': contractData['logementId'],
        'address': logementData['adresse'],
        'image': logementData['photo1'], // Images déjà en Base64 ou URL
        'rooms': logementData['chambres'].toString(),
        'area': logementData['surface'].toString(),
        'rent': contractData['loyerMois'],
        'status': contractData['etat'] == 'actif' ? 'occupied' : 'available',
        'titre': logementData['titre'],
        
        // Autres informations utiles venant du logement
        'photo2': logementData['photo2'],
        'photo3': logementData['photo3'],
        'cuisines': logementData['cuisines'].toString(),
        'salons': logementData['salons'].toString(),
        'salleDeBains': logementData['salleDeBains'].toString(),
        'parking': logementData['parking'].toString(),
        'estMeuble': logementData['estMeuble'],
        'estClimatise': logementData['estClimatise'],
        'description': logementData['description'],
        
        // Informations du contrat
        'caution': contractData['caution'],
        'avance': contractData['avance'],
        'dateDebut': contractData['dateDebut'],
        'dateFin': contractData['dateFin'],
        'duree': contractData['duree'],
        'dureeType': contractData['dureeType'],
        'nomDemandeur': contractData['nomDemandeur'],
        'statutContrat': contractData['statut'],
      });
    }
  }
  
  return propertyList;
}
  Widget _buildPropertiesTab() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getPropertiesFromContracts(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(child: Text('Erreur: ${snapshot.error}'));
      }
      
      final properties = snapshot.data ?? [];
      if (properties.isEmpty) {
        return Center(child: Text('Aucune propriété disponible'));
      }
      
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return Container(
            height: 180,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: property['image'].startsWith('http') 
                      ? Image.network(
                          property['image'],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.memory(
                          base64Decode(property['image']),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                
                // Overlay sombre
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                // Contenu
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property['titre'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        property['address'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.king_bed, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${property['rooms']} chambres',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          Icon(Icons.square_foot, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${property['area']} m²',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${property['rent']} fcfa/mois',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: property['status'] == 'occupied' 
                                ? accentColor.withOpacity(0.8) 
                                : Colors.green.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              property['status'] == 'occupied' ? 'Occupé' : 'Disponible',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Naviguer vers la page de détails du contrat/logement
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageDetailsProprietaire(property: property),
                        ),
                      );*/
                    },
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


Future<void> generateContractPDF(Map<String, dynamic> contractData) async {
try{


  final pdf = pw.Document();
  DateTime parseFirestoreTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    throw Exception('Format de date non reconnu');
  }

  // Conversion des dates
  final dateCreation = parseFirestoreTimestamp(contractData['dateCreation']);
  final dateDebut = parseFirestoreTimestamp(contractData['dateDebut']);
  final dateFin = parseFirestoreTimestamp(contractData['dateFin']);

  // Formatage des dates
  final dateFormat = DateFormat('dd MMMM yyyy');
  final dateTimeFormat = DateFormat('dd MMMM yyyy à HH:mm');
  
  final formattedDateCreation = dateTimeFormat.format(dateCreation);
  final formattedDateDebut = dateFormat.format(dateDebut);
  final formattedDateFin = dateFormat.format(dateFin);


  pw.Header(
  level: 0,
  child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text('CONTRAT DE LOCATION', 
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.Container(
        height: 50,
       // child: pw.Image(/* votre image de logo */),
      ),
    ],
  ),
);
  pdf.addPage(
    
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // En-tête
            pw.Header(
              level: 0,
              child: pw.Text('CONTRAT DE LOCATION', 
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            
            // Informations générales
            pw.Text('Fait à ${contractData['detailsLogement']['adresse'].split(',').first}', 
              style: pw.TextStyle(fontSize: 12)),
            pw.Text('Le $formattedDateCreation', style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 20),
            
            // Titre
            pw.Text('ENTRE LES SOUSSIGNÉS :', 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            
            // Parties
            pw.Text('D\'une part, le propriétaire du bien désigné ci-dessous,', 
              style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.Text('Et d\'autre part, ${contractData['nomDemandeur']}, locataire,', 
              style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 20),
            
            // Détails du bien
            pw.Text('IL A ÉTÉ CONVENU CE QUI SUIT :', 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            
            pw.Text('Article 1 - Désignation du bien', 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Le propriétaire loue au locataire le bien suivant :', 
              style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.Text('- ${contractData['detailsLogement']['titre']}', 
              style: pw.TextStyle(fontSize: 12)),
            pw.Text('- Adresse : ${contractData['detailsLogement']['adresse']}', 
              style: pw.TextStyle(fontSize: 12)),
            pw.Text('- Surface : ${contractData['detailsLogement']['surface']} m²', 
              style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            
            // Composition
            pw.Text('Article 2 - Composition du bien', 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Le bien se compose de :', style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.Text('- ${contractData['composition']['chambres']} chambre(s)', 
              style: pw.TextStyle(fontSize: 12)),
            pw.Text('- ${contractData['composition']['cuisines']} cuisine(s)', 
              style: pw.TextStyle(fontSize: 12)),
            pw.Text('- ${contractData['composition']['sallesBain']} salle(s) de bain', 
              style: pw.TextStyle(fontSize: 12)),
            pw.Text('- ${contractData['composition']['salons']} salon(s)', 
              style: pw.TextStyle(fontSize: 12)),
            pw.Text('- ${contractData['composition']['parking']} place(s) de parking', 
              style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            
            // Durée du bail
            pw.Text('Article 3 - Durée du bail', 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Le présent bail est consenti pour une durée de ${contractData['duree']} mois,', 
              style: pw.TextStyle(fontSize: 12)),
            pw.Text('à compter du $formattedDateDebut jusqu\'au $formattedDateFin.', 
              style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            
            // Loyer et charges
            pw.Text('Article 4 - Loyer et charges', 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Le loyer est fixé à ${NumberFormat.decimalPattern('fr').format(contractData['loyerMois'])} FCFA par mois,', 
              style: pw.TextStyle(fontSize: 12)),
            pw.Text('payable ${contractData['modePaiement'].toLowerCase()}.', 
              style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.Text('Caution : ${NumberFormat.decimalPattern('fr').format(contractData['caution'])} FCFA', 
              style: pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            
            // Conditions spéciales
            pw.Text('Article 5 - Conditions spéciales', 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...contractData['conditionsSpeciales'].map((condition) => 
              pw.Text('- $condition', style: pw.TextStyle(fontSize: 12))).toList(),
            pw.SizedBox(height: 20),
            
            // Signature
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text('Le Locataire', 
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 40),
                    pw.Text('${contractData['nomDemandeur']}', 
                      style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text('Le Propriétaire', 
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 40),
                    pw.Text('Signature', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  // Impression ou sauvegarde du PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}catch(e){
  
}
}
}