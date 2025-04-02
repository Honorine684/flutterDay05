import 'package:flutter/material.dart';
import 'dart:math' as math;

class DemandesLocationFiltre extends StatefulWidget {
  const DemandesLocationFiltre({super.key});

  @override
  DemandesLocationFiltreState createState() => DemandesLocationFiltreState();
}

class DemandesLocationFiltreState extends State<DemandesLocationFiltre>
    with SingleTickerProviderStateMixin {
  int _currentCardIndex = 0;
  final PageController _pageController = PageController();
  
  // Ajout du TabController
  late TabController _tabController;
  

  final List<Map<String, dynamic>> _demandesNonEligibles = [
    {'id': '1', 'nom': 'Jean Dupont', 'statut': 'Étudiant', 'photo': 'https://randomuser.me/api/portraits/men/1.jpg', 'revenu': '600€/mois', 'motif': 'Revenus insuffisants'},
    {'id': '2', 'nom': 'Marie Martin', 'statut': 'Auto-entrepreneur', 'photo': 'https://randomuser.me/api/portraits/women/1.jpg', 'revenu': '1200€/mois', 'motif': 'Activité récente'},
    {'id': '3', 'nom': 'Pierre Durand', 'statut': 'CDD', 'photo': 'https://randomuser.me/api/portraits/men/2.jpg', 'revenu': '1800€/mois', 'motif': 'Contrat précaire'},
    {'id': '4', 'nom': 'Amélie Blanc', 'statut': 'Intérimaire', 'photo': 'https://randomuser.me/api/portraits/women/4.jpg', 'revenu': '1500€/mois', 'motif': 'Emploi instable'},
    {'id': '5', 'nom': 'Lucas Leroy', 'statut': 'Stage', 'photo': 'https://randomuser.me/api/portraits/men/5.jpg', 'revenu': '700€/mois', 'motif': 'Revenus insuffisants'},
  ];

  final List<Map<String, dynamic>> _demandesEligibles = [
    {'id': '6', 'nom': 'Sophie Lambert', 'statut': 'Fonctionnaire', 'photo': 'https://randomuser.me/api/portraits/women/2.jpg', 'status': 'en_attente', 'revenu': '2200€/mois'},
    {'id': '7', 'nom': 'Lucie Petit', 'statut': 'CDI', 'photo': 'https://randomuser.me/api/portraits/women/3.jpg', 'status': 'confirme', 'revenu': '2500€/mois'},
  ];

  // Filtres
  String _statutFilter = 'Tous';
  String _revenuFilter = 'Tous';
  final List<String> _statutOptions = ['Tous', 'Étudiant', 'CDI', 'CDD', 'Auto-entrepreneur', 'Intérimaire'];
  final List<String> _revenuOptions = ['Tous', 'Moins de 1000€', '1000€-2000€', 'Plus de 2000€'];

  @override
  void initState() {
    super.initState();
    
    // Initialisation du TabController avec 3 onglets
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demandes de Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicateur de progression
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Profil ${_currentCardIndex + 1}/${_demandesNonEligibles.length}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Section des cartes en 3D
          Expanded(
            flex: 2,
            child: _build3DCardStack(),
          ),
          // Section tabbar (éligibles)
          Expanded(
            flex: 1,
            child: _buildTabBarSection(),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Filtres de recherche",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 10),
                  Text(
                    "Statut professionnel",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statutOptions.map((statut) {
                      return ChoiceChip(
                        label: Text(statut),
                        selected: _statutFilter == statut,
                        onSelected: (selected) {
                          setState(() {
                            _statutFilter = selected ? statut : 'Tous';
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Revenus mensuels",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _revenuOptions.map((revenu) {
                      return ChoiceChip(
                        label: Text(revenu),
                        selected: _revenuFilter == revenu,
                        onSelected: (selected) {
                          setState(() {
                            _revenuFilter = selected ? revenu : 'Tous';
                          });
                        },
                      );
                    }).toList(),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            iconColor: Colors.grey[300],
                            overlayColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _statutFilter = 'Tous';
                              _revenuFilter = 'Tous';
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text("Réinitialiser"),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            iconColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Appliquer les filtres
                            Navigator.pop(context);
                            // Logique de filtrage à implémenter
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text("Appliquer"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _build3DCardStack() {
    return Stack(
      children: [
        // Pile de cartes avec effet 3D
        Positioned.fill(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < 0 && _currentCardIndex < _demandesNonEligibles.length - 1) {
                  // Swipe gauche -> carte suivante
                  setState(() {
                    _currentCardIndex++;
                  });
                } else if (details.primaryVelocity! > 0 && _currentCardIndex > 0) {
                  // Swipe droite -> carte précédente
                  setState(() {
                    _currentCardIndex--;
                  });
                }
              }
            },
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Construction des cartes empilées avec effet 3D
                  // Nous affichons jusqu'à 3 cartes en arrière-plan
                  for (int i = math.min(_currentCardIndex + 3, _demandesNonEligibles.length - 1); 
                       i >= _currentCardIndex; 
                       i--)
                    Positioned(
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Effet de perspective
                          ..translate(0.0, (i - _currentCardIndex) * 15.0, -(i - _currentCardIndex) * 10.0)
                          ..scale(1.0 - (i - _currentCardIndex) * 0.05), // Réduction de taille pour les cartes du fond
                        alignment: Alignment.topCenter,
                        child: Opacity(
                          opacity: 1.0 - (i - _currentCardIndex) * 0.2, // Opacité réduite pour les cartes du fond
                          child: _buildLocationCard(_demandesNonEligibles[i], i == _currentCardIndex),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Boutons de navigation sur les côtés
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: _currentCardIndex > 0
              ? Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentCardIndex--;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ),
        
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: _currentCardIndex < _demandesNonEligibles.length - 1
              ? Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentCardIndex++;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ),
      ],
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> demande, bool isCurrent) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 280,
      child: Card(
        elevation: isCurrent ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la carte avec le profil
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(demande['photo']),
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          demande['nom'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          demande['statut'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          demande['revenu'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.blue),
                    onPressed: () {
                      // Afficher plus d'informations
                      _showProfileDetails(demande);
                    },
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Non éligible",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Motif: ${demande['motif']}",
                      style: TextStyle(color: Colors.red[800]),
                    ),
                  ],
                ),
              ),
              
              // Actions en bas de la carte
              if (isCurrent) ...[
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      Icons.schedule,
                      "Mettre de côté",
                      Colors.orange,
                      () => _mettreDeCote(demande),
                    ),
                    _buildActionButton(
                      Icons.delete_outline,
                      "Supprimer",
                      Colors.red,
                      () {
                        _rejeterDemande(demande);
                        if (_demandesNonEligibles.length > 1) {
                          setState(() {
                            _demandesNonEligibles.removeAt(_currentCardIndex);
                            if (_currentCardIndex >= _demandesNonEligibles.length) {
                              _currentCardIndex = _demandesNonEligibles.length - 1;
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDetails(Map<String, dynamic> demande) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Détails du profil"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(demande['photo']),
              ),
              title: Text(demande['nom']),
              subtitle: Text(demande['statut']),
            ),
            SizedBox(height: 16),
            Text("Revenus: ${demande['revenu']}"),
            SizedBox(height: 8),
            Text("Motif de refus: ${demande['motif']}"),
            // Vous pouvez ajouter d'autres détails ici
          ],
        ),
        actions: [
          TextButton(
            child: Text("Fermer"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarSection() {
    return Column(
      children: [
        // Utilisation du TabController
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'En attente'),
            Tab(text: 'Confirmées'),
            Tab(text: 'Annulées'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDemandeList(_demandesEligibles.where((d) => d['status'] == 'en_attente').toList()),
              _buildDemandeList(_demandesEligibles.where((d) => d['status'] == 'confirme').toList()),
              _buildDemandeList([]), // Liste vide pour les demandes annulées
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemandeList(List<Map<String, dynamic>> demandes) {
    return ListView.builder(
      itemCount: demandes.length,
      itemBuilder: (context, index) {
        final demande = demandes[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(demande['photo'])),
            title: Text(demande['nom']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(demande['statut']),
                Text(demande['revenu']),
              ],
            ),
            isThreeLine: true,
            trailing: _tabController.index == 0
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _confirmerDemande(demande),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _annulerDemande(demande),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  void _rejeterDemande(Map<String, dynamic> demande) {
    print("Demande rejetée: ${demande['nom']}");
    // Implémentez votre logique ici
  }

  void _mettreDeCote(Map<String, dynamic> demande) {
    print("Demande mise de côté: ${demande['nom']}");
    // Implémentez votre logique ici
  }

  void _confirmerDemande(Map<String, dynamic> demande) {
    print("Demande confirmée: ${demande['nom']}");
    // Implémentez votre logique ici
  }

  void _annulerDemande(Map<String, dynamic> demande) {
    print("Demande annulée: ${demande['nom']}");
    // Implémentez votre logique ici
  }
}