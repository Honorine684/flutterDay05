import 'package:flutter/material.dart';

class PageDetails extends StatefulWidget {
  const PageDetails({super.key});

  @override
  State<PageDetails> createState() => _PageDetailsState();
}

class _PageDetailsState extends State<PageDetails> {
  final images = [
    'assets/images/fig2.jpg',
    'assets/images/google.jpg',
    'assets/images/fig2.jpg'
  ];
  final pageController = PageController();

  double get pageOffset {
    try {
      var page = pageController.page ?? pageController.initialPage.toDouble();
      return page % images.length;
    } catch (_) {
      return pageController.initialPage.toDouble();
    }
  }

  double calculateOffsetForIndex(int index) {
    return (index - pageOffset);
  }

  @override
  Widget build(BuildContext context) {
    final largeurEcran = MediaQuery.of(context).size.width;

    final hauteurEcran = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              height: hauteurEcran * 0.3,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: PageView.builder(
                  controller: pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(images[index]),
                              fit: BoxFit.fill)),
                    );
                  }),
            ),
            Container(
              height: 34,
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedBuilder(
                  animation: pageController,
                  builder: (context, _) {
                    return ListView.separated(
                      itemCount: images.length,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (_, __) {
                        return const SizedBox(width: 4);
                      },
                      itemBuilder: (context, index) {
                        final absoluteOffset =
                            calculateOffsetForIndex(index).abs();
                        final Offset = 1 - absoluteOffset.clamp(0, 1);
                        return Container(
                          height:
                              hauteurEcran * 0.012 + (10 * Offset.toDouble()),
                          width:
                              largeurEcran * 0.012 + (10 * Offset.toDouble()),
                          decoration: const BoxDecoration(
                              color: Colors.amber, shape: BoxShape.circle),
                        );
                      },
                    );
                  }),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                      width: double.infinity,
                      height: hauteurEcran * 0.06,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 2, color: Colors.deepPurpleAccent),
                          color: Color.fromRGBO(208, 205, 205, 0.486),
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Text('Regarder la vidéo',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.deepPurpleAccent,
                                fontWeight: FontWeight.bold)),
                      )),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color.fromRGBO(112, 101, 101, 0.475),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Appartement meublé - Akpakpa',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amberAccent,
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        '4.1',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.008,
                      ),
                      Text(
                        '(66 visites)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.23,
                      ),
                      Icon(
                        Icons.bed,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        '2 chambres',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.005,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.weekend,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Salon/Séjour',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.26,
                      ),
                      Icon(
                        Icons.dining,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Salle à manger',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.005,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.room,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Cotonou, Littoral',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.19,
                      ),
                      Icon(
                        Icons.home_outlined,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        '850 m²',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Accessibilité & Sécurité',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.elevator,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Ascenceur',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.31,
                      ),
                      Icon(
                        Icons.layers,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Etage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.accessible,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Accès PMR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.29,
                      ),
                      Icon(
                        Icons.dialpad,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Digicode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.videocam,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Vidéo de surveillance',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.11,
                      ),
                      Icon(
                        Icons.security,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Alarme',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Extérieurs et dépendances',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.deck,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Balcon',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.38,
                      ),
                      Icon(
                        Icons.park,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Jardin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.garage,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Garage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.38,
                      ),
                      Icon(
                        Icons.house_outlined,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Véranda',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.outdoor_grill,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Cuisine d\'été',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.28,
                      ),
                      Icon(
                        Icons.cottage,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Abri de jardin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Cuisine et électroménager',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.local_laundry_service,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Lave-vaisselle',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.25,
                      ),
                      Icon(
                        Icons.kitchen,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Réfrigérateur',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.microwave,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Four/Micro-ondes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.18,
                      ),
                      Icon(
                        Icons.heat_pump,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Gaz',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.air,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Hotte aspirante',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.22,
                      ),
                      Icon(
                        Icons.water_drop,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Evier',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Confort et équipements',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.ac_unit,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Climatisation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.26,
                      ),
                      Icon(
                        Icons.heat_pump,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Isolation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.device_hub,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Domotique',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.3,
                      ),
                      Icon(
                        Icons.fireplace,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Cheminée',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'Technologie et connectivité',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.wifi,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Connexion Wifi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.22,
                      ),
                      Icon(
                        Icons.settings_ethernet,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Prises RJ45',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: hauteurEcran * 0.01,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.settings_input_antenna,
                        color: Color.fromRGBO(67, 58, 58, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        'Antenne',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.34,
                      ),
                      Icon(
                        Icons.speaker,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.02,
                      ),
                      Text(
                        'Home Cinéma',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: hauteurEcran*0.01,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Text(
                        'A propos de cet appartement',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(height: hauteurEcran*0.01,),
                  Text(
                      'Cette cabane est équipée d\'un système Smart Home et d\'un magnifique style viking. Vous pouvez voir le lever du soleil le matin avec une vue sur la ville depuis une fenêtre entièrement vitrée. \n\nCette unité est entourée par le quartier d\'affaires de West Surabaya qui vous offre la vie citadine ainsi qu\'un large éventail d\'activités culinaires. \n \nCet appartement est équipé d\'un lave-linge, d\'une cuisinière électrique, d\'un four à micro-ondes, d\'un réfrigérateur et de couverts.'),
                
              Container(
                width: double.infinity,
                height: hauteurEcran * 0.06,
                decoration: BoxDecoration(
                    color: Colors.blue, borderRadius: BorderRadius.circular(2)),
                child: Center(
                  child: Text('Modifier',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                )),
                
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
