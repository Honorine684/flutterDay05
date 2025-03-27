import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Pages/NotificationsPage.dart';
import 'package:houeto/Pages/ShowBien.dart';
import 'package:houeto/Services/Firebase/auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  String nom = '';
String prenom = '';
String email = '';
String uid = '';
Future<void> getUserData()async{
  try{
    final User? currentUser = Auth().currentUser;
    DocumentSnapshot userDoc =  await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    if(userDoc.exists){
      setState(() {
        //uid = userDoc.get('uid');
        nom = userDoc.get('nom')?? '';
        prenom = userDoc.get('prenom')?? '';
        email = currentUser.email??'';
      });
    }
  }catch(e){
    print("erreur lors de la recupération de l'user $e");
  }
}

@override
  void initState() {
    getUserData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;
    final hauteurEcran = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              width: largeurEcran * 0.25,
            ),
            Text(
              "Tableau de bord",
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
        actions: [IconButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const NotificationsPage()));
        }, icon: Icon(Icons.notification_add_rounded))],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Bienvenue,$prenom",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: hauteurEcran * 0.025,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  color: const Color.fromARGB(255, 84, 189, 87),
                  elevation: 4,
                  child: SizedBox(
                    width: largeurEcran * 0.4,
                    height: hauteurEcran * 0.13,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Nombre de propriétés",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: largeurEcran * 0.28,
                            ),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: Center(
                                child: Text(
                                  "4",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  color: const Color.fromARGB(255, 119, 29, 29),
                  elevation: 4,
                  child: SizedBox(
                    width: largeurEcran * 0.4,
                    height: hauteurEcran * 0.13,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Nombre de locataires",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: largeurEcran * 0.28,
                            ),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: Center(
                                child: Text(
                                  "4",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: hauteurEcran * 0.013,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 4,
                  child: SizedBox(
                    width: largeurEcran * 0.4,
                    height: hauteurEcran * 0.18,
                    child: Column(
                      children: [
                        SizedBox(
                          height: hauteurEcran * 0.035,
                        ),
                        Icon(
                          Icons.wallet,
                          size: 40,
                        ),
                        Text(
                          "Paiements reçus",
                          style: TextStyle(fontSize: 13),
                        ),
                        Text(
                          "10000 FCFA",
                          style: TextStyle(fontSize: 11, color: Colors.amber),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  child: SizedBox(
                    width: largeurEcran * 0.4,
                    height: hauteurEcran * 0.18,
                    child: Column(
                      children: [
                        SizedBox(
                          height: hauteurEcran * 0.035,
                        ),
                        IconButton(
                          onPressed:(){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> const Showbien()));
                          },
                           icon: Icon(Icons.visibility,size: 40,)
                           ),
                        Text(
                          "Voir plus",
                          style: TextStyle(fontSize: 13),
                        ),
                        Text(
                          "Vos logements",
                          style: TextStyle(fontSize: 11, color: Colors.amber),
                        )
                      ],
                    ),
                  ),
                ),
                
              ],
            )
          ],
        ),
      ),
    );
  }
}
