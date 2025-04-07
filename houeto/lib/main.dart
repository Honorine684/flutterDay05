import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Authentication/RedirectionPage.dart';
import 'package:houeto/Services/Firebase/push_notifications.dart';
import 'package:houeto/firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  final pushNotificationService = PushNotification();
  
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': newToken});
    }
  });

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await pushNotificationService.checkPendingNotifications();
  });

   runApp(MaterialApp(
    
    navigatorKey: navigatorKey,
    home: FutureBuilder(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await pushNotificationService.checkPendingNotifications();
          });
        }
        return Redirectionpage();
        
      },
    ),
    debugShowCheckedModeBanner: false,
    
    theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor:Color(0xFF2A3647),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    
      colorScheme: ColorScheme.light(
     primary: Colors.blue, 
     
     
    ),
  )));
}