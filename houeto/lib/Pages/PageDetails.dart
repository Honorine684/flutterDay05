import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:houeto/JsonModels/Logement.dart';
import 'package:houeto/Pages/EditLogement.dart';

class PageDetailsProprietaire extends StatefulWidget {
  final Logement logement;
  const PageDetailsProprietaire({super.key, required this.logement});

  @override
  State<PageDetailsProprietaire> createState() => _PageDetailsProprietaireState();
}

class _PageDetailsProprietaireState extends State<PageDetailsProprietaire> {
  late PageController _pageController;
  late List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadImages();
  }

  void _loadImages() {
    final logement = widget.logement;
    _images = [];
    
    if (logement.photo1.isNotEmpty) _images.add(logement.photo1);
    if (logement.photo2.isNotEmpty) _images.add(logement.photo2);
    if (logement.photo3.isNotEmpty) _images.add(logement.photo3);
    
    if (_images.isEmpty) {
      _images.add('assets/images/placeholder.jpg');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logement = widget.logement;

    return Scaffold(
      appBar: AppBar(
        title: Text(logement.titre),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> Editlogement(logementId:logement.id)))
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_images.isNotEmpty) _buildImageCarousel(size),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        logement.titre,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (logement.loyerMois > 0)
                            Text(
                              '${logement.loyerMois} FCFA/mois',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          if (logement.loyerJour > 0)
                            Text(
                              '${logement.loyerJour} FCFA/jour',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          logement.adresse,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  
                  Divider(height: 24),
                  
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildFeatureChip(Icons.home, 'Type', logement.typeProperty),
                      _buildFeatureChip(Icons.aspect_ratio, 'Surface', '${logement.surface} m²'),
                      _buildFeatureChip(Icons.bed, 'Chambres', '${logement.chambres}'),
                      _buildFeatureChip(Icons.bathtub, 'Salles de bain', '${logement.salleDeBains}'),
                      if (logement.etages > 0) _buildFeatureChip(Icons.layers, 'Étages', '${logement.etages}'),
                      if (logement.parking > 0) _buildFeatureChip(Icons.local_parking, 'Parkings', '${logement.parking}'),
                    ],
                  ),
                  
                  Divider(height: 24),
                  
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    logement.description.isNotEmpty 
                        ? logement.description 
                        : 'Aucune description fournie',
                  ),
                  
                  Divider(height: 24),
                  
                  _buildDetailSection(
                    title: 'Détails du logement',
                    items: [
                      _DetailItem('Statut', logement.statut),
                      _DetailItem('Mode', logement.mode ?? "NOn confier"),
                      _DetailItem('État', logement.etat),
                      _DetailItem('Type de bail', logement.typeDeBail),
                      _DetailItem('Avance requise', '${logement.avance} FCFA'),
                      _DetailItem('Frais de visite', '${logement.fraisDeVisite} FCFA'),
                    ],
                  ),
                  
_buildDetailSection(
  title: 'Équipements',
  items: [
    _DetailItem('Meublé', logement.estMeuble != null ? (logement.estMeuble! ? 'Oui' : 'Non') : 'Non spécifié'),
    _DetailItem('Climatisé', logement.estClimatise != null ? (logement.estClimatise! ? 'Oui' : 'Non') : 'Non spécifié'),
    _DetailItem('Sanitaire', logement.estSanitaire != null ? (logement.estSanitaire! ? 'Oui' : 'Non') : 'Non spécifié'),
  ],
),
                  
                  _buildDetailSection(
                    title: 'Conditions d\'admission',
                    items: [
                      _DetailItem('Conditions', logement.conditionAdmission),
                    ],
                  ),
                  
                  if (logement.gestionnaireNom.isNotEmpty)
                    _buildDetailSection(
                      title: 'Gestion',
                      items: [
                        _DetailItem('Gestionnaire', logement.gestionnaireNom),
                      ],
                    ),
                  
                  // Créneaux de visite
                  if (logement.creneaux.isNotEmpty)
                    _buildCreneauxSection(logement.creneaux),
                  
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildImageCarousel(Size size) {
  return SizedBox(
    height: size.height * 0.3,
    child: Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return _images[index].startsWith('http')
                ? Image.network(_images[index], fit: BoxFit.cover)
                : _images[index].startsWith('assets/')
                    ? Image.asset(_images[index], fit: BoxFit.cover)
                    : Image.memory(
                        base64Decode(_images[index]),
                        fit: BoxFit.cover,
                      );
          },
        ),
        if (_images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_images.length, (index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    final currentPage = _pageController.hasClients 
                        ? _pageController.page ?? 0 
                        : 0;
                    final isActive = (currentPage - index).abs() < 0.5;
                    return Container(
                      width: isActive ? 12 : 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildFeatureChip(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<_DetailItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Text(item.value),
              ),
            ],
          ),
        )),
        SizedBox(height: 16),
      ],
    );
  }

Widget _buildCreneauxSection(List<Map<String, dynamic>>? creneaux) {
  if (creneaux == null || creneaux.isEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Créneaux de visite',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Aucun créneau disponible pour le moment',
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Créneaux de visite',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: creneaux.map((creneau) {
          return Chip(
            label: Text(
              '${creneau['jour'] ?? 'Jour non spécifié'} '
              '${_formatCreneau(creneau)}',
            ),
            backgroundColor: Colors.blue[50],
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          );
        }).toList(),
      ),
      SizedBox(height: 16),
    ],
  );
}

String _formatCreneau(Map<String, dynamic> creneau) {
  // Formatage des heures avec valeurs par défaut
  final startHour = creneau['startHour']?.toString() ?? '0';
  final startMinute = creneau['startMinute']?.toString().padLeft(2, '0') ?? '00';
  final endHour = creneau['endHour']?.toString() ?? '0';
  final endMinute = creneau['endMinute']?.toString().padLeft(2, '0') ?? '00';

  // Construction de la chaîne formatée
  return '${startHour.padLeft(2, '0')}:$startMinute - ${endHour.padLeft(2, '0')}:$endMinute';
}

}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
}