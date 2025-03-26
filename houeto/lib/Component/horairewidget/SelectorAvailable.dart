import 'package:flutter/material.dart';
import 'package:houeto/JsonModels/Creneau.dart';
import 'package:houeto/JsonModels/JourDisponibilite.dart';

class Selectoravailable extends StatefulWidget {
  final Function(List<Jourdisponibilite>) onDaychanged;
  const Selectoravailable({
    super.key,
    required this.onDaychanged,
  });

  @override
  State<Selectoravailable> createState() {
    return SelectoravailableState();
  }
}

class SelectoravailableState extends State<Selectoravailable> {
  final List<Jourdisponibilite> disponibilites = [
    Jourdisponibilite(day: 'Lundi', creneaux: []),
    Jourdisponibilite(day: 'Mardi', creneaux: []),
    Jourdisponibilite(day: 'Mercredi', creneaux: []),
    Jourdisponibilite(day: 'Jeudi', creneaux: []),
    Jourdisponibilite(day: 'Vendredi', creneaux: []),
    Jourdisponibilite(day: 'Samedi', creneaux: []),
    Jourdisponibilite(day: 'Dimanche', creneaux: [])
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Color(0xfff5f5f5),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sélectionnez les jours de visite et ajoutez des créneaux horaires :',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250, 
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: disponibilites.length,
                itemBuilder: (context, index) {
                  final day = disponibilites[index];
                  return buildDay(day);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDay(Jourdisponibilite jour) {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(jour.day),
          value: jour.estDisponible,
          onChanged: (value) {
            setState(() {
              jour.estDisponible = value ?? false;
            });
            // si le jour devient disponible et aucun creneau n'est choisi
            if (jour.estDisponible && jour.creneaux.isEmpty) {
              jour.addCreneau(
                Creneau(
                  start: const TimeOfDay(hour: 9, minute: 0),
                  end: const TimeOfDay(hour: 17, minute: 0),
                ),
              );
            }
            widget.onDaychanged(disponibilites);
          },
          activeColor: Colors.blue,
        ),
        if (jour.estDisponible) ...[
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16),
            child: Column(
              children: [
                for (int i = 0; i < jour.creneaux.length; i++)
                  buildCreneauRow(jour, i),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      // Ajouter un nouveau créneau avec des heures par défaut
                      jour.addCreneau(
                        Creneau(
                          start: const TimeOfDay(hour: 14, minute: 0),
                          end: const TimeOfDay(hour: 18, minute: 0),
                        ),
                      );
                      widget.onDaychanged(disponibilites);
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter un créneau'),
                ),
                const Divider(),
              ],
            ),
          )
        ],
      ],
    );
  }

  Widget buildCreneauRow(Jourdisponibilite jour, int indexCReneau) {
    final timeSlot = jour.creneaux[indexCReneau];
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('De'),
            subtitle: Text(formatTimeOfDay(timeSlot.start)),
            onTap: () => selectTime(context, true, jour, indexCReneau),
            dense: true,
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('À'),
            subtitle: Text(formatTimeOfDay(timeSlot.end)),
            onTap: () => selectTime(context, false, jour, indexCReneau),
            dense: true,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            setState(() {
              jour.removeCreneau(indexCReneau);
              widget.onDaychanged(disponibilites);
            });
          },
        ),
      ],
    );
  }

  Future<void> selectTime(
    BuildContext context,
    bool isStart,
    Jourdisponibilite jour,
    int indexCReneau,
  ) async {
    final Creneau creneauCourant = jour.creneaux[indexCReneau];
    final TimeOfDay initialTime = isStart ? creneauCourant.start : creneauCourant.end;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          jour.creneaux[indexCReneau] = Creneau(
            start: pickedTime,
            end: creneauCourant.end,
          );
        } else {
          jour.creneaux[indexCReneau] = Creneau(
            start: creneauCourant.start,
            end: pickedTime,
          );
        }
        widget.onDaychanged(disponibilites);
      });
    }
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}