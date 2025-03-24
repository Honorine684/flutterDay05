import 'package:flutter/material.dart';
import 'package:houeto/Component/horairewidget/SelectorAvailable.dart';
import 'package:houeto/JsonModels/JourDisponibilite.dart';


class Stephoraire extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  const Stephoraire({super.key, required this.onDataChanged});

  @override
  State<Stephoraire> createState() {
    return StephoraireState();
  }
}

class StephoraireState extends State<Stephoraire> {
  List<Jourdisponibilite> doctorAvailability = [];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Selectoravailable(
          onDaychanged: (availability) {
            setState(() {
              doctorAvailability = availability;
            });

            widget.onDataChanged({
              'doctorAvailability': doctorAvailability,
            });
          },
        ),
      ],
    );
  }
}