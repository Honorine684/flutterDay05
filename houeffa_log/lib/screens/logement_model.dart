class Logement {
  final String adresse;
  final int anneeConstruction;
  final int avance;
  final int balcons;
  final int caution;
  final int chambres;
  final String conditionAdmission;
  final String description;
  final bool estClimatise;
  final bool estMeuble;
  final bool estSanitaire;
  final String etat;
  final int fraisVisite;
  final double latitude;
  final double longitude;
  final int loyerJour;
  final int loyerMois;
  final int parking;
  final String photo1;
  final String photo2;
  final String photo3;
  final String photo4;
  final String propertyType;
  final int sallesDeBain;
  final int salons;
  final int surface;
  final int terrasses;
  final String titre;
  final String typeDeBail;

  Logement({
    required this.adresse,
    required this.anneeConstruction,
    required this.avance,
    required this.balcons,
    required this.caution,
    required this.chambres,
    required this.conditionAdmission,
    required this.description,
    required this.estClimatise,
    required this.estMeuble,
    required this.estSanitaire,
    required this.etat,
    required this.fraisVisite,
    required this.latitude,
    required this.longitude,
    required this.loyerJour,
    required this.loyerMois,
    required this.parking,
    required this.photo1,
    required this.photo2,
    required this.photo3,
    required this.photo4,
    required this.propertyType,
    required this.sallesDeBain,
    required this.salons,
    required this.surface,
    required this.terrasses,
    required this.titre,
    required this.typeDeBail,
  });

  // Conversion depuis Firebase
  factory Logement.fromFirestore(Map<String, dynamic> data) {
    return Logement(
      adresse: data['adresse'] ?? '',
      anneeConstruction: data['annee_construction'] ?? 0,
      avance: data['avance'] ?? 0,
      balcons: data['balcons'] ?? 0,
      caution: data['caution'] ?? 0,
      chambres: data['chambres'] ?? 0,
      conditionAdmission: data['conditionAdmission'] ?? '',
      description: data['description'] ?? '',
      estClimatise: data['estClimatise'] ?? false,
      estMeuble: data['estMeuble'] ?? false,
      estSanitaire: data['estSanitaire'] ?? false,
      etat: data['etat'] ?? '',
      fraisVisite: data['fraisVisite'] ?? 0,
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      loyerJour: data['loyerJour'] ?? 0,
      loyerMois: data['loyerMois'] ?? 0,
      parking: data['parking'] ?? 0,
      photo1: data['photo1'] ?? '',
      photo2: data['photo2'] ?? '',
      photo3: data['photo3'] ?? '',
      photo4: data['photo4'] ?? '',
      propertyType: data['propertyType'] ?? '',
      sallesDeBain: data['salles_de_bain'] ?? 0,
      salons: data['salons'] ?? 0,
      surface: data['surface'] ?? 0,
      terrasses: data['terrasses'] ?? 0,
      titre: data['titre'] ?? '',
      typeDeBail: data['typeDeBail'] ?? '',
    );
  }
}
