import 'package:houeto/JsonModels/Creneau.dart';

class Jourdisponibilite {
  final String day;
  List<Creneau> creneaux;
  bool estDisponible;

  Jourdisponibilite({
    required this.day,
    required this.creneaux,
    this.estDisponible = false,
  });

  void addCreneau(Creneau creneau) {
    creneaux.add(creneau);
  }

  void removeCreneau(int index) {
    if (index >= 0 && index < creneaux.length) {
      creneaux.removeAt(index);
    }
  }

  factory Jourdisponibilite.fromMap(Map<String, dynamic> map) {
    return Jourdisponibilite(
      day: map['jour'] ?? map['day'] ?? '',
      estDisponible: map['estDisponible'] ?? false,
      creneaux: (map['creneaux'] as List<dynamic>?)?.map((creneauMap) {
        return Creneau.fromMap(creneauMap as Map<String, dynamic>);
      }).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jour': day,
      'estDisponible': estDisponible,
      'creneaux': creneaux.map((creneau) => creneau.toMap()).toList(),
    };
  }
}