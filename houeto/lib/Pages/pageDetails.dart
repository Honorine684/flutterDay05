import 'package:flutter/material.dart';

class PageDetails extends StatefulWidget {
  const PageDetails({super.key});

  @override
  State<PageDetails> createState() => _PageDetailsState();
}

class _PageDetailsState extends State<PageDetails> {
  @override
  Widget build(BuildContext context) {
     //final largeurEcran = MediaQuery.of(context).size.width;

    final hauteurEcran = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              SingleChildScrollView(child: Image.asset('assets/images/fig2.jpg',
                  height: hauteurEcran*0.4,
                 
                  
                 ),)
              
            ],
          )
        ],
      )
    );
  }
}