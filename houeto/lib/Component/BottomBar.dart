import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Pages/AddLogement.dart';
import 'package:houeto/Pages/Home.dart';
import 'package:houeto/Pages/SeeAllBien.dart';
import 'package:houeto/Pages/ShowBien.dart';
import 'package:houeto/Pages/pageProfile.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int selected = 0;
  bool add = false;
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

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), 
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: selected == 0 ? Colors.teal : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selected = 0;
                  controller.jumpToPage(0);
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.real_estate_agent,
                color: selected == 1 ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selected = 1;
                  controller.jumpToPage(1);
                });
              },
            ),
            const SizedBox(width: 48), // Espace pour le bouton flottant
            IconButton(
              icon: Icon(
                Icons.visibility,
                color: selected == 2 ? Colors.deepOrangeAccent : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selected = 2;
                  controller.jumpToPage(2);
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: selected == 3 ? Colors.deepPurple : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  selected = 3;
                  controller.jumpToPage(3);
                });
              },
            ),
          ],
        ),
      ),

      // Bouton flottant centré
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const Addlogement()));
            //add = !add;
          });
        },
        backgroundColor: Colors.white,
        child: Icon(
          add ? Icons.add : CupertinoIcons.add,
          color: Colors.blue,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Corps de la page
      body: SafeArea(
        child: PageView(
          controller: controller,
          children: const [
            Home(),
            Showbien(),
            Seeallbien() ,
            PageProfile(),
          ],
        ),
      ),
    );
  }
}