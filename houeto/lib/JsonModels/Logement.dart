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
  final String gestionnaireNom;
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
    required this.gestionnaireNom,
    required this.etat,
    required this.creneaux, 
    
  });
}