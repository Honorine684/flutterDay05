import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeto/Authentication/Login.dart';
import 'package:houeto/Pages/pageInfos.dart';
import 'package:houeto/Services/Firebase/auth.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({super.key});

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  bool light = true;
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: hauteurEcran * 0.05,
            ),
            Stack(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: largeurEcran * 0.3,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 45,
                    )
                  ],
                ),
                Positioned(
                    bottom: 1,
                    right: largeurEcran*0.3,
                    child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.edit,
                          size: 35,
                        )))
              ],
            ),
            Text(
              '$nom $prenom',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(
              height: hauteurEcran * 0.05,
            ),
            Divider(
              color: Colors.grey.shade700.withOpacity(0.2),
            ),
            SizedBox(
              height: hauteurEcran * 0.04,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PageInfos()));
              },
              child: Row(
                children: [
                  Card(
                    elevation: 4,
                    child: Icon(
                    Icons.person,
                    size: 32,
                  ),
                  ),
                  SizedBox(
                    width: largeurEcran * 0.03,
                  ),
                  Text(
                    'Infos personnelles',
                    style: TextStyle(fontSize: 16,)
                  ),
                  SizedBox(width: largeurEcran * 0.235),
                  Icon(
                    Icons.chevron_right,
                    size: 35,
                    
                  ),
                ],
              ),
            ),
            SizedBox(
              height: hauteurEcran * 0.04,
            ),
            Row(
              children: [
                Card(
                  elevation: 4,
                  child:Icon(
                  Icons.settings,
                  size: 33,
                ),
                ),
                SizedBox(
                  width: largeurEcran * 0.03,
                ),
                Text(
                  'Paramètres',
                  style: TextStyle(fontSize: 16,),
                ),
                SizedBox(width: largeurEcran * 0.385),
                Icon(
                  Icons.chevron_right,
                  size: 35,
                ),
              ],
            ),
            SizedBox(
              height: hauteurEcran * 0.04,
            ),
            Row(
              children: [
                Card(
                  elevation: 4,
                  child: Icon(
                  Icons.wallet_giftcard,
                  size: 33,
                ),
                ),
                SizedBox(
                  width: largeurEcran * 0.03,
                ),
                Text(
                  'Détails factures',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: largeurEcran * 0.28),
                Icon(
                  Icons.chevron_right,
                  size: 35,
                ),
              ],
            ),
            SizedBox(
              height: hauteurEcran * 0.04,
            ),
            Row(
              children: [
                Card(
                  elevation: 4,
                  child:                 Icon(
                  Icons.info,
                  size: 33,
                ),
                ),
                SizedBox(
                  width: largeurEcran * 0.03,
                ),
                Text(
                  'FAQ',
                  style: TextStyle(fontSize: 16,),
                ),
                SizedBox(width: largeurEcran * 0.54),
                Icon(
                  Icons.chevron_right,
                  size: 35,
                ),
              ],
            ),
            SizedBox(
              height: hauteurEcran * 0.03,
            ),
            Divider(
              color: Colors.grey.shade600.withOpacity(0.2),
            ),
            Row(
              children: [
                Switch(
                  value: light,
                  activeColor: Colors.black,
                  onChanged: (bool value) {
                    setState(() {
                      light = value;
                    });
                  },
                ),
                SizedBox(
                  width: largeurEcran * 0.005,
                ),
                Text(
                  'Mode Sombre/Clair',
                  style: TextStyle(fontSize: 16, ),
                ),
                SizedBox(width: largeurEcran * 0.13),
                Icon(
                  Icons.chevron_right,
                  size: 35,
                ),
              ],
            ),
            SizedBox(
              height: hauteurEcran * 0.02,
            ),
            GestureDetector(
              onTap: (){
                Auth().logout();
                Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const ConnexionPage()),
                (route) => false,
              );
              },
              child: Container(
                width: double.infinity,
                height: hauteurEcran * 0.06,
                decoration: BoxDecoration(
                    color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text('Deconnexion',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                )),
            )
          ],
        ),
      ),
    );
  }
}
