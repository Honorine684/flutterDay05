import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Reservation extends StatefulWidget {
  final String logementId;

  const Reservation({super.key, required this.logementId});

  @override
  State<Reservation> createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  DateTime selectedDate = DateTime.now();
  String? selectedDay;
  String? selectedHour;

  Stream<QuerySnapshot>? getCrenauxForLogement(String logementId) {
    if (logementId.isEmpty) {
      debugPrint("Erreur : logementId est vide");
      return null;
    }
    return FirebaseFirestore.instance
        .collection('logement')
        .doc(logementId)
        .collection('joursDisponibles')
        .snapshots();
  }

  Future<void> _saveReservation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "Utilisateur non connecté";

      final reservationData = {
        'userId': user.uid,
        'day': selectedDay,
        'hour': selectedHour,
        'date': "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
        'timestamp': FieldValue.serverTimestamp(),
        'amount': 5000,
        'status': 'pending',
        'logementId': widget.logementId,
      };

      await FirebaseFirestore.instance.collection('reservations').add(reservationData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Réservation envoyée pour 5000f ! En attente de confirmation.")),
        );
        setState(() {
          selectedDay = null;
          selectedHour = null;
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la réservation : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réserver un créneau"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: getCrenauxForLogement(widget.logementId),
          builder: (context, snapshot) {
            if (widget.logementId.isEmpty) {
              return const Center(child: Text("Erreur : Aucun logement spécifié"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              debugPrint("Erreur dans le snapshot : ${snapshot.error}");
              return const Center(child: Text("Erreur de chargement des disponibilités"));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("Aucune disponibilité pour ce logement"));
            }

            final availabilities = snapshot.data!.docs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (selectedDay == null || selectedHour == null)
                      ? "Date : ${selectedDate.year}-${selectedDate.month}-${selectedDate.day}"
                      : "Réservation : $selectedDay ${selectedDate.year}-${selectedDate.month}-${selectedDate.day} à $selectedHour",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? dateTime = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (dateTime != null) {
                      setState(() {
                        selectedDate = dateTime;
                        selectedDay = null;
                        selectedHour = null;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                  child: const Text("Choisir une date"),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Jours disponibles :",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: availabilities.length,
                    itemBuilder: (context, index) {
                      final data = availabilities[index].data() as Map<String, dynamic>;
                      final day = data['day'] as String;
                      final date = data['date'] as String;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDay = day;
                              selectedDate = DateTime.parse(date);
                              selectedHour = null;
                            });
                          },
                          child: Chip(
                            label: Text(day),
                            backgroundColor: selectedDay == day
                                ? Colors.deepOrangeAccent
                                : Colors.grey[300],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                if (selectedDay != null) ...[
                  const Text(
                    "Heures disponibles :",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: availabilities
                          .firstWhere((doc) => (doc['day'] as String) == selectedDay)
                          ['hours']
                          .length,
                      itemBuilder: (context, index) {
                        final hours = (availabilities
                            .firstWhere((doc) => (doc['day'] as String) == selectedDay)['hours'] as List<dynamic>);
                        final hour = hours[index] as String;

                        return ListTile(
                          title: Text(hour),
                          tileColor: selectedHour == hour
                              ? Colors.deepOrangeAccent.withOpacity(0.2)
                              : null,
                          onTap: () {
                            setState(() {
                              selectedHour = hour;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: (selectedDay != null && selectedHour != null)
                        ? _saveReservation
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      backgroundColor: (selectedDay != null && selectedHour != null)
                          ? Colors.deepOrangeAccent
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Confirmer et payer 5000f",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}