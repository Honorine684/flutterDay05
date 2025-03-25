import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickImage extends StatefulWidget {
  const PickImage({Key? key}) : super(key: key);

  @override
  _PickImageState createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  File? _image;

  Future<void> getImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;

      final imageFile = File(pickedImage.path);

      setState(() {
        _image = imageFile;
      });
    } catch (e) {
      print('Erreur lors de la sélection de l’image : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  void _confirmImage() {
    if (_image != null) {
      Navigator.pop(context, _image);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une image d’abord')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(
                    _image!,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    'https://images.pexels.com/photos/3992656/pexels-photo-3992656.png?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => getImage(ImageSource.gallery),
              child: const Text('Choisir depuis la galerie'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => getImage(ImageSource.camera),
              child: const Text('Choisir depuis la caméra'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }
}