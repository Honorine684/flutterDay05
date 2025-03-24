import 'package:flutter/material.dart';
import 'package:houeto/Pages/pageInfos.dart';

class PageProfile extends StatefulWidget {
  const PageProfile({super.key});

  @override
  State<PageProfile> createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;

    final hauteurEcran = MediaQuery.of(context).size.height;
    return Scaffold(
      
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: hauteurEcran*0.05,),
            Stack(children: [
Row(
              children: [
                SizedBox(width: largeurEcran*0.3,),
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 60,
                )
              ],
            ),
            Positioned(bottom: 2, right: 80, 
              child: IconButton(onPressed: (){}, icon: Icon(Icons.camera_alt, size: 40,)))
            ],),
           Text('ELISHA Richard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
           Text('elishamede@gmail.com', style: TextStyle(fontSize: 16, color: Colors.grey.shade600),), 
           SizedBox(height: hauteurEcran*0.05,),
           Divider(color: Colors.grey.shade600,),
           SizedBox(height: hauteurEcran*0.04,),

           GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>PageInfos()));
            },
             child: Row(children: [
              Icon(Icons.person, size: 35,), 
              SizedBox(width: largeurEcran*0.03,),
              Text('Infos personnelles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(width: largeurEcran*0.235),
             Icon(Icons.chevron_right, size: 35,),
             
             ],),
           ),
           SizedBox(height: hauteurEcran*0.04,),

      Row(children: [
            Icon(Icons.settings, size: 35,), 
            SizedBox(width: largeurEcran*0.03,),
            Text('Paramètres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            SizedBox(width: largeurEcran*0.385),
Icon(Icons.chevron_right, size: 35,),

           ],),
           SizedBox(height: hauteurEcran*0.04,),

      Row(children: [
            Icon(Icons.monetization_on, size: 35,), 
            SizedBox(width: largeurEcran*0.03,),
            Text('Détails factures', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            SizedBox(width: largeurEcran*0.28),
Icon(Icons.chevron_right, size: 35,),

           ],),
           SizedBox(height: hauteurEcran*0.04,),

      Row(children: [
            Icon(Icons.person, size: 35,), 
            SizedBox(width: largeurEcran*0.03,),
            Text('FAQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            SizedBox(width: largeurEcran*0.54),
Icon(Icons.chevron_right, size: 35,),

           ],),
            SizedBox(height: hauteurEcran*0.03,),
           Divider(color: Colors.grey.shade600,),
           Row(children: [
            Switch(
  
    value: light,
    activeColor: Colors.black,
    onChanged: (bool value) {

      setState(() {
        light = value;
      });
},
),

            SizedBox(width: largeurEcran*0.005,),
            Text('Mode Sombre/Clair', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            SizedBox(width: largeurEcran*0.13),
Icon(Icons.chevron_right, size: 35,),

           ],),
           SizedBox(height: hauteurEcran*0.02,),
            Container(width: double.infinity,
            height: hauteurEcran*0.06,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2)
            ),
              child: Center(child: Text('Deconnexion', style: TextStyle(fontSize: 16 ,color: Colors.white, fontWeight: FontWeight.bold)),) ), 
          ],
          
        ),
      ),
    );
  }
}
