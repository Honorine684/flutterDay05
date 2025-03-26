import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Authentication/RedirectionPage.dart';
import 'package:houeto/Pages/AcceptConfierScreen.dart';
import 'package:houeto/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': newToken});
    }
  });
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.data['type'] == 'confier') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => Acceptconfierscreen(
            logementId: message.data['logementId'],
            demandeurId: message.data['destinataireId'],
          ),
        ),
      );
    }
  });
   runApp(MaterialApp(
   navigatorKey: navigatorKey,  
   home: Redirectionpage(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor:Color(0xffF6CFF3),
    
      colorScheme: ColorScheme.light(
     primary: Colors.blue, 
    ),)));
}
