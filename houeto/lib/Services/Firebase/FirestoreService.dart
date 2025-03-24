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

}