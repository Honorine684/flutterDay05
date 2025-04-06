import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

class Photo extends StatefulWidget {
  final List<String?>? initialPhotos;
  final void Function(List<String?> paths) onPhotosChanged;
  
  const Photo({
    super.key, 
    required this.onPhotosChanged,
    this.initialPhotos,
  });
  
  @override
  State<Photo> createState() => PhotoState();
}

class PhotoState extends State<Photo> {
  
  late final List<File?> images;
  late final List<String?> base64Images;
Future<File?> decodeBase64Image(String base64String, int index) async {
  try {
    final bytes = base64Decode(base64String);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/image_$index.jpg');
    await file.writeAsBytes(bytes);
    return file;
  } catch (e) {
    print('Erreur de décodage image: $e');
    return null;
  }
}  
@override
void initState() {
  super.initState();
  images = List.filled(4, null);
  base64Images = List.filled(4, null);
  
  if (widget.initialPhotos != null) {
    for (int i = 0; i < widget.initialPhotos!.length && i < 4; i++) {
      if (widget.initialPhotos![i] != null) {
        base64Images[i] = widget.initialPhotos![i];
        decodeBase64Image(widget.initialPhotos![i]!, i).then((file) {
          if (mounted && file != null) {
            setState(() {
              images[i] = file;
            });
          }
        });
      }
    }
  }
}

Future<File?> compressImage(File file) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // Qualité entre 0-100 (70 est un bon compromis)
      minWidth: 800, // Largeur maximale
      minHeight: 800, // Hauteur maximale
    );

    return result != null ? File(result.path) : null;
  } catch (e) {
    print('Erreur compression: $e');
    return null;
  }
}
Future<File?> compressVideo(File file) async {
  try {
    final compressedVideo = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality, 
      deleteOrigin: false, 
    );

    return compressedVideo?.file;
  } catch (e) {
    print('Erreur de compression vidéo: $e');
    return null;
  }
}

Future<void> pickMedia(int index) async {
  try {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    if (index == 3) {
      pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedFile == null || !mounted) return;

    File selectedFile = File(pickedFile.path);
    File? processedFile;

    if (index == 3) {
      processedFile = await compressVideo(selectedFile);
    } else {
      processedFile = await compressImage(selectedFile);
    }

    // Utiliser le fichier compressé si disponible, sinon l'original
    final fileToUse = processedFile ?? selectedFile;
    final fileSize = await fileToUse.length();

    if (fileSize > 5 * 1024 * 1024) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fichier trop volumineux'),
          content: const Text('Le fichier dépasse la limite autorisée (5 Mo).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final bytes = await fileToUse.readAsBytes();
    final base64 = base64Encode(bytes);

    if (!mounted) return;
    setState(() {
      images[index] = fileToUse;
      base64Images[index] = base64;
    });

    widget.onPhotosChanged(base64Images);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de la sélection: ${e.toString()}')),
    );
  }
}

  
  void removeImage(int index) {
    setState(() {
      images[index] = null;
      base64Images[index] = null;
    });
    widget.onPhotosChanged(base64Images);
  }

 Widget buildMediaSlot(int index) {
  final hasMedia = base64Images[index] != null;

  return Container(
    width: double.infinity,
    height: 100,
    margin: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: hasMedia
        ? Stack(
            fit: StackFit.expand,
            children: [
              index == 3
                  ? Center(child: Icon(Icons.videocam, size: 40, color: Colors.red))
                  : (images[index] != null 
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            images[index]!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container() // Fallback si image est null
                    ),
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    onPressed: () => removeImage(index),
                    padding: const EdgeInsets.all(2),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ),
            ],
          )
        : InkWell(
            onTap: () => pickMedia(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  index == 3 ? Icons.videocam : Icons.add_photo_alternate,
                  size: 24,
                  color: Colors.blue.shade300,
                ),
                const SizedBox(height: 4),
                Text("Média ${index + 1}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
  );
}
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Photos",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: buildMediaSlot(0)),
              const SizedBox(width: 8),
              Expanded(child: buildMediaSlot(1)),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(child: buildMediaSlot(2)),
              const SizedBox(width: 8),
              Expanded(child: buildMediaSlot(3)),
            ],
          ),
        ],
      ),
    );
  }
}