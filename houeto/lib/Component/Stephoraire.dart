import 'package:flutter/material.dart';
import 'package:houeto/Component/horairewidget/SelectorAvailable.dart';
import 'package:houeto/JsonModels/JourDisponibilite.dart';

class Stephoraire extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final List<Jourdisponibilite>? initialAvailability;
  
  const Stephoraire({
    super.key, 
    required this.onDataChanged,
    this.initialAvailability,
  });

  @override
  State<Stephoraire> createState() => StephoraireState();
}

class StephoraireState extends State<Stephoraire> {
  late List<Jourdisponibilite> doctorAvailability;

  @override
  void initState() {
    super.initState();
    doctorAvailability = widget.initialAvailability ?? [];
  }

  @override
  void didUpdateWidget(covariant Stephoraire oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAvailability != oldWidget.initialAvailability) {
      setState(() {
        doctorAvailability = widget.initialAvailability ?? [];
      });
    }
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
              'doctorAvailability': doctorAvailability,
            });
          },
        ),
      ],
    );
  }
}