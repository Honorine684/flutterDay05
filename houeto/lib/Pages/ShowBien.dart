import 'package:flutter/material.dart';

class Showbien extends StatefulWidget {
  const Showbien({super.key});

  @override
  State<Showbien> createState() {
    return ShowbienState();
  }
}

class ShowbienState extends State<Showbien> {
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
            const Text(
              "HoueTo",
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.filter))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  "Mes biens",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Row(
              children: [
                Text(
                  "Ajoutez votre bien immobilier et commencez à\n bénéficier de ce dernier.",
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
            SizedBox(height: hauteurEcran * 0.03),
            Card(
              elevation: 4,
              color: Colors.white,
              child: SizedBox(
                width: largeurEcran * 0.85,
                height: hauteurEcran * 0.22,
                child: Padding(
                  padding: const EdgeInsets.all(12.0), 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            "Appartement",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "A Cotonou",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.delete, size: 30),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.edit, size: 30),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Voir plus",
                              style: TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Column(
                            children: [
                              Text(
                                "Prix",
                                style: TextStyle(fontSize: 13),
                              ),
                              Text(
                                '150fcfa',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}