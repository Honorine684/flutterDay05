import 'package:flutter/material.dart';

class Etatchoice extends StatefulWidget {
  final String selectedEtat;
  final void Function(String selectedEtat) onEtatChanged;
  const Etatchoice({
    super.key,
    required this.selectedEtat,
    required this.onEtatChanged,
  });

  @override
  EtatchoiceState createState() => EtatchoiceState();
}

class EtatchoiceState extends State<Etatchoice> {
  String? selectedEtat; 

  final List<String> etats = ["Neuf", "Bon état", "À rénover"];
  final Map<String, IconData> etatIcons = {
    "Neuf": Icons.new_releases,
    "Bon état": Icons.check_circle,
    "À rénover": Icons.construction,
  };

  @override
  void initState() {
    super.initState();
    selectedEtat = widget.selectedEtat;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("État général:", style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        InkWell(
          onTap: () {
            _showEtatMenu(context);
          },
          child: Row(
            children: [
              Icon(
                etatIcons[selectedEtat ?? "Neuf"],
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              Text(
                selectedEtat ?? "Sélectionnez un état",
                style: TextStyle(fontSize: 14),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  void _showEtatMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height * 2,
      ),
      items: etats.map((String etat) {
        return PopupMenuItem(
          value: etat,
          child: Row(
            children: [
              Icon(etatIcons[etat]),
              SizedBox(width: 8),
              Text(etat),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedEtat = value;
        });
        widget.onEtatChanged(value);
      }
    });
  }
}