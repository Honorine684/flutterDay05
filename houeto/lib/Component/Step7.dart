import 'package:flutter/material.dart';

class Step7 extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  const Step7({super.key,required this.onDataChanged});

  @override
  State<Step7> createState() {
    return Step7State();
  }
}

class Step7State extends State<Step7> {
  final description = TextEditingController();
  void sendDataToParent() {
    Map<String, dynamic> data = {
      'description':description
    };

    widget.onDataChanged(data); // Appel du callback avec les données
  }
@override
  void initState() {
    sendDataToParent();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextFormField(
          controller: description,
          decoration: const InputDecoration(
            labelText: 'Description(Que voulez-vous rajouter?)',
          ),
          maxLines: 5,
        ),
      const SizedBox(height: 10),
      const Text(
        "En cliquant sur Confirmer, vous acceptez nos conditions d'utilisation et notre politique de confidentialité.",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      )
    ]);
  }
}