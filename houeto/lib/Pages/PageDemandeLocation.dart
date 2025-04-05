import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:houeto/JsonModels/ContratService.dart';
import 'package:houeto/JsonModels/NotificationPushVisite.dart';
import 'package:houeto/Pages/ContratForm.dart';
import 'package:intl/intl.dart';

class Pagedemandelocation extends StatefulWidget {
  const Pagedemandelocation({super.key});

  @override
  State<Pagedemandelocation> createState() {
    return PagedemandelocationState();
  }
}

class PagedemandelocationState extends State<Pagedemandelocation> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Demandes de location',
              style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.schedule), text: 'En attente'),
              Tab(icon: Icon(Icons.check_circle), text: 'Confirmer'),
              Tab(icon: Icon(Icons.cancel), text: 'Annuler'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLocationList(userId, 'En attente'),
            _buildLocationList(userId, 'Confirmer'),
            _buildLocationList(userId, 'Annuler'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationList(String userId, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('demandes_logement')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucune demande trouvée'));
        }

        return FutureBuilder<List<dynamic>>(
          future: _getLogementsAndUsers(userId, snapshot.data!.docs),
          builder: (context, combinedSnapshot) {
            if (!combinedSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allDemandes = combinedSnapshot.data!;
            final DemandesFiltrees = allDemandes
                .where((item) => item['demande']['statut'] == status)
                .toList();

            if (DemandesFiltrees.isEmpty) {
              return Center(
                  child: Text('Aucune demande $status pour vos logements'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: DemandesFiltrees.length,
              itemBuilder: (context, index) {
                final item = DemandesFiltrees[index];
                return _buildVisiteCard(
                  item['demande'] as Map<String, dynamic>,
                  item['docId'] as String,
                  item['nomComplet'] as String? ?? 'Locataire inconnu',
                  item['logementNom'] as String? ?? 'Logement inconnu',
                  item['telephone'] as String? ?? 'Non spécifié',
                  item['profession'] as String? ?? 'Non spécifié',
                  context,
                  role: item['role'] as String? ?? 'Propriétaire',
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getLogementsAndUsers(
      String userId, List<QueryDocumentSnapshot> demandeDocs) async {
    // Récupérer les logements (propriétaire ou gestionnaire)
    final logementsProprietaireSnapshot = await FirebaseFirestore.instance
        .collection('logement')
        .where('proprietaireId', isEqualTo: userId)
        .get();

    final logementsGestionnaireSnapshot = await FirebaseFirestore.instance
        .collection('logement')
        .where('gestionnaireId', isEqualTo: userId)
        .get();

    final logementsMap = {
      for (var doc in [
        ...logementsProprietaireSnapshot.docs,
        ...logementsGestionnaireSnapshot.docs
      ])
        doc.id: doc.data()
    };

    // Filtrer les demandes pour les logements de l'utilisateur
    final demandesFiltrees = demandeDocs.where((demandeDoc) {
      final demande = demandeDoc.data() as Map<String, dynamic>;
      return logementsMap.containsKey(demande['logement_id']);
    }).toList();

    if (demandesFiltrees.isEmpty) {
      return [];
    }

    // Récupérer les IDs des locataires
    final locataireIds = demandesFiltrees
        .map((doc) =>
            (doc.data() as Map<String, dynamic>)['locataire_id'] as String)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    // Récupérer les infos utilisateurs
    final userMap = <String, Map<String, dynamic>>{};
    if (locataireIds.isNotEmpty) {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: locataireIds)
          .get();

      for (var user in users.docs) {
        userMap[user.id] = user.data();
      }
    }

    // Combiner les données
    return demandesFiltrees.map((doc) {
      final demande = doc.data() as Map<String, dynamic>;
      final userData = userMap[demande['locataire_id']] ?? {};
      final logementData = logementsMap[demande['logement_id']] ?? {};

      final String role = logementData['proprietaireId'] == userId
          ? 'Propriétaire'
          : 'Gestionnaire';

      return {
        'demande': demande,
        'docId': doc.id,
        'nomComplet':
            '${userData['prenom'] ?? demande['prenom'] ?? ''} ${userData['nom'] ?? demande['nom'] ?? ''}'
                .trim(),
        'logementNom': logementData['titre'] ?? 'Logement inconnu',
        'telephone':
            userData['telephone'] ?? demande['telephone'] ?? 'Non spécifié',
        'profession':
            userData['profession'] ?? demande['profession'] ?? 'Non spécifié',
        'role': role,
      };
    }).toList();
  }

  Widget _buildVisiteCard(
    Map<String, dynamic> visite,
    String docId,
    String nomComplet,
    String logementNom,
    String telephone,
    String profession,
    BuildContext context, {
    String role = 'Propriétaire', // Ajout du paramètre optionnel pour le rôle
  }) {
    nomComplet = nomComplet.isNotEmpty ? nomComplet : 'Locataire inconnu';
    logementNom = logementNom.isNotEmpty ? logementNom : 'Logement inconnu';
    telephone = telephone.isNotEmpty ? telephone : 'Non spécifié';
    profession = profession.isNotEmpty ? profession : 'Non spécifié';
    final statusColor = visite['statut'] == 'Annuler'
        ? Colors.red
        : (visite['statut'] == 'Confirmer' ? Colors.green : Colors.orange);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom du locataire et statut
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomComplet,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Statut: $profession",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(visite['statut']),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
              ],
            ),

            const Divider(height: 24),

            // Détails du logement et rôle
            Row(
              children: [
                const Icon(Icons.home, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    logementNom,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Informations sur la date
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Envoyé le ${DateFormat('dd/MM/yyyy à HH:mm').format((visite['timestamp'] as Timestamp).toDate())}",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Boutons d'action
            if (visite['statut'] == 'En attente')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Refuser'),
                    onPressed: () => _annulerDemande(docId, context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accepter'),
                    onPressed: () => _confirmerDemande(docId, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              )
            else if (visite['statut'] == 'Confirmer')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.document_scanner_rounded, size: 18),
                    label: const Text('Envoyer contrat'),
                    onPressed: () =>
                        envoyerContrat(docId, context, nomComplet, logementNom),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmerDemande(String demandeId, BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Récupérer les données de la visite
      final demandeDoc =
          await firestore.collection('demandes_logement').doc(demandeId).get();
      if (!demandeDoc.exists) throw Exception("Visite introuvable");
      final demandeData = demandeDoc.data() as Map<String, dynamic>;

      final receiverId = demandeData['locataire_id'];
      final logementId = demandeData['logement_id'];

      // Récupérer les infos du logement
      final logementDoc =
          await firestore.collection('logement').doc(logementId).get();
      if (!logementDoc.exists) throw Exception("Logement introuvable");

      final logementData = logementDoc.data() as Map<String, dynamic>;
      final logementNom = logementData['titre'] ?? "Logement inconnu";
      final proprietaireNom =
          logementData['nomProprietaire'] ?? "Propriétaire inconnu";

      // Mettre à jour le statut de la visite
      await firestore
          .collection('demandes_logement')
          .doc(demandeId)
          .update({'statut': 'Confirmer'});

      // Envoyer la notification
      await NotificationServiceVisite().sendNotificationVisite(
        receiverId: receiverId,
        title: "Demande de location confirmée",
        body:
            "Votre demande pour **$logementNom**, appartenant à $proprietaireNom a été confirmé.",
        demandeId: demandeId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Demande de location confirmée et notification envoyée')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _annulerDemande(String demandeId, BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Récupérer les données de la visite
      final demandeDoc =
          await firestore.collection('demandes_logement').doc(demandeId).get();
      if (!demandeDoc.exists) throw Exception("Demande introuvable");
      final demandeData = demandeDoc.data() as Map<String, dynamic>;

      final receiverId = demandeData['locataire_id'];
      final logementId = demandeData['logement_id'];

      // Récupérer les infos du logement
      final logementDoc =
          await firestore.collection('logement').doc(logementId).get();
      if (!logementDoc.exists) throw Exception("Logement introuvable");

      final logementData = logementDoc.data() as Map<String, dynamic>;
      final logementNom = logementData['titre'] ?? "Logement inconnu";
      final proprietaireNom =
          logementData['nomProprietaire'] ?? "Propriétaire inconnu";

      // Demander le motif d'annulation
      final motif = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Motif d\'annulation'),
          content: TextField(
            decoration: const InputDecoration(
                hintText: 'Pourquoi annulez-vous cette demande de location ?',
                hintStyle: TextStyle(fontSize: 13)),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler')),
            TextButton(
                onPressed: () => Navigator.pop(context, 'Motif non précisé'),
                child: const Text('Confirmer')),
          ],
        ),
      );

      if (motif == null) return;

      // Mettre à jour le statut de la visite
      await firestore.collection('demandes_logement').doc(demandeId).update({
        'statut': 'Annuler',
        'motifAnnulation': motif,
      });

      // Envoyer la notification
      await NotificationServiceVisite().sendNotificationVisite(
        receiverId: receiverId,
        title: "Demande de location annulée",
        body:
            "$proprietaireNom a annulé votre demande de location pour **$logementNom** Motif : $motif",
        demandeId: demandeId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Demande de location annulée et notification envoyée')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> envoyerContrat(String demandeId, BuildContext context,
      String nomLocataire, String logementNom) async {
    try {
      final contratService = ContratService();
      final firestore = FirebaseFirestore.instance;

      final demandeDoc =
          await firestore.collection('demandes_logement').doc(demandeId).get();
      if (!demandeDoc.exists) throw Exception("Demande introuvable");

      final demandeData = demandeDoc.data() as Map<String, dynamic>;
      final locataireId = demandeData['locataire_id'];
      final logementId = demandeData['logement_id'];

      final logementDoc =
          await firestore.collection('logement').doc(logementId).get();
      if (!logementDoc.exists) throw Exception("Logement introuvable");
      final logementData = logementDoc.data() as Map<String, dynamic>;

      final contratData = await contratService.preparerContrat(
        locataireId: locataireId,
        logementId: logementId,
        logementData: logementData,
        typeDemande: 'Demande location',
        demandeLocationId: demandeId,
      );

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ContratForm(
          contratData: contratData,
          onSubmit: (dateDebut, duree, modePaiement) async {
            final contratId = await contratService.envoyerContrat(
              contratData: {
                ...contratData,
                'modePaiement': modePaiement,
              },
              dateDebut: dateDebut,
              duree: duree,
              modePaiement: modePaiement,
            );

            double totalToShow = 0.0;
            final avance = (contratData['avance'] as num?)?.toDouble() ?? 0.0;

            if (modePaiement == 'Journalier') {
              final loyerJour = contratData['loyerJour'] ??
                  (contratData['detailsLogement']?['loyerJour'] as num?)
                      ?.toDouble() ??
                  0.0;
              totalToShow = avance + (loyerJour * (int.tryParse(duree) ?? 1));
            } else {
              final loyerMois = contratData['loyerMois'] ??
                  (contratData['detailsLogement']?['loyerMois'] as num?)
                      ?.toDouble() ??
                  0.0;
              final typeBail =
                  contratData['typeBail']?.toString() ?? 'Standard';
              totalToShow =
                  avance + (typeBail == 'Avancé' ? loyerMois * 6 : loyerMois);
            }

            await NotificationServiceVisite().sendNotificationVisite(
              receiverId: locataireId,
              title: "Contrat de location prêt",
              body:
                  "Le contrat pour $logementNom est disponible. Montant Total: ${totalToShow.toStringAsFixed(2)} FCFA",
              demandeId: demandeId,
              contratId: contratId,
            );
          },
        ),
      );

      if (confirmed == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Contrat envoyé avec succès'),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }
}
