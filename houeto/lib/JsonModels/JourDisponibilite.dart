
import 'package:flutter/material.dart';
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
  static Jourdisponibilite fromMap(Map<String, dynamic> map) {
  List<Creneau> creneauxList = [];
  if (map['creneaux'] != null) {
    for (var creneauMap in map['creneaux']) {
      creneauxList.add(Creneau(
        start: TimeOfDay(
          hour: creneauMap['startHour'],
          minute: creneauMap['startMinute'],
        ),
        end: TimeOfDay(
          hour: creneauMap['endHour'],
          minute: creneauMap['endMinute'],
        ),
      ));
    }
  }
  
  return Jourdisponibilite(
    day: map['jour'] ?? '',
    creneaux: creneauxList,
    estDisponible: map['estDisponible'] ?? false,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'jour': day,
      'estDisponible': estDisponible,
      'creneaux': creneaux.map((creneau) => creneau.toMap()).toList(),
    };
  }
factory Jourdisponibilite.fromJson(Map<String, dynamic> json) {
  return Jourdisponibilite(
    day: json['day'] ?? 'Jour non spécifié', 
    creneaux: (json['creneaux'] as List?)?.map((e) => Creneau.fromJson(e)).toList() ?? [],
    estDisponible: json['estDisponible'] ?? false,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'creneaux': creneaux.map((e) => e.toJson()).toList(),
      'estDisponible': estDisponible,
    };
  }

}