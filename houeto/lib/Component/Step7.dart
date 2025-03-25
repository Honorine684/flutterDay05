import 'package:flutter/material.dart';

class Step7 extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  final Map<String, dynamic>? initialData;
  
  const Step7({
    super.key, 
    required this.onDataChanged,
    this.initialData,
  });

  @override
  State<Step7> createState() => Step7State();
}

class Step7State extends State<Step7> {
  late final TextEditingController description;

  @override
  void initState() {
    super.initState();
    description = TextEditingController(text: widget.initialData?['description'] ?? '');
    description.addListener(sendDataToParent);
  }

  @override
  void didUpdateWidget(covariant Step7 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      description.text = widget.initialData?['description'] ?? '';
    }
  }

  @override
  void dispose() {
    description.removeListener(sendDataToParent);
    description.dispose();
    super.dispose();
  }

  void sendDataToParent() {
    widget.onDataChanged({
      'description': description.text, 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: description,
          decoration: const InputDecoration(
            labelText: 'Description (Que voulez-vous rajouter ?)',
            labelStyle: TextStyle(fontSize: 13)
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
        ),
      ],
    );
  }
}