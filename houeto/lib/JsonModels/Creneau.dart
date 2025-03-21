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
}
