import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:houeffa_log/auth/auth_service.dart';
import 'package:houeffa_log/ui/reservation.dart';
import 'package:houeffa_log/wrapper.dart';

import 'firebase_options.dart';

const String appTitle = 'HouefFa Toit';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialisé avec succès");
    runApp(const MyApp());
  } catch (e) {
    debugPrint("Erreur lors de l'initialisation de Firebase : $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        useMaterial3: true,
      ),
      home: const Wrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  int _counter = 0;

  void _incrementCounter() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    debugPrint("Rendu de ExplorePage");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Page Explorer", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          Text("Compteur : $_counter"),
          ElevatedButton(
            onPressed: _incrementCounter,
            child: const Text("Incrémenter"),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _status = "En attente";

  void _updateStatus() => setState(() => _status = _status == "En attente" ? "Terminé" : "En attente");

  @override
  Widget build(BuildContext context) {
    debugPrint("Rendu de DashboardPage");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Tableau de bord", style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          Text("Statut : $_status"),
          ElevatedButton(
            onPressed: _updateStatus,
            child: const Text("Changer statut"),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signOut();
      debugPrint("Déconnexion réussie");
    } catch (e) {
      debugPrint("Erreur lors de la déconnexion : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la déconnexion : $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Rendu de ProfilePage");
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Profil", style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Se déconnecter"),
                ),
              ],
            ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const ExplorePage(key: ValueKey("explore")),
    const Reservation(key: ValueKey("reservation")),
    const DashboardPage(key: ValueKey("dashboard")),
    const ProfilePage(key: ValueKey("profile")),
  ];

  void _onItemTapped(int index) {
    debugPrint("Clic détecté sur l’index : $index");
    setState(() {
      _selectedIndex = index;
      debugPrint("Nouvel index sélectionné : $_selectedIndex");
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Construction de HomeScreen avec index : $_selectedIndex");
    return Scaffold(
      appBar: AppBar(title: const Text(appTitle)),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.explore, size: 30, color: Colors.white),
          Icon(Icons.calendar_today, size: 30, color: Colors.white),
          Icon(Icons.dashboard, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: Colors.deepOrangeAccent,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _onItemTapped,
      ),
    );
  }
}