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
  String? selectedDay;
  String? selectedHour;
  String? conditionLocataire;
  String? telephone;
  List<String> availableHours = [];

  Stream<QuerySnapshot> getCrenauxForLogement(String logementId) {
    return FirebaseFirestore.instance
        .collection('logement')
        .doc(logementId)
        .collection('joursDisponibles')
        .where('estDisponible', isEqualTo: true)
        .snapshots();
  }

  void updateAvailableHours(String selectedDay) async {
    List<String> hours = [];
    for (int hour = 9; hour <= 17; hour++) {
      hours.add("$hour:00");
      hours.add("$hour:30");
    }
    setState(() => availableHours = hours);
  }

  Future<void> _saveReservation() async {
    if (selectedDay == null || selectedHour == null ||
        conditionLocataire == null || conditionLocataire!.trim().isEmpty ||
        telephone == null || telephone!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires.")),
      );
      return;
    }

    if (!RegExp(r'^9[0-9]{7}$|^6[0-9]{7}$').hasMatch(telephone!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un numéro de téléphone valide.")),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "Utilisateur non connecté";

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userData.exists || !userData.data()!.containsKey('nom')) {
        throw "Le champ 'nom' est manquant dans les données utilisateur.";
      }

      final logementData = await FirebaseFirestore.instance
          .collection('logement')
          .doc(widget.logementId)
          .get();

      final reservationData = {
        'conditionLocataire': conditionLocataire,
        'locataireId': user.uid,
        'locataireNom': userData.data()?['nom'] ?? 'Nom inconnu',
        'logementId': widget.logementId,
        'logementNom': logementData.data()?['nom'] ?? 'Nom inconnu',
        'jour': selectedDay,
        'heure': selectedHour,
        'statut': 'En attente',
        'timestamp': FieldValue.serverTimestamp(),
        'telephone': telephone
      };

      await FirebaseFirestore.instance.collection('visite').add(reservationData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Réservation envoyée avec succès !")),
        );
        setState(() {
          selectedDay = null;
          selectedHour = null;
          conditionLocataire = null;
          telephone = null;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: getCrenauxForLogement(widget.logementId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final jours = snapshot.data!.docs.map((doc) => doc.id).toList();
                return DropdownButtonFormField<String>(
                  value: selectedDay,
                  hint: const Text("Choisir un jour"),
                  items: jours.map((jour) => DropdownMenuItem(
                    value: jour,
                    child: Text(jour),
                  )).toList(),
                  onChanged: (value) {
                    setState(() => selectedDay = value);
                    updateAvailableHours(value!);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedHour,
              hint: const Text("Choisir une heure"),
              items: availableHours.map((hour) => DropdownMenuItem(
                value: hour,
                child: Text(hour),
              )).toList(),
              onChanged: (value) => setState(() => selectedHour = value),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: "Condition du locataire"),
              onChanged: (value) => conditionLocataire = value,
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: "Numéro de téléphone"),
              keyboardType: TextInputType.phone,
              onChanged: (value) => telephone = value,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveReservation,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Soumettre"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}