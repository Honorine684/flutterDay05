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
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  factory Creneau.fromMap(Map<String, dynamic> map) {
    return Creneau(
      start: TimeOfDay(
        hour: (map['startHour'] ?? 0) as int,
        minute: (map['startMinute'] ?? 0) as int,
      ),
      end: TimeOfDay(
        hour: (map['endHour'] ?? 0) as int,
        minute: (map['endMinute'] ?? 0) as int,
      ),
    );
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