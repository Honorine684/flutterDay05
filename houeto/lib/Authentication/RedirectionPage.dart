import 'package:flutter/material.dart';
import 'package:houeto/Authentication/Login.dart';
import 'package:houeto/Component/BottomBar.dart';
import 'package:houeto/Services/Firebase/auth.dart';

class Redirectionpage extends StatefulWidget {
  const Redirectionpage({super.key});

  @override
  State<Redirectionpage> createState() => RedirectionpageState();
}

class RedirectionpageState extends State<Redirectionpage> {
  bool _minDelayElapsed = false;
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
    // Démarrer le timer pour le délai minimum
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _minDelayElapsed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChange,
      builder: (context, snapshot) {
        // Mettre à jour l'état quand l'authentification est vérifiée
        if (!_authChecked && snapshot.connectionState != ConnectionState.waiting) {
          _authChecked = true;
        }

        // Afficher l'écran de chargement si:
        //  Le délai minimum n'est pas écoulé OU
        // L'authentification est toujours en cours
        if (!_minDelayElapsed || snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        } else if (snapshot.hasData) {
          return const Bottombar();
        } else {
          return const ConnexionPage();
        }
      },
    );
  }

  Widget LoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation avec effet de pulsation
            TweenAnimationBuilder(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade600,
                          ),
                          strokeWidth: 6,
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.home_rounded,
                        size: 50,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Texte avec effet de fondu
            AnimatedOpacity(
              opacity: _minDelayElapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  Text(
                    "Chargement...",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Veuillez patienter",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}