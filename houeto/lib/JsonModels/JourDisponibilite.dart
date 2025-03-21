
import 'package:houeto/JsonModels/Creneau.dart';

class Jourdisponibilite {
  final String day;
  List<Creneau> creneaux = [];
  bool estDisponible;

  Jourdisponibilite({
    required this.day,
    required this.creneaux,
    this.estDisponible = false,
  });

  addCreneau(Creneau creneau) {
    creneaux.add(creneau);
  }

  removeCreneau(int index) {
    if (index >= 0 && index < creneaux.length) {
      creneaux.removeAt(index);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'jour': day,
      'estDisponible': estDisponible,
      'creneaux': creneaux.map((creneau) => creneau.toMap()).toList(),
    };
  }
}
