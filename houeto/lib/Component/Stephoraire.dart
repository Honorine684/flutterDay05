import 'package:flutter/material.dart';
import 'package:houeto/Component/horairewidget/SelectorAvailable.dart';
import 'package:houeto/JsonModels/JourDisponibilite.dart';


class Stephoraire extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
   final List<Jourdisponibilite>? initialAvailability; 
  const Stephoraire({super.key, required this.onDataChanged, this.initialAvailability = const[]});

  @override
  State<Stephoraire> createState() {
    return StephoraireState();
  }
}

class StephoraireState extends State<Stephoraire> {
  late List<Jourdisponibilite> doctorAvailability;
  
  
  @override
  void initState() {
    super.initState();
    doctorAvailability = widget.initialAvailability ?? [
      Jourdisponibilite(day: 'Lundi', creneaux: []),
      Jourdisponibilite(day: 'Mardi', creneaux: []),
      Jourdisponibilite(day: 'Mercredi', creneaux: []),
      Jourdisponibilite(day: 'Jeudi', creneaux: []),
      Jourdisponibilite(day: 'Vendredi', creneaux: []),
      Jourdisponibilite(day: 'Samedi', creneaux: []),
      Jourdisponibilite(day: 'Dimanche', creneaux: [])
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Selectoravailable(
          initialAvailability: doctorAvailability,
          onDaychanged: (availability) {
            setState(() {
              doctorAvailability = availability;
            });
            widget.onDataChanged({
              'doctorAvailability': availability,
            });
          },
        ),
      ],
    );
  }
}