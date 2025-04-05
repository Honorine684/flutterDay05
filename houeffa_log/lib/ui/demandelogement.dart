import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DemandeLogement extends StatefulWidget {
  final dynamic logementId;

  const DemandeLogement({super.key, required this.logementId});
  
  @override
  _DemandeLogementState createState() => _DemandeLogementState();
}

class _DemandeLogementState extends State<DemandeLogement> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  String _typeLocation = 'Appartement';

  final List<String> _typesLocation = ['Appartement', 'Maison', 'Chambre', 'Studio'];

  bool _isLoading = false;

  Future<void> _soumettreDemande() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Utilisateur non connecté')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // 🔍 Debug
        print('logement_id reçu : ${widget.logementId}');
        print('locataire_id : ${user.uid}');

        await FirebaseFirestore.instance.collection('demandes_logement').add({
          'nom': _nomController.text.trim(),
          'prenom': _prenomController.text.trim(),
          'adresse': _adresseController.text.trim(),
          'telephone': _telephoneController.text.trim(),
          'profession': _professionController.text.trim(),
          'type_location': _typeLocation,
          'timestamp': Timestamp.now(),
          'logement_id': widget.logementId.toString(), // ✅ forcer en string
          'locataire_id': user.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demande envoyée avec succès')),
        );

        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la soumission : $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demande de Logement'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nomController, 'Nom'),
              _buildTextField(_prenomController, 'Prénom'),
              _buildTextField(_adresseController, 'Adresse'),
              _buildTextField(_telephoneController, 'Téléphone', TextInputType.phone),
              _buildTextField(_professionController, 'Profession'),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Type de Location',
                  border: OutlineInputBorder(),
                ),
                value: _typeLocation,
                items: _typesLocation.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _typeLocation = value!;
                  });
                },
              ),
              SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _soumettreDemande,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Soumettre', style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType type = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.trim().isEmpty ? 'Ce champ est requis' : null,
      ),
    );
  }
}