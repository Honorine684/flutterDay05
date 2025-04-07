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
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }

      final demandes = snapshot.data!.docs;
      if (demandes.isEmpty) {
        return Center(child: Text("Aucune demande en attente"));
      }

      return Stack(
        children: [
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
                    for (int i = math.min(_currentCardIndex + 2, demandes.length - 1);
                         i >= _currentCardIndex;
                         i--)
                      Positioned(
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..translate(0.0, (i - _currentCardIndex) * 15.0, 
                                       -(i - _currentCardIndex) * 10.0)
                            ..scale(1.0 - (i - _currentCardIndex) * 0.05),
                          alignment: Alignment.topCenter,
                          child: Opacity(
                            opacity: 1.0 - (i - _currentCardIndex) * 0.3,
                            child: _buildLocationCard(
                              demandes[i], 
                              i == _currentCardIndex
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Boutons de navigation
          if (demandes.length > 1) ...[
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: _currentCardIndex > 0
                  ? IconButton(
                      icon: Icon(Icons.chevron_left, size: 40),
                      onPressed: () => setState(() => _currentCardIndex--),
                    )
                  : SizedBox(),
            ),
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: _currentCardIndex < demandes.length - 1
                  ? IconButton(
                      icon: Icon(Icons.chevron_right, size: 40),
                      onPressed: () => setState(() => _currentCardIndex++),
                    )
                  : SizedBox(),
            ),
          ],
          
          // Indicateur de position
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
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentCardIndex 
                          ? Colors.blue 
                          : Colors.grey,
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
  // Vérification null-safe du document
 /* if (!demandeDoc.exists) {
    return _buildErrorCard("Demande introuvable");
  }*/

  final demande = demandeDoc.data() as Map<String, dynamic>? ?? {};

  return FutureBuilder<Map<String, dynamic>>(
    future: _getLocataireInfo(demande['locataire_id']?.toString() ?? ''),
    builder: (context, snapshot) {
      // Gestion des états du FutureBuilder
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLoadingCard();
      }

      /*if (snapshot.hasError || !snapshot.hasData) {
        return _buildErrorCard("Erreur de chargement");
      }*/

      final locataire = snapshot.data!;
      
      // Données par défaut sécurisées
      final prenom = locataire['prenom']?.toString() ?? 'Prénom inconnu';
      final nom = locataire['nom']?.toString() ?? '';
      final profession = locataire['profession']?.toString() ?? 'Non spécifié';
      final photoUrl = locataire['photoUrl']?.toString();

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
                // En-tête sécurisée
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null 
                          ? Text("${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}")
                          : null,
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
                          if (demande['telephone']?.toString() != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Tél: ${demande['telephone']}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Section Statut sécurisée
                if (demande['statut']?.toString() != null) ...[
                  const SizedBox(height: 16),
                  _buildStatusSection(demande['statut'].toString()),
                ],
                
                // Actions seulement si la demande est en attente
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

// Méthodes utilitaires sécurisées
Widget _buildStatusSection(String status) {
  Color color;
  String text;
  
  switch(status) {
    case 'Confirmer':
      color = Colors.green;
      text = 'Confirmée';
      break;
    case 'En attente':
      color = Colors.orange;
      text = 'En attente';
      break;
    case 'Refuser':
      color = Colors.red;
      text = 'Refusée';
      break;
    default:
      color = Colors.grey;
      text = status;
  }

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(_getStatusIcon(status), color: color),
        const SizedBox(width: 8),
        Text(
          "Statut: $text",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    ),
  );
}

IconData _getStatusIcon(String status) {
  switch(status) {
    case 'Confirmer': return Icons.check_circle;
    case 'En attente': return Icons.access_time;
    case 'Refuser': return Icons.cancel;
    default: return Icons.help_outline;
  }
}



Widget _buildLoadingCard() {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

Widget _buildErrorCard() {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: Text("Erreur de chargement", style: TextStyle(color: Colors.red))),
    ),
  );
}

Future<Map<String, dynamic>> _getLocataireInfo(String locataireId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('locataires')
        .doc(locataireId)
        .get();
    return doc.data() ?? {};
  } catch (e) {
    print("Erreur: $e");
    return {};
  }
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

 /* void _rejeterDemande(Map<String, dynamic> demande) {
    print("Demande rejetée: ${demande['nom']}");
    // Implémentez votre logique ici
  }

  void _mettreDeCote(Map<String, dynamic> demande) {
    print("Demande mise de côté: ${demande['nom']}");
    // Implémentez votre logique ici
  }*/
}