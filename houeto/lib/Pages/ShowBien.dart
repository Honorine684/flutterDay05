import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:houeto/JsonModels/Logement.dart';
import 'package:houeto/JsonModels/NotificationPush.dart';
import 'package:houeto/Pages/EditLogement.dart';
import 'package:houeto/Pages/PageDetails.dart';

class Showbien extends StatefulWidget {
  const Showbien({super.key});

  @override
  State<Showbien> createState() => _ShowbienState();
}

class _ShowbienState extends State<Showbien> {
  List<Logement> logements = [];
  List<Logement> filteredLogements = [];
  bool showNonConfiedOnly = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLogement();
  }

  void loadLogement() async {
    setState(() => isLoading = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        logements = [];
        isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('logement')
          .where('proprietaireId', isEqualTo: currentUser.uid)
          .get();

      List<Logement> loadedLogements = [];

      for (var doc in snapshot.docs) {
        try {
          final logement = Logement.fromFirestore(doc);
          loadedLogements.add(logement);
        } catch (e) {
          print("Error parsing logement ${doc.id}: $e");
        }
      }

      setState(() {
        logements = loadedLogements;
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading logements: $e");
      setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredLogements = showNonConfiedOnly
          ? logements
              .where((logement) => logement.mode == "Non confier")
              .toList()
          : List.from(logements);
    });
  }

  void _toggleFilter() {
    setState(() {
      showNonConfiedOnly = !showNonConfiedOnly;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes biens immobiliers"),
        actions: [
          IconButton(
            icon: Icon(
              showNonConfiedOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: showNonConfiedOnly ? Colors.blue : null,
            ),
            onPressed: _toggleFilter,
            tooltip: showNonConfiedOnly
                ? "Afficher tous les logements"
                : "Filtrer les non confiés",
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (logements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_work, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Aucun logement trouvé",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text("Ajoutez votre premier bien immobilier"),
          ],
        ),
      );
    }

    if (filteredLogements.isEmpty && showNonConfiedOnly) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_turned_in,
                size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Tous vos logements sont confiés",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: _toggleFilter,
              child: const Text("Voir tous les logements"),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredLogements.length,
      itemBuilder: (context, index) {
        return _buildLogementCard(filteredLogements[index]);
      },
    );
  }

  Widget _buildLogementCard(Logement logement) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageDetailsProprietaire(logement: logement),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${logement.typeProperty} - ${logement.titre}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(logement),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                logement.adresse,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${logement.surface.toStringAsFixed(0)} m²",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${logement.chambres} chambres",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getFormattedPrice(logement),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      if (logement.mode == "Non confier")
                        ElevatedButton(
                          onPressed: () =>
                              _showProprietairesDialog(logement.id),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text("Confier"),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Editlogement(logementId: logement.id),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(logement.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Logement logement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            logement.statut == "Occuper" ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        logement.statut,
        style: TextStyle(
          color: logement.statut == "Occuper"
              ? Colors.red[800]
              : Colors.green[800],
          fontSize: 12,
        ),
      ),
    );
  }

  String _getFormattedPrice(Logement logement) {
    if (logement.loyerMois > 0 && logement.loyerJour > 0) {
      return "${logement.loyerMois.toStringAsFixed(0)} FCFA/mois\n${logement.loyerJour.toStringAsFixed(0)} FCFA/jour";
    } else if (logement.loyerMois > 0) {
      return "${logement.loyerMois.toStringAsFixed(0)} FCFA/mois";
    } else if (logement.loyerJour > 0) {
      return "${logement.loyerJour.toStringAsFixed(0)} FCFA/jour";
    }
    return "Prix sur demande";
  }

  void _showDeleteConfirmation(String logementId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Êtes-vous sûr de vouloir supprimer ce logement ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('logement')
                    .doc(logementId)
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logement supprimé avec succès"),
                    backgroundColor: Colors.green,
                  ),
                );
                loadLogement();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Erreur lors de la suppression: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showProprietairesDialog(String logementId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final proprietaires = await _getOtherProprietaires(currentUser.uid);
      if (proprietaires.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun autre propriétaire disponible")),
        );
        return;
      }



       showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Confier à un propriétaire"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: proprietaires.length,
          itemBuilder: (context, index) {
            final proprietaire = proprietaires[index];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text('${proprietaire['prenom']} ${proprietaire['nom']}'),
              subtitle: Text(proprietaire['email']),
             onTap: () async {
  Navigator.pop(context);
  await _assignToProprietaire(
    logementId, 
    proprietaire['uid'], 
    '${proprietaire['prenom']} ${proprietaire['nom']}' 
  );
},
            );
          },
        ),
      ),
    ),
  );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getOtherProprietaires(String currentUserId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'proprietaire')
      .where(FieldPath.documentId, isNotEqualTo: currentUserId)
      .get();

  return snapshot.docs.map((doc) {
    final nom = doc['nom'] ?? '';
    final prenom = doc['prenom'] ?? '';
    
    final nomComplet = '$prenom $nom'.trim();
    
    return {
      'uid': doc.id,
      'nomComplet': nomComplet.isNotEmpty ? nomComplet : 'Nom inconnu',
      'email': doc['email'] ?? 'Email inconnu',
      'nom': nom, 
      'prenom': prenom,
    };
  }).toList();
}

 Future<void> _assignToProprietaire(
  String logementId, 
  String proprietaireId, 
  String proprietaireName 
) async {
  try {
    final logementDoc = await FirebaseFirestore.instance
        .collection('logement')
        .doc(logementId)
        .get();

    final logementName = logementDoc['titre'] ?? "un logement";

    await FirebaseFirestore.instance
        .collection('logement')
        .doc(logementId)
        .update({
      'gestionnaireId': proprietaireId,
      'mode': 'Confier',
    });

    await NotificationService().sendNotification(
      receiverId: proprietaireId,
      title: "Demande de gestion",
      body: "Le logement \"$logementName\" vous a été confié par $proprietaireName",
      logementId: logementId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Le logement \"$logementName\" a été confié à $proprietaireName"),
        backgroundColor: Colors.green,
      ),
    );

    loadLogement();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Erreur lors de la confiance: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}
}