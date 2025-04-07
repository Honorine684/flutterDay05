import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:houeto/JsonModels/JourDisponibilite.dart';

class FirestoreService {
  final CollectionReference logement = FirebaseFirestore.instance.collection("logement");
  final CollectionReference visites = FirebaseFirestore.instance.collection("visites");
  final CollectionReference contrats = FirebaseFirestore.instance.collection("contrats");



  Future<DocumentReference<Object?>> addLogement(
   String propritaireId,
    String nomProprietaire,
    String titre,
    String adresse,
    String propertyType,
    double surface,
    int anneDeConstruction,
    int nbreDeChambre, 
   int nbreDeCuisine,
    int nbreDeSalleDeBain,
    int nbreDeSalons,
    int nbreDeTerrasse,
    int nbreDeBalcon,
    int nbreDeParking,
    bool estSanitaire,
    bool estMeuble,
    bool estClimatise,
    String etat,
    double avance,
    double loyerMois,
    double loyerJour,
    double caution,
    List<Jourdisponibilite> jours,
    String conditionAdmission,
    String typeDeBail,
    double fraisVisite,
    String photo1,
    String photo2,
    String photo3,
    String photo4,
    String description,
    double latitude,
    int etages ,
    double longitude,
    {
    String mode = "Non confier", 
    String statut = "Inocupper",
    String gestionnaireId = '',
    String gestionnaireNom = '',
   
  }) async{ 
    // Ajouter le logement principal
    DocumentReference logementRef = await logement.add({
      'titre': titre,
      'adresse': adresse,
      'propertyType': propertyType,
      'surface': surface,
      'annee_construction': anneDeConstruction,
      'chambres': nbreDeChambre,
      'salons': nbreDeSalons,
      'salles_de_bain': nbreDeSalleDeBain,
      'terrasses': nbreDeTerrasse,
      'balcons': nbreDeBalcon,
      'cuisines':nbreDeCuisine,
      'etages':etages,
      'parking': nbreDeParking,
      'estSanitaire': estSanitaire,
      'estMeuble': estMeuble,
      'estClimatise': estClimatise,
      'etat': etat,
      'avance': avance,
      'loyerMois': loyerMois,
      'loyerJour': loyerJour,
      'caution': caution,
      'conditionAdmission': conditionAdmission,
      'fraisVisite': fraisVisite,
      'typeDeBail': typeDeBail,
      'description': description,
      'photo1': photo1,
      'photo2': photo2,
      'photo3': photo3,
      'photo4': photo4,
      'latitude':latitude,
      'longitude':longitude,
      'statut':statut,
      'proprietaireId':propritaireId,
      'nomProprietaire':nomProprietaire,
      'mode':mode,
      'gestionnaireId':gestionnaireId,
      'gestionnaireNom':gestionnaireNom,
      'Timestamp': Timestamp.now(),
    });

    List<Jourdisponibilite> joursDisponibles = jours.where((jour) => jour.estDisponible).toList();

    for (Jourdisponibilite jour in joursDisponibles) {
      if (jour.estDisponible && jour.creneaux.isNotEmpty) {
        await logementRef
            .collection('joursDisponibles')
            .doc(jour.day)
            .set(jour.toMap());
        print('Créneaux ajoutés pour ${jour.day}');
      }
    }

    return logementRef;
  }
  Stream<QuerySnapshot> getLogement(String proprietaireId){
  final logementStream = logement.where('proprietaireId', isEqualTo: proprietaireId)
  .snapshots();
  return logementStream;
}
Future<void> updateLogement(
  String logementId, {
  String? titre,
  String? adresse,
  String? propertyType,
  double? surface,
  int? anneDeConstruction,
  int? nbreDeChambre,
  int? nbreDeCuisine,
  int? nbreDeSalleDeBain,
  int? nbreDeSalons,
  int? nbreDeTerrasse,
  int? nbreDeBalcon,
  int? nbreDeParking,
  bool? estSanitaire,
  bool? estMeuble,
  bool? estClimatise,
  String? etat,
  double? avance,
  double? loyerMois,
  double? loyerJour,
  double? caution,
  List<Jourdisponibilite>? jours,
  String? conditionAdmission,
  String? typeDeBail,
  double? fraisVisite,
  String? photo1,
  String? photo2,
  String? photo3,
  String? photo4,
  String? description,
  double? latitude,
  double? longitude,
  String? statut,
  int? nbreEtages
}) async {
  Map<String, dynamic> updateData = {
    'Timestamp': Timestamp.now(),
  };

  if (titre != null) updateData['titre'] = titre;
  if (adresse != null) updateData['adresse'] = adresse;
  if (propertyType != null) updateData['propertyType'] = propertyType;
  if (surface != null) updateData['surface'] = surface;
  if (anneDeConstruction != null) updateData['annee_construction'] = anneDeConstruction;
  if (nbreDeChambre != null) updateData['chambres'] = nbreDeChambre;
  if (nbreDeSalons != null) updateData['salons'] = nbreDeSalons;
  if (nbreDeSalleDeBain != null) updateData['salles_de_bain'] = nbreDeSalleDeBain;
  if (nbreDeTerrasse != null) updateData['terrasses'] = nbreDeTerrasse;
  if (nbreDeBalcon != null) updateData['balcons'] = nbreDeBalcon;
  if (nbreDeParking != null) updateData['parking'] = nbreDeParking;
  if (nbreEtages != null) updateData['etages'] = nbreEtages;
  if (estSanitaire != null) updateData['estSanitaire'] = estSanitaire;
  if (estMeuble != null) updateData['estMeuble'] = estMeuble;
  if (estClimatise != null) updateData['estClimatise'] = estClimatise;
  if (etat != null) updateData['etat'] = etat;
  if (avance != null) updateData['avance'] = avance;
  if (loyerMois != null) updateData['loyerMois'] = loyerMois;
  if (loyerJour != null) updateData['loyerJour'] = loyerJour;
  if (caution != null) updateData['caution'] = caution;
  if (conditionAdmission != null) updateData['conditionAdmission'] = conditionAdmission;
  if (fraisVisite != null) updateData['fraisVisite'] = fraisVisite;
  if (typeDeBail != null) updateData['typeDeBail'] = typeDeBail;
  if (description != null) updateData['description'] = description;
  if (photo1 != null) updateData['photo1'] = photo1;
  if (photo2 != null) updateData['photo2'] = photo2;
  if (photo3 != null) updateData['photo3'] = photo3;
  if (photo4 != null) updateData['photo4'] = photo4;
  if (latitude != null) updateData['latitude'] = latitude;
  if (longitude != null) updateData['longitude'] = longitude;
  if (statut != null) updateData['statut'] = statut;

  await logement.doc(logementId).update(updateData);
  
  if (jours != null && jours.isNotEmpty) {
    var joursCollection = logement.doc(logementId).collection('joursDisponibles');
    
    List<Jourdisponibilite> joursDisponibles = jours.where((jour) => jour.estDisponible).toList();
    
    for (Jourdisponibilite jour in joursDisponibles) {
      if (jour.estDisponible && jour.creneaux.isNotEmpty) {
        await joursCollection.doc(jour.day).set(jour.toMap());
      }
    }
  }
}
//delete
Future<void> deleteLogement(String logementId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('logement')
        .doc(logementId)
        .get();

    if (!doc.exists) {
      throw Exception("Le logement n'existe pas");
    }

    await _deleteSubcollection(logementId, 'joursDisponibles');

    await FirebaseFirestore.instance
        .collection('logement')
        .doc(logementId)
        .delete();

    print('Logement et joursDisponibles supprimés avec succès');
  } catch (e) {
    print('Erreur lors de la suppression: $e');
    rethrow;
  }
}

Future<void> _deleteSubcollection(String logementId, String subcollection) async {
  final collectionPath = 'logement/$logementId/$subcollection';
  final collectionRef = FirebaseFirestore.instance.collection(collectionPath);
  
  const batchSize = 20;
  QuerySnapshot snapshot = await collectionRef.limit(batchSize).get();

  while (snapshot.docs.isNotEmpty) {
    final batch = FirebaseFirestore.instance.batch();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    snapshot = await collectionRef.limit(batchSize).get();
  }
}

  Stream<QuerySnapshot> getCreneauxForLogement(String logementId) {
    try {
      final creneauStream = FirebaseFirestore.instance
          .collection('logement')
          .doc(logementId)
          .collection('joursDisponibles')
          .snapshots();
      creneauStream.listen((snapshot) {
        print("Créneaux récupérés pour le logement $logementId: ${snapshot.docs.length}");
      });
      return creneauStream;
    } catch (e) {
      print("Erreur lors de la récupération des créneaux: $e");
      rethrow;
    }
  }
  Stream<QuerySnapshot> getLogementForWithGestionnaire(String userId){
    final gestionnaireLogement = logement.
    where('mode',isEqualTo: 'Confier').
    where('proprietaireId',isEqualTo:userId).
    snapshots();
    return gestionnaireLogement;
  }
Stream<QuerySnapshot> recupeLogementNonConfieAuGestionnaire(String userId){
    final gestionnaireLogement = logement.
    where('mode',isEqualTo: 'Non confier').
    where('proprietaireId',isEqualTo:userId).
    snapshots();
    return gestionnaireLogement;
  }

 Stream<List<Map<String, dynamic>>> getVisitesByStatus({
  required String userId, 
  required String status
}) {
  return FirebaseFirestore.instance
      .collectionGroup('visites')
      .where('statut', isEqualTo: status)
      .snapshots()
      .asyncMap((visitesSnapshot) async {
        // Récupère d'abord les logements concernés
        final logementsSnapshot = await FirebaseFirestore.instance
            .collection('logement')
            .where(
              Filter.or(
                Filter('proprietaireId', isEqualTo: userId),
                Filter('gestionnaireId', isEqualTo: userId),
              ),
            )
            .get();

        final logementIds = logementsSnapshot.docs.map((doc) => doc.id).toList();
        
        return visitesSnapshot.docs
            .where((doc) => logementIds.contains(doc['logementId']))
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            })
            .toList();
      });
}

Future<DocumentSnapshot?> getLogementById(String logementId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('logement')
        .doc(logementId)
        .get();
    
    return doc;
  } catch (e) {
    print("Erreur dans getLogementById: $e");
    return null;
  }
}

Future<QuerySnapshot> getJoursDisponibles(String logementId) async {
  try {
    return await FirebaseFirestore.instance
        .collection('logement')
        .doc(logementId)
        .collection('joursDisponibles')
        .get();
  } catch (e) {
    print("Erreur dans getJoursDisponibles: $e");
    rethrow;
  }
}
Stream<QuerySnapshot> getContratActif(String userId) {
  print("Recherche des contrats actifs pour userId: $userId");
  
  final logementsRef = FirebaseFirestore.instance.collection('logement');
  
  return logementsRef
      .where('proprietaireId', isEqualTo: userId)
      .snapshots()
      .asyncMap((logementsSnapshot) async {
        print("Logements trouvés: ${logementsSnapshot.docs.length}");
        
        // Afficher les IDs des logements trouvés pour débogage
        List<String> logementIds = logementsSnapshot.docs.map((doc) {
          print("Logement trouvé: ${doc.id}");
          return doc.id;
        }).toList();
        
        if (logementIds.isEmpty) {
          print("Aucun logement trouvé pour ce propriétaire");
          return await FirebaseFirestore.instance.collection('contrats')
              .limit(0)
              .get();
        }
        
        print("Recherche de contrats avec logementId dans: $logementIds");
        
        if (logementIds.length > 10) {
          print("Plus de 10 logements, limitation à 10 pour whereIn");
          logementIds = logementIds.sublist(0, 10);
        }
        
        final contratsQuery = FirebaseFirestore.instance.collection('contrats')
            .where('etat', isEqualTo: 'actif')
            .where('logementId', whereIn: logementIds);
            
        QuerySnapshot result = await contratsQuery.get();
        print("Contrats actifs trouvés: ${result.docs.length}");
        
        for (var doc in result.docs) {
          print("Contrat trouvé: ${doc.id}, logementId: ${(doc.data() as Map)['logementId']}");
        }
        
        return result;
      });
}

}
  
  
