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
    required this.surface
  });
}