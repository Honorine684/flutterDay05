import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:houeto/JsonModels/JourDisponibilite.dart';

class FirestoreService {
  final CollectionReference logement = FirebaseFirestore.instance.collection("logement");

  Future<DocumentReference<Object?>> addLogement(
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
    double longitude,
    {String statut = "Inocupper"}
  ) async {
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
  Stream<QuerySnapshot> getLogement(){
  final logementStream = logement.orderBy('Timestamp',descending: true).snapshots();
  return logementStream;
}
Future<void> updateLogement(
  String logementId,
  {
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
  }) async {
    
  Map<String, dynamic> updateData = {
    'timestamp': Timestamp.now(),
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

  if (jours != null) {
    var joursCollection = logement.doc(logementId).collection('joursDisponibles');
    var existingDays = await joursCollection.get();
    for (var doc in existingDays.docs) {
      await doc.reference.delete();
    }

    List<Jourdisponibilite> joursDisponibles = jours.where((jour) => jour.estDisponible).toList();
    for (Jourdisponibilite jour in joursDisponibles) {
      if (jour.estDisponible && jour.creneaux.isNotEmpty) {
        await joursCollection.doc(jour.day).set(jour.toMap());
      }
    }
  }
}
//delete
Future<void> deleteLogement(String idLogement)async{
  return logement.doc(idLogement).delete();
}

}