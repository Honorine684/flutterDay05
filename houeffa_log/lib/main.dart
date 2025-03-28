import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:houeffa_log/wrapper.dart';
import 'package:houeffa_log/auth/login.dart';
import 'package:houeffa_log/auth/verification.dart';
import 'package:houeffa_log/ui/profil.dart';
import 'package:houeffa_log/ui/notificationpush.dart';
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        '/verification': (context) {
          final user = ModalRoute.of(context)?.settings.arguments as User?;
          if (user == null) {
            return const Scaffold(body: Center(child: Text("Utilisateur requis")));
          }
          return VerificationScreen(user: user);
        },
        '/notification': (context) => const NotificationPage(),
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
      backgroundColor: Colors.orange,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenue chez Houeffa',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Explorer'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Gestion'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}