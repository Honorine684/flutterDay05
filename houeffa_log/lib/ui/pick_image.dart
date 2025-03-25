 import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class PickImage extends StatefulWidget {
  const PickImage ({ Key?key}): super (key: key);
  @override

  _PickImageState createState() => _PickImageState();
}

class _PickImageState extends State<PickImage>{

  File? _image;

  Future getImage(ImageSource source) async{
    try{

    
    final image = await ImagePicker ().pickImage(source:source);
    if( image == null ) return;

    //final imageTemporary = File(image.path);
    final imagePermanent = await saveFilePermanently(image.path);

    setState((){
      this._image = imagePermanent;

    });
  } on PlatformException catch (e){
    print('Failed to pick image:$e');
  }
  }
  Future<File>saveFilePermanently( String imagePath) async{
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(imagePath);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text('Choisir une image')
      ),

      body:Center(
        child: Column( children: [
        SizedBox(height: 40,),

       _image != null? Image.file(_image!,width:250,height:250,fit:BoxFit.cover ,
       )
       : Image.network('https://www.pexels.com/fr-fr/photo/portrait-photo-d-une-femme-3992656/'),
        SizedBox(height: 40,),
        CustomButton(
        title:'Choisir depuis la gallerie', 
        icon:Icons.image_outlined,
        onClick: ()=> getImage(ImageSource.gallery)
        ),

         CustomButton(
        title:'Choisir depuis la caméra', 
        icon:Icons.camera,
        onClick: ()=> getImage(ImageSource.camera)
        ),
       

        ],)
      )
    );

  }
}
Widget CustomButton({
 required String title,
  required IconData icon,
  required VoidCallback onClick,
}){
  return Container(
    width: 280,
    child:ElevatedButton(
      onPressed: onClick, 
      child: Row(
      children: [
        Icon(icon),
        SizedBox(width:20),
        Text(title)
      ],
    ),),
    );
}