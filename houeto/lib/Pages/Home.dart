import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
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
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.filter))],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Bienvenue,Richard",
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
                        Icon(
                          Icons.visibility,
                          size: 40,
                        ),
                        Text(
                          "Nombres de visites",
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
                
              ],
            )
          ],
        ),
      ),
    );
  }
}
