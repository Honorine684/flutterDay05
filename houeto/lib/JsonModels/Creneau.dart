import 'package:flutter/material.dart';

class Creneau {
 final TimeOfDay start;
 final TimeOfDay end;
 Creneau({
  required this.start,
  required this.end,
 });
 @override
  String toString() {
    return '${formatTime(start)} - ${formatTime(end)}';
  }
  
   String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');// s'assure qu'il ya au moins deux chiffres si mois complete 0 a gauche
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  Map<String, dynamic> toMap() {
    return {
      'startHour': start.hour,
      'startMinute': start.minute,
      'endHour': end.hour,
      'endMinute': end.minute,
    };
  }
factory Creneau.fromJson(Map<String, dynamic> json) {
  return Creneau(
    start: TimeOfDay(
      hour: (json['start']?['hour'] as int?) ?? 9, // Valeur par défaut 9h
      minute: (json['start']?['minute'] as int?) ?? 0,
    ),
    end: TimeOfDay(
      hour: (json['end']?['hour'] as int?) ?? 17, // Valeur par défaut 17h
      minute: (json['end']?['minute'] as int?) ?? 0,
    ),
  );
}


  Map<String, dynamic> toJson() {
    return {
      'start': {
        'hour': start.hour,
        'minute': start.minute,
      },
      'end': {
        'hour': end.hour,
        'minute': end.minute,
      },
    };
  }
}