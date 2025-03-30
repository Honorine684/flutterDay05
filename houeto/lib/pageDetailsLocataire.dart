
import 'package:flutter/material.dart';

class PageDetailsLocataire extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil du Locataire'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              _enteteProfile(),
              
              SizedBox(height: 20),
              
              
              _titreSection('Informations Personnelles'),
              _carteInformations([
                _ligneInformation('Âge', '28 ans'),
                _ligneInformation('Profession', 'Ingénieur'),
                _ligneInformation('Revenu Mensuel', '350 000 FCFA'),
              ]),
              
              SizedBox(height: 20),
              
              
              _titreSection('Exigences de Logement'),
              _carteInformations([
                _ligneInformation('Type de Logement', 'Appartement 2 pièces'),
                _ligneInformation('Budget Mensuel', '75 000 FCFA'),
                _ligneInformation('Localisation', 'Cotonou'),
              ]),
              
              SizedBox(height: 20),
              
           
              _titreSection('Sérieux et Garanties'),
              _carteSerieux(),
              
              SizedBox(height: 20),
        
              _boutonsAction(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _enteteProfile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://exemple.com/photo.jpg'),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elisha Richard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'elisha.richard@exemple.com',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '+229 96 XX XX XX',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titreSection(String titre) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        titre,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _carteInformations(List<Widget> enfants) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: enfants,
        ),
      ),
    );
  }

  Widget _ligneInformation(String libelle, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            libelle,
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            valeur,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _carteSerieux() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ligneSerieux('Justificatif de Revenu', 'Validé'),
            _ligneSerieux('Référence Employeur', 'En cours'),
            _ligneSerieux('Casier Judiciaire', 'Validé'),
            _ligneSerieux('Notation de Crédit', '8/10'),
          ],
        ),
      ),
    );
  }

  Widget _ligneSerieux(String libelle, String statut) {
    Color couleurStatut = statut.toLowerCase().contains('validé') 
        ? Colors.green 
        : statut.toLowerCase().contains('en cours') 
            ? Colors.orange 
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            libelle,
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            statut,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: couleurStatut,
            ),
          ),
        ],
      ),
    );
  }

  Widget _boutonsAction(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text('Rejeter'),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _afficherDialogueConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text('Accepter'),
          ),
        ),
      ],
    );
  }

  void _afficherDialogueConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment sélectionner ce locataire ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirmer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}





