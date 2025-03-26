import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Login.dart';
import 'package:houeto/firebase_options.dart';
import 'package:houeto/pageAnnonces.dart';
import 'package:houeto/pageDetails.dart';
import 'package:houeto/pageProfile.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
   runApp(MaterialApp(
   home: PageVisites(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor:Color(0xffF6CFF3),
    
      colorScheme: ColorScheme.light(
     primary: Colors.blue, 
    ),)));
}
