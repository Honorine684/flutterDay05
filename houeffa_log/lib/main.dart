import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:houeffa_log/ui/notificationpush.dart';
import 'package:houeffa_log/wrapper.dart';
import 'package:houeffa_log/auth/login.dart';
import 'package:houeffa_log/auth/verification.dart';
import 'package:houeffa_log/ui/profil.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/gl_screen.dart';
import 'screens/services_screen.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Notification en arrière-plan : ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  try {
    print("Initialisation de Firebase...");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase initialisé avec succès");
  } catch (e) {
    print("Erreur lors de l'initialisation de Firebase : $e");
    return;
  }

 
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  try {
    print("Initialisation des notifications locales...");
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification cliquée avec payload : ${response.payload}");
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => NotificationPage(
              title: "Notification locale",
              body: "Cliquez pour voir les détails",
              logementId: response.payload,
            ),
          ),
        );
      },
    );
    print("Notifications locales initialisées");
  } catch (e) {
    print("Erreur lors de l'initialisation des notifications locales : $e");
  }
  try {
    print("Demande de permission pour notifications...");
    await FirebaseMessaging.instance.requestPermission();
    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token : $token");
  } catch (e) {
    print("Erreur lors de la demande de permission FCM : $e");
  }

  print("Lancement de l'application...");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Construction de MyApp");
    return MaterialApp(
      title: 'Houeffa',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/wrapper': (context) => const Wrapper(),
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/verification': (context) => VerificationScreen(
              user: ModalRoute.of(context)!.settings.arguments as User,
            ),
        '/notification': (context) => NotificationPage(
              logementId: ModalRoute.of(context)!.settings.arguments as String?,
            ),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("Affichage de SplashScreen");
    Future.delayed(const Duration(seconds: 3), () {
      print("Redirection vers /wrapper");
      Navigator.pushReplacementNamed(context, '/wrapper');
    });

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue chez Houeffa',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ExploreScreen(),
    const GestionLocativeScreen(userId: ''),
    const ServicesScreen(logementId: ''),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print("Index sélectionné : $_selectedIndex");
    });
  }

  @override
  void initState() {
    super.initState();
    print("Initialisation de MainScreen");

    // Gestion des notifications en avant-plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Notification en avant-plan : ${message.notification?.title}");
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'Canal pour les notifications importantes',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );
      flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title ?? "Notification",
        message.notification?.body ?? "Nouveau message reçu",
        platformDetails,
        payload: message.data['tripId'],
      );
    });

    // Gestion des notifications ouvertes (depuis arrière-plan ou terminé)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification ouverte : ${message.data}");
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => NotificationPage(
            title: message.notification?.title,
            body: message.notification?.body,
            logementId: message.data['tripId'],
          ),
        ),
      );
    });

    // Vérifier si l'app a été ouverte par une notification au démarrage
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("App ouverte par une notification : ${message.data}");
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => NotificationPage(
              title: message.notification?.title,
              body: message.notification?.body,
              logementId: message.data['tripId'],
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Construction de MainScreen");
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _pages[_selectedIndex],
        key: ValueKey<int>(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorer'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Gestion'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}