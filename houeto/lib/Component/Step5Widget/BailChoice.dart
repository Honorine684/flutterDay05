import 'package:flutter/material.dart';

class Bailchoice extends StatefulWidget {
  final String selectedBail;
  final void Function(String selectedBail) onEtatChanged; 
  const Bailchoice({
    super.key,
    required this.selectedBail,
    required this.onEtatChanged,
  });

  @override
  BailchoiceState createState() => BailchoiceState();
}

class BailchoiceState extends State<Bailchoice> {
  String? selectedBail; 

  final List<String> etats = ["Mensuel", "Avancé"];
  final Map<String, IconData> etatIcons = {
    "Mensuel": Icons.calendar_view_month,
    "Avancé": Icons.golf_course,
  };

  @override
  void initState() {
    super.initState();
    selectedBail = widget.selectedBail;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Type du bail:", style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        InkWell(
          onTap: () {
            
            _showEtatMenu(context);
          },
          child: Row(
            children: [
              Icon(
                etatIcons[selectedBail ?? "Mensuel"],
                color: Colors.blue,
              ),
              SizedBox(width: 8),
              Text(
                selectedBail ?? "Sélectionnez un état",
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
          selectedBail = value; 
        });
        widget.onEtatChanged(value);
      }
    });
  }
}