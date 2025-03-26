import 'package:flutter/material.dart';

class Acceptconfierscreen extends StatefulWidget{
    final String logementId, demandeurId;

  const Acceptconfierscreen({super.key,required this.demandeurId,required this.logementId});

  @override
  State<Acceptconfierscreen> createState() {
    return AcceptconfierscreenState();
  }
 


}
class AcceptconfierscreenState extends State<Acceptconfierscreen>  {

  /*Future<void> _accepter() async {
    // 1. Met à jour le logement (optionnel, si besoin de confirmation)
    await FirebaseFirestore.instance
        .collection('logements')
        .doc(logementId)
        .update({'statut': 'confirme'});

    // 2. Notifie le demandeur (ex: via une autre notification)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Vous gérez maintenant ce logement !")),
    );
    Navigator.pop(context);
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Accepter la gestion")),
      body: Center(
        child: Column(
          children: [
            Text("Voulez-vous devenir gestionnaire de ce logement ?"),
            ElevatedButton(
              onPressed:(){}  ,  // _accepter,
              child: Text("Accepter"),
            ),
          ],
        ),
      ),
    );
  }
}