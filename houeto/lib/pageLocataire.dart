import 'package:flutter/material.dart';

class RecherchePage extends StatefulWidget {
  @override
  _RecherchePageState createState() => _RecherchePageState();
}

class _RecherchePageState extends State<RecherchePage> {

  final List<Map<String, String>> locataire = [
    {
      'nom': 'ELISHA Richard',
      'location': 'A Cotonou',
      'heure': '14 min',
      'image': 'assets/images/fig2.jpg'
    },
    {
      'nom': 'Bro Vivien Jeek',
      'location': 'A Fidjrossè',
      'heure': '14 min',
      'image': 'assets/images/fig2.jpg'
    },
    {
      'nom': 'Elon Musk Rich',
      'location': 'A Toffo',
      'heure': '14 min',
      'image': 'assets/images/fig2.jpg'
    },
  ];


  List<Map<String, String>> filtresLocataires = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  
    filtresLocataires = locataire;
    _searchController.addListener(_filterTenants);
  }

  void _filterTenants() {
    String query = _searchController.text.toLowerCase();
    setState(() {
   filtresLocataires = locataire.where((tenant) {
        return tenant['nom']!.toLowerCase().contains(query) ||
               tenant['location']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Houeto',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recherche locataire',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Rechercher un locataire parfait pour votre bien !',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
       
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un locataire...',
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

            Expanded(
              child: filtresLocataires.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun locataire trouvé',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtresLocataires.length,
                      itemBuilder: (context, index) {
                        return _locataireCarte(filtresLocataires[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locataireCarte(Map<String, String> tenant) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(tenant['image']!),
              radius: 30,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenant['name']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Recherche, Apartment ${tenant['location']!}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${tenant['time']!}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Voir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}