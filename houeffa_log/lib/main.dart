import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:houeffa_log/auth/auth_service.dart';


import 'package:houeffa_log/wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, 
    );
    print("Firebase initialisé avec succès");
    runApp(MyApp());
  } catch (e) {
    print("Erreur lors de l'initialisation de Firebase : $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HouefFa Toit',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const Wrapper(),
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Page Explorer", style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text("Compteur : $_counter"),
          ElevatedButton(
            onPressed: _incrementCounter,
            child: Text("Incrémenter"),
          ),
        ],
      ),
    );
  }
}


class Reservation extends StatefulWidget {
  const Reservation({super.key});

  @override
  State<Reservation> createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  bool _isReserved = false;

  void _toggleReservation() {
    setState(() {
      _isReserved = !_isReserved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Réservations", style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text(_isReserved ? "Réservé !" : "Non réservé"),
          ElevatedButton(
            onPressed: _toggleReservation,
            child: Text(_isReserved ? "Annuler" : "Réserver"),
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

  void _updateStatus() {
    setState(() {
      _status = _status == "En attente" ? "Terminé" : "En attente";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Tableau de bord", style: TextStyle(fontSize: 24)),
          SizedBox(height: 20),
          Text("Statut : $_status"),
          ElevatedButton(
            onPressed: _updateStatus,
            child: Text("Changer statut"),
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
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la déconnexion : $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Profil", style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text("Se déconnecter", style: TextStyle(color: Colors.white)),
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
  final List<Widget> _pages = [
    const ExplorePage(),
    const Reservation(),
    const DashboardPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print("Page sélectionnée : $index"); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HouefFa Toit")),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.explore, size: 30, color: Colors.white),
          Icon(Icons.calendar_today, size: 30, color: Colors.white),
          Icon(Icons.dashboard, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: Colors.deepOrangeAccent,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: _onItemTapped,
      ),
    );
  }
}