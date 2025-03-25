import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PickImage extends StatefulWidget {
  const PickImage({Key? key}) : super(key: key);

  @override
  _PickImageState createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  File? _image;

  Future<String?> _compressAndEncodeImage(File file) async {
    final filePath = file.path;
    final lastIndex = filePath.lastIndexOf('.');
    final outPath = "${filePath.substring(0, lastIndex)}_compressed.jpg";

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 85,
    );

    if (compressedFile == null) return null;

    // Convertir en Base64
    final bytes = await File(compressedFile.path).readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> getImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;

      final imageFile = File(pickedImage.path);
      setState(() {
        _image = imageFile;
      });

      final base64Image = await _compressAndEncodeImage(imageFile);
      if (base64Image != null) {
        Navigator.pop(context, base64Image);
      }
    } catch (e) {
      print('Erreur lors de la sélection ou compression : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
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
          ],
        ),
      ),
    );
  }
}