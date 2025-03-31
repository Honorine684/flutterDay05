import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DemandeLogement extends StatefulWidget {
  const DemandeLogement({super.key});

  @override
  _DemandeLogementState createState() => _DemandeLogementState();
}

class _DemandeLogementState extends State<DemandeLogement> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();

  String? _statut; 
  String? _typeLocation;

  
  final List<String> _statutOptions = [
    'Élève',
    'Étudiant',
    'Fonctionnaire',
    'Travailleur indépendant',
    'Salarié du privé',
    'Retraité',
    'Sans emploi',
  ];
  final List<String> _typeLocationOptions = ['Appartement', 'Maison', 'Boutique', 'Duplex'];

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté pour soumettre une demande.')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('demandede_logement').add({
          'nom': _nomController.text.trim(),
          'prenom': _prenomController.text.trim(),
          'adresse': _adresseController.text.trim(),
          'telephone': _telephoneController.text.trim(),
          'statut': _statut, 
          'typeLocation': _typeLocation,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'En attente', 
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande soumise avec succès !')),
        );

      
        _formKey.currentState!.reset();
        _nomController.clear();
        _prenomController.clear();
        _adresseController.clear();
        _telephoneController.clear();
        setState(() {
          _statut = null;
          _typeLocation = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la soumission : $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de Logement'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                
                TextFormField(
                  controller: _prenomController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                
                TextFormField(
                  controller: _adresseController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Champ Téléphone
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de téléphone';
                    }
                    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                      return 'Numéro de téléphone invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _statut,
                  decoration: const InputDecoration(
                    labelText: 'Statut Professionnel',
                    border: OutlineInputBorder(),
                  ),
                  items: _statutOptions.map((String statut) {
                    return DropdownMenuItem<String>(
                      value: statut,
                      child: Text(statut),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _statut = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner votre statut';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                
                DropdownButtonFormField<String>(
                  value: _typeLocation,
                  decoration: const InputDecoration(
                    labelText: 'Type de Location',
                    border: OutlineInputBorder(),
                  ),
                  items: _typeLocationOptions.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _typeLocation = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner un type de location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                
                Center(
                  child: ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Soumettre'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}