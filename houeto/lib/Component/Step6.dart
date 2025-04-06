import 'package:flutter/material.dart';
import 'package:houeto/Component/Step3Widget/Photo.dart';

class Step6 extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  final Map<String, dynamic>? initialData;
  
  const Step6({
    super.key, 
    required this.onDataChanged,
    this.initialData,
  });

  @override
  State<Step6> createState() => Step6State();
}

class Step6State extends State<Step6> {
  late List<String?> photoPaths;

  @override
  void initState() {
    super.initState();
    // Initialisation avec les valeurs par défaut ou celles fournies
        photoPaths = [
      widget.initialData?['photo1'],
      widget.initialData?['photo2'],
      widget.initialData?['photo3'],
      widget.initialData?['photo4'],
    ].whereType<String>().toList(); 
  
  }

  @override
  void didUpdateWidget(covariant Step6 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      setState(() {
        photoPaths = [
          widget.initialData?['photo1'],
          widget.initialData?['photo2'],
          widget.initialData?['photo3'],
          widget.initialData?['photo4'],
        ];
      });
    }
  }

  void sendDataToParent() {
    final Map<String, dynamic> data = {
      'photo1': photoPaths[0],
      'photo2': photoPaths[1],
      'photo3': photoPaths[2],
      'photo4': photoPaths[3],
    };
    
    widget.onDataChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Photo(
          initialPhotos: photoPaths,
          onPhotosChanged: (List<String?> paths) {
            setState(() {
              photoPaths = paths;
            });
            sendDataToParent();
          },
        ),
      ],
    );
  }
}