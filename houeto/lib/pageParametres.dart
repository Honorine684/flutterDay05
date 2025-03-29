import 'package:flutter/material.dart';


/// Application principale
class ParametresPage extends StatelessWidget {
  const ParametresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Paramètres',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const EcranParametres(),
    );
  }
}


class EcranParametres extends StatefulWidget {
  const EcranParametres({super.key});

  @override
  State<EcranParametres> createState() => _EcranParametresState();
}

class _EcranParametresState extends State<EcranParametres> {
 
  bool _notifEmail = false;
  bool _notifSMS = false;
  bool _notifPush = false;
  bool _authDoubleFacteur = false;

  String _langueChoisie = 'Français';
  String _deviseChoisie = 'FCFA ';
  String _fuseauChoisi = 'Paris (UTC+1/+2)';

  final List<String> _languesDisponibles = [
    'Français',
    'Anglais',
    'Espagnol',
    'Allemand'
  ];

  final List<String> _devisesDisponibles = [
    'FCFA',
    'Dollar',
    'Livre ',
    'Euro'
  ];

  final List<String> _fuseauxDisponibles = [
    'Paris (UTC+1/+2)',
    'New York (UTC-5/-4)',
    'Tokyo (UTC+9)',
    'Sydney (UTC+10/+11)'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres de l\'Application'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            _TitreSection('Préférences de Notification'),
            _OptionInterrupteur(
                'Notifications par E-mail', _notifEmail, (v) {
              setState(() => _notifEmail = v);
            }),
            _OptionInterrupteur('Notifications SMS', _notifSMS, (v) {
              setState(() => _notifSMS = v);
            }),
            _OptionInterrupteur('Notifications Push', _notifPush, (v) {
              setState(() => _notifPush = v);
            }),

            const SizedBox(height: 24),
            const Divider(),

            // Section Paramètres du compte
            _TitreSection('Paramètres du Compte'),
            _OptionMenuDeroulant(
                'Langue', _langueChoisie, _languesDisponibles, (nouvelleValeur) {
              setState(() => _langueChoisie = nouvelleValeur);
            }),
            _OptionMenuDeroulant(
                'Devise', _deviseChoisie, _devisesDisponibles, (nouvelleValeur) {
              setState(() => _deviseChoisie = nouvelleValeur);
            }),
            _OptionMenuDeroulant(
                'Fuseau Horaire', _fuseauChoisi, _fuseauxDisponibles, (nouvelleValeur) {
              setState(() => _fuseauChoisi = nouvelleValeur);
            }),

            const SizedBox(height: 24),
            const Divider(),

           
            _TitreSection('Sécurité'),
            _OptionInterrupteur(
                'Authentification à Deux Facteurs', _authDoubleFacteur, (v) {
              setState(() => _authDoubleFacteur = v);
            }),

            const SizedBox(height: 32),

          
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _sauvegarderParametres,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SAUVEGARDER LES MODIFICATIONS',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _TitreSection(String titre) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        titre,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _OptionInterrupteur(
      String titre, bool valeur, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(titre),
      value: valeur,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }


  Widget _OptionMenuDeroulant(
      String titre, String valeur, List<String> options, Function(String) onChanged) {
    return ListTile(
      title: Text(titre),
      trailing: DropdownButton<String>(
        value: valeur,
        items: options
            .map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  
  void _sauvegarderParametres() {
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vos paramètres ont été sauvegardés avec succès !'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

