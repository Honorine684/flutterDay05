import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Pages/AddLogement.dart';
import 'package:houeto/Pages/Gestion.dart';
import 'package:houeto/Pages/Home.dart';
import 'package:houeto/Pages/SeeAllBien.dart';
import 'package:houeto/Pages/pageProfile.dart';
import 'package:houeto/Pages/pageVisite.dart';

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
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(),
          StadiumBorder(side: BorderSide()),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                    Icons.real_estate_agent_rounded,
                    color: selected == 1 ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      selected = 1;
                      controller.jumpToPage(1);
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.golf_course_rounded,
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
                    color: selected == 3 ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      selected = 3;
                      controller.jumpToPage(3);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: selected == 4 ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      selected = 4;
                      controller.jumpToPage(4);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      // Bouton flottant à droite
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const Addlogement()));
        },
        backgroundColor: Colors.white,
        child: Icon(
          add ? Icons.add : CupertinoIcons.add,
          color: Colors.blue,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      // Corps de la page
      body: SafeArea(
        child: PageView(
          controller: controller,
          children: [
          PageAccueil(),            
            Home(),
            Seeallbien(),
            PageVisites(),
            PageProfile(),
          ],
        ),
      ),
    );
  }
}