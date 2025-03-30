import 'package:flutter/material.dart';
import 'package:houeto/Pages/DashboardProprio.dart';
import 'package:houeto/Pages/PageGestion.dart';
import 'package:houeto/Pages/SeeAllBien.dart';
import 'package:houeto/Pages/pageProfile.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int selected = 0;
  final controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: PageView(
          controller: controller,
          children: [
            ProprioDashboard(),
            Seeallbien(),
            PageGestion(),
            PageProfile(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: kBottomNavigationBarHeight + 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Accueil',
                  isSelected: selected == 0,
                  onTap: () => _navigateToPage(0),
                ),
                _buildNavItem(
                  icon: Icons.real_estate_agent_rounded,
                  label: 'Biens',
                  isSelected: selected == 1,
                  onTap: () => _navigateToPage(1),
                ),
                SizedBox(width: 60), // Espace pour le bouton central
                _buildNavItem(
                  icon: Icons.gesture_outlined,
                  label: 'Gestion',
                  isSelected: selected == 2,
                  onTap: () => _navigateToPage(2),
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Profil',
                  isSelected: selected == 3,
                  onTap: () => _navigateToPage(3),
                ),
              ],
            ),
            Center(
              child: Transform.translate(
                offset: Offset(0, -25),
                child: GestureDetector(
                  onTap: () {
                    // Action pour le bouton central
                    _navigateToPage(1); 
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    setState(() {
      selected = index;
      controller.jumpToPage(index);
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? _getColorForIndex(selected) : Colors.grey[600],
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? _getColorForIndex(selected) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return Colors.blueAccent;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}