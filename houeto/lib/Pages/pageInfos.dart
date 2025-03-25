import 'package:flutter/material.dart';
import 'package:houeto/Pages/pageProfile.dart';

class PageInfos extends StatefulWidget {
  const PageInfos({super.key});

  @override
  State<PageInfos> createState() => _PageInfosState();
}

class _PageInfosState extends State<PageInfos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PageProfile()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),

        title: Text(
          'Informations personnelles',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
        body: UserInfoScreen(),
      );
    
  }
}

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  // Données existantes
  String firstName = "Hélène";
  String lastName = "AZANTI";

  String email = "azanti@example.com";
  String phone = "0163456789";
  
  String id = "ID12345";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        
        children: [
          buildEditableRow("Prénom", firstName, (value) {
            setState(() {
              firstName = value;
            });
          }),
          buildEditableRow("Nom", lastName, (value) {
            setState(() {
              lastName = value;
            });
          }),
          
          buildEditableRow("Email", email, (value) {
            setState(() {
              email = value;
            });
          }),
          buildEditableRow("Téléphone", phone, (value) {
            setState(() {
              phone = value;
            });
          }),
          
          
          buildEditableRow("ID", id, (value) {
            setState(() {
              id = value;
            });
          }),
        ],
      ),
    );
  }

  Widget buildEditableRow(String label, String value, Function(String) onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: label,
                
              ),
              controller: TextEditingController(text: value),
              onSubmitted: (newValue) {
                onSave(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }
}
