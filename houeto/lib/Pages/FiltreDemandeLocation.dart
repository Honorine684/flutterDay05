import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;


class DemandesLocationFiltre extends StatefulWidget {
  const DemandesLocationFiltre({super.key});

  @override
  DemandesLocationFiltreState createState() => DemandesLocationFiltreState();
}

class DemandesLocationFiltreState extends State<DemandesLocationFiltre> {
  int _currentCardIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _demandesNonEligibles = [
    {'id': '1', 'nom': 'Jean Dupont', 'statut': 'Étudiant', 'photo': 'https://randomuser.me/api/portraits/men/1.jpg', 'revenu': '600€/mois', 'motif': 'Revenus insuffisants'},
    {'id': '2', 'nom': 'Marie Martin', 'statut': 'Auto-entrepreneur', 'photo': 'https://randomuser.me/api/portraits/women/1.jpg', 'revenu': '1200€/mois', 'motif': 'Activité récente'},
    {'id': '3', 'nom': 'Pierre Durand', 'statut': 'CDD', 'photo': 'https://randomuser.me/api/portraits/men/2.jpg', 'revenu': '1800€/mois', 'motif': 'Contrat précaire'},
    {'id': '4', 'nom': 'Amélie Blanc', 'statut': 'Intérimaire', 'photo': 'https://randomuser.me/api/portraits/women/4.jpg', 'revenu': '1500€/mois', 'motif': 'Emploi instable'},
    {'id': '5', 'nom': 'Lucas Leroy', 'statut': 'Stage', 'photo': 'https://randomuser.me/api/portraits/men/5.jpg', 'revenu': '700€/mois', 'motif': 'Revenus insuffisants'},
  ];


  // Filtres
  String _statutFilter = 'Tous';
  String _revenuFilter = 'Tous';
  bool iaFilterEnabled = false;
  final List<String> _statutOptions = ['Tous', 'Étudiant', 'CDI', 'CDD', 'Auto-entrepreneur', 'Intérimaire'];
  final List<String> _revenuOptions = ['Tous', 'Moins de 1000€', '1000€-2000€', 'Plus de 2000€'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtre demandes'),
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
          Expanded(
            child: _build3DCardStack(),
          ),
          Padding(
  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("IA pour filtrage: "),
      Switch(
        value: iaFilterEnabled,
        onChanged: (value) {
          setState(() {
            iaFilterEnabled = value;
          });
        },
        activeColor: Theme.of(context).primaryColor,
      ),
    ],
  ),
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
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('demandes_logement')
        .where('statut', isEqualTo: 'En attente')
        .orderBy('timestamp', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text("Erreur: ${snapshot.error}"));
      }

      final demandes = snapshot.data?.docs ?? [];
      if (demandes.isEmpty) {
        return const Center(child: Text("Aucune demande en attente"));
      }

      // S'assurer que _currentCardIndex est dans les limites
      if (_currentCardIndex >= demandes.length) {
        _currentCardIndex = demandes.length - 1;
      }

      return Stack(
        children: [
          // La pile de cartes 3D
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < 0 && _currentCardIndex < demandes.length - 1) {
                    setState(() => _currentCardIndex++);
                  } else if (details.primaryVelocity! > 0 && _currentCardIndex > 0) {
                    setState(() => _currentCardIndex--);
                  }
                }
              },
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Générer les cartes en commençant par la plus éloignée
                    for (int i = math.min(_currentCardIndex + 2, demandes.length - 1);
                         i >= _currentCardIndex;
                         i--)
                      Positioned(
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // Perspective
                            ..translate(
                              0.0,
                              (i - _currentCardIndex) * 15.0, // Translation verticale pour l'empilement
                              -(i - _currentCardIndex) * 10.0, // Translation en profondeur
                            )
                            ..scale(1.0 - (i - _currentCardIndex) * 0.05), // Réduction de taille avec la profondeur
                          alignment: Alignment.topCenter,
                          child: Opacity(
                            opacity: 1.0 - (i - _currentCardIndex) * 0.3, // Réduction d'opacité avec la profondeur
                            child: _buildLocationCard(
                              demandes[i],
                              i == _currentCardIndex,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Boutons de navigation - bien visibles sur les côtés
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: _currentCardIndex > 0
                ? Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 30, color: Colors.white),
                      onPressed: () => setState(() => _currentCardIndex--),
                    ),
                  )
                : const SizedBox(),
          ),
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: _currentCardIndex < demandes.length - 1
                ? Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, size: 30, color: Colors.white),
                      onPressed: () => setState(() => _currentCardIndex++),
                    ),
                  )
                : const SizedBox(),
          ),
          
          // Indicateur de position (dots)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < demandes.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentCardIndex ? Colors.blue : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
Widget _buildLocationCard(DocumentSnapshot demandeDoc, bool isCurrent) {
  if (!demandeDoc.exists) {
    return _buildErrorCard("Demande introuvable");
  }

  final demande = demandeDoc.data() as Map<String, dynamic>? ?? {};

  return FutureBuilder<Map<String, dynamic>>(
    future: _getDemandeInfoWithTitle(demande),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingCard();
      }

      if (snapshot.hasError || !snapshot.hasData) {
        return _buildErrorCard("Erreur de chargement");
      }

      final demandeComplete = snapshot.data!;
      
      // Données par défaut sécurisées
      final prenom = demande['prenom']?.toString() ?? 'Prénom inconnu';
      final nom = demande['nom']?.toString() ?? '';
      final profession = demande['profession']?.toString() ?? 'Non spécifié';
      final telephone = demande['telephone']?.toString() ?? 'Non spécifié';
      final logementTitre = demandeComplete['logementTitre']?.toString() ?? 'Titre inconnu';

      return SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 340,
        child: Card(
          elevation: isCurrent ? 8 : 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue.shade200,
                      child: Text(
                        "${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$prenom $nom",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Profession: $profession",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tél: $telephone",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Section Logement
                const SizedBox(height: 16),
                Text(
                  "Logement demandé:",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  logementTitre,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                
                const SizedBox(height: 16),
                _buildStatusSection(demande['statut']?.toString() ?? 'En attente'),
                
                if (isCurrent && demande['statut']?.toString() == 'En attente') ...[
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        Icons.check,
                        "Accepter",
                        Colors.green,
                        () => _traiterDemande(demandeDoc, true),
                      ),
                      _buildActionButton(
                        Icons.close,
                        "Refuser",
                        Colors.red,
                        () => _traiterDemande(demandeDoc, false),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
Future<Map<String, dynamic>> _getDemandeInfoWithTitle(Map<String, dynamic> demande) async {
  final result = Map<String, dynamic>.from(demande);
  
  try {
    if (demande['logement_id'] != null) {
      DocumentSnapshot logementDoc = await FirebaseFirestore.instance
          .collection('logement')
          .doc(demande['logement_id'].toString())
          .get();
          
      if (logementDoc.exists) {
        final logementData = logementDoc.data() as Map<String, dynamic>? ?? {};
        result['logementTitre'] = logementData['titre']?.toString() ?? 'Sans titre';
      }
    }
    
    return result;
  } catch (e) {
    print('Erreur lors de la récupération des données: $e');
    return result;
  }
}
Widget _buildLoadingCard() {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.85,
    height: 340,
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

Widget _buildErrorCard(String message) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.85,
    height: 340,
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildStatusSection(String statut) {
  Color statusColor;
  IconData statusIcon;
  
  switch (statut) {
    case 'Acceptée':
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      break;
    case 'Refusée':
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      break;
    case 'En attente':
    default:
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
      break;
  }
  
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    decoration: BoxDecoration(
      color: statusColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statusIcon, color: statusColor, size: 18),
        const SizedBox(width: 8),
        Text(
          "Statut: $statut",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
  return ElevatedButton.icon(
    icon: Icon(icon, color: Colors.white),
    label: Text(label, style: const TextStyle(color: Colors.white)),
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onPressed: onPressed,
  );
}



void _traiterDemande(DocumentSnapshot demandeDoc, bool accepte) async {
  try {
    await FirebaseFirestore.instance
        .collection('demandes_logement')
        .doc(demandeDoc.id)
        .update({
          'statut': accepte ? 'Confirmer' : 'Refuser',
        });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Demande ${accepte ? 'acceptée' : 'refusée'}")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur: ${e.toString()}")),
    );
  }
}


}