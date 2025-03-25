import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class PickImage extends StatefulWidget {
  const PickImage({Key? key}) : super(key: key);

  @override
  _PickImageState createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  File? _image;

  Future getImage(ImageSource source) async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      // Sauvegarde permanente de l'image
      final imagePermanent = await saveFilePermanently(image.path);

      setState(() {
        _image = imagePermanent;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<File> saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une image'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
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
            CustomButton(
              title: 'Choisir depuis la galerie',
              icon: Icons.image_outlined,
              onClick: () => getImage(ImageSource.gallery),
            ),
            const SizedBox(height: 20),
            CustomButton(
              title: 'Choisir depuis la caméra',
              icon: Icons.camera,
              onClick: () => getImage(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}

Widget CustomButton({
  required String title,
  required IconData icon,
  required VoidCallback onClick,
}) {
  return Container(
    width: 280,
    child: ElevatedButton(
      onPressed: onClick,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 20),
          Text(title),
        ],
      ),
    ),
  );
}