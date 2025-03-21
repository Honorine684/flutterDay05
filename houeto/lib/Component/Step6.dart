import 'package:flutter/material.dart';
import 'package:houeto/Component/Step3Widget/Photo.dart';

class Step6 extends StatefulWidget {
  final void Function(Map<String, dynamic> data) onDataChanged;
  const Step6({super.key, required this.onDataChanged});

  @override
  State<Step6> createState() {
    return Step6State();
  }
}

class Step6State extends State<Step6> {
  List<String?> photoPaths = List.filled(4, null);
  
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