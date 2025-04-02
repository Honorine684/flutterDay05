import 'package:cloud_firestore/cloud_firestore.dart';

class Logement {
  final String id;
  final String titre;
  final String adresse;
  final String typeProperty;
  final double latitude;
  final double longitude;
  final String photo1;
  final double loyerJour;
  final double loyerMois;
  final double surface;
  final int chambres;
  final int balcons;
  final int etages;
  final int cuisines;
  final int salleDeBains;
  final int parking;
  final int salons;
  final String statut;
  final String? mode;
  final bool? estClimatise;
  final bool? estSanitaire;
  final String typeDeBail;
  final bool? estMeuble;
  final String conditionAdmission;
  final String description;
  final String photo2;
  final String photo3;
  final int terrasses;
  double avance;
  double fraisDeVisite;
  final String? gestionnaireNom;
  final String etat;
  final List<Map<String,dynamic>> creneaux;
  Logement({
    required this.id,
    required this.adresse,
    required this.titre,
    required this.typeProperty,
    required this.latitude,
    required this.longitude,
    required this.photo1,
    required this.loyerJour,
    required this.loyerMois,
    required this.chambres,
    required this.surface,
    required this.statut,
    this.mode,
    required this.balcons,
    required this.cuisines,
    required this.etages,
    required this.salleDeBains,
    required this.parking,
    required this.salons,
    required this.fraisDeVisite,
    this.estClimatise,
    this.estSanitaire,
    this.estMeuble,
    required this.typeDeBail,
    required this.conditionAdmission,
    required this.description,
    required this.photo2,
    required this.photo3,
    required this.terrasses,
    required this.avance,
    this.gestionnaireNom,
    required this.etat,
    required this.creneaux, 
    
  });
  factory Logement.fromFirestore(DocumentSnapshot doc) {
  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  return Logement(
    id: doc.id,
    titre: data['titre'] ?? 'Titre non disponible',
    adresse: data['adresse'] ?? 'Adresse non disponible',
    typeProperty: data['propertyType'] ?? 'Type non disponible',
    photo1: data['photo1'] ?? '',
    surface: (data['surface'] ?? 0).toDouble(),
    latitude: (data['latitude'] ?? 0).toDouble(),
    longitude: (data['longitude'] ?? 0).toDouble(),
    loyerJour: (data['loyerJour'] ?? 0).toDouble(),
    loyerMois: (data['loyerMois'] ?? 0).toDouble(),
    chambres: data['chambres'] ?? 0,
    statut: data['statut'] ?? 'Inocupper',
    mode: data['mode'],
    balcons: data['balcons'] ?? 0,
    cuisines: data['cuisines'] ?? 0,
    etages: data['etages'] ?? 0,
    salleDeBains: data['salleDeBains'] ?? 0,
    parking: data['parking'] ?? 0,
    salons: data['salons'] ?? 0,
    fraisDeVisite: (data['fraisDeVisite'] ?? 0).toDouble(),
    estClimatise: data['estClimatise'] ?? false,
    estSanitaire: data['estSanitaire'] ?? false,
    estMeuble: data['estMeuble'] ?? false,
    typeDeBail: data['typeDeBail'] ?? '',
    conditionAdmission: data['conditionAdmission'] ?? '',
    description: data['description'] ?? '',
    photo2: data['photo2'] ?? '',
    photo3: data['photo3'] ?? '',
    terrasses: data['terrasses'] ?? 0,
    avance: (data['avance'] ?? 0).toDouble(),
    gestionnaireNom: data['gestionnaireNom'],
    etat: data['etat'] ?? '',
    creneaux: List<Map<String, dynamic>>.from(data['creneaux'] ?? []),
  );
}
}