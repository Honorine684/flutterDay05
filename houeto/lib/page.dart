import 'package:flutter/material.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';

class PageAccueil extends StatelessWidget {
  final List<Map<String, dynamic>> mesBiens = [
    {
      'image': 'assets/images/fig2.jpg',
      'nom': 'Studio H21',
      'numero': '4,8',
      'nombre': '(65)',
      'prix': '\$526/mois',
      'chambres': '2 chambres',
      'surface': '900 m²',
      'localisation': 'Cotonou, Akpakpa',
      'meuble': 'Oui',
      'estFavoris': false
    },
    {
      'image': 'assets/images/fig2.jpg',
      'nom': 'Appartement H34',
      'prix': '\$800/mois',
      'numero': '4,8',
      'meuble': 'Non',
      'localisation': 'Porto-Novo, Dowa',
      'nombre': '(65)',
      'chambres': '2 chambres',
      'surface': '900 m²',
      'estFavoris': false
    },
    {
      'image': 'assets/images/fig2.jpg',
      'nom': 'Studio H21',
      'numero': '4,8',
      'nombre': '(65)',
      'prix': '\$526/mois',
      'chambres': '2 chambres',
      'surface': '900 m²',
      'meuble': 'Oui',
      'localisation': 'Cotonou, Akpakpa',
      'estFavoris': false
    },
  ];

  final List<Map<String, dynamic>> biensGestionnaire = [
    {
      'image': 'assets/images/fig2.jpg',
      'nom': 'Maison G12',
      'numero': '4,5',
      'nombre': '(40)',
      'prix': '\$1200/mois',
      'chambres': '3 chambres',
      'surface': '1200 m²',
      'localisation': 'Cotonou, Fidjrossè',
      'meuble': 'Non',
      'estFavoris': false
    },
    {
      'image': 'assets/images/fig2.jpg',
      'nom': 'Appartement G45',
      'prix': '\$950/mois',
      'numero': '4,7',
      'meuble': 'Oui',
      'localisation': 'Porto-Novo, Centre',
      'nombre': '(55)',
      'chambres': '2 chambres',
      'surface': '850 m²',
      'estFavoris': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Abomey-Calavi',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Benin',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche par adresse, ville, ...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              
              SizedBox(height: 16),

              Text(
                'Bienvenue à Houeto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 16),

              SafeArea(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: <Widget>[
                      ButtonsTabBar(
                        backgroundColor: Colors.blue,
                        unselectedBackgroundColor: Colors.white,
                        unselectedLabelStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          Tab(text: "Gérer moi-meme"),
                          Tab(text: "Confier au gestionnaire"),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 400, 
                        child: TabBarView(
                          children: <Widget>[
                            _propriete(context, "Mes biens", mesBiens),
                            _propriete(context, "Biens du gestionnaire", biensGestionnaire),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _propriete(BuildContext context, String title, List<Map<String, dynamic>> biens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: biens.map((bien) => 
                _cartePropriete(context, bien)
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cartePropriete(BuildContext context, Map<String, dynamic> bien) {
    final largeurEcran = MediaQuery.of(context).size.width;
    final hauteurEcran = MediaQuery.of(context).size.height;

    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        height: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.amber,
                image: DecorationImage(
                  image: AssetImage(bien['image']),
                  fit: BoxFit.cover, 
                ),
              ),
            ),            
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        bien['numero'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),  
                      Text(
                        bien['nombre'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                        ),
                      ),
                    ],
                  ),  
                  Text(
                    bien['nom'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    bien['localisation'],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.bed,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        bien['chambres'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                          fontSize: 10
                        ),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.019,
                      ),
                      Icon(
                        Icons.home_max_outlined,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        bien['surface'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                          fontSize: 10
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.chair,
                        color: Color.fromRGBO(28, 21, 21, 0.475),
                      ),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text('Meuble :', style: TextStyle(fontSize: 10, color: Colors.grey),),
                      SizedBox(
                        width: largeurEcran * 0.01,
                      ),
                      Text(
                        bien['meuble'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(67, 58, 58, 0.475),
                          fontSize: 10
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bien['prix'],
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}