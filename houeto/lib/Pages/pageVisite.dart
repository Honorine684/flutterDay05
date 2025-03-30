import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:houeto/JsonModels/ContratService.dart';
import 'package:houeto/JsonModels/NotificationPushVisite.dart';
import 'package:houeto/Pages/ContratForm.dart';
import 'package:intl/intl.dart';

class PageVisites extends StatefulWidget {
  const PageVisites({super.key});

  @override
  State<PageVisites> createState() {
    return PageVisitesState();
  }
}

class PageVisitesState extends State<PageVisites> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Demandes de visites',
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
            _buildVisitesList(userId, 'En attente'),
            _buildVisitesList(userId, 'Confirmer'),
            _buildVisitesList(userId, 'Annuler'),
          ],
        ),
      ),
    );
  }

Widget _buildVisitesList(String userId, String status) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('visite')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('Aucune visite trouvée'));
      }

      return FutureBuilder<List<dynamic>>(
        future: _getLogementsAndUsers(userId, snapshot.data!.docs),
        builder: (context, combinedSnapshot) {
          if (!combinedSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allVisites = combinedSnapshot.data!;
          final visitesFiltrees = allVisites.where((item) => 
            item['visite']['statut'] == status
          ).toList();
          
          if (visitesFiltrees.isEmpty) {
            return Center(
                child: Text('Aucune visite $status pour vos logements'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: visitesFiltrees.length,
            itemBuilder: (context, index) {
              final item = visitesFiltrees[index];
              return _buildVisiteCard(
                item['visite'],
                item['docId'],
                item['nomComplet'],
                item['logementNom'],
                item['jour'],
                item['heure'],
                item['telephone'],
                context,
              );
            },
          );
        },
      );
    },
  );
}

  Future<List<Map<String, dynamic>>> _getLogementsAndUsers(
      String userId, List<QueryDocumentSnapshot> visiteDocs) async {
    //récupérer les logements du propriétaire
    final logementsSnapshot = await FirebaseFirestore.instance
        .collection('logement')
        .where('proprietaireId', isEqualTo: userId)
        .get();

    final logementsMap = {
      for (var doc in logementsSnapshot.docs) doc.id: doc.data()
    };

    // Filtrer les visites pour ne garder que celles concernant les logements du propriétaire
    final visitesFiltrees = visiteDocs.where((visiteDoc) {
      final visite = visiteDoc.data() as Map<String, dynamic>;
      return logementsMap.containsKey(visite['logementId']);
    }).toList();

    // Récupérer tous les IDs des locataires uniques
    final locataireIds = visitesFiltrees
        .map((doc) =>
            (doc.data() as Map<String, dynamic>)['locataireId'] as String)
        .toSet()
        .toList();

    // Récupérer les informations des utilisateurs
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: locataireIds)
        .get();

    final userMap = {for (var user in users.docs) user.id: user.data()};

    // Combiner toutes les données
    return visitesFiltrees.map((doc) {
      final visite = doc.data() as Map<String, dynamic>;
      final userData = userMap[visite['locataireId']];
      final logementData = logementsMap[visite['logementId']];

      return {
        'visite': visite,
        'docId': doc.id,
        'nomComplet': userData != null
            ? '${userData['prenom']} ${userData['nom']}'
            : 'Locataire inconnu',
        'logementNom': logementData?['titre'] ?? 'Logement inconnu',
        'jour': visite['jour'],
        'heure': visite['heure'],
        'telephone': visite['telephone']
      };
    }).toList();
  }

  Widget _buildVisiteCard(
    Map<String, dynamic> visite,
    String docId,
    String nomComplet,
    String logementNom,
    String jour,
    String heure,
    String telephone,
    BuildContext context,
  ) {
    final statusColor = visite['statut'] == 'Annuler'
        ? Colors.red
        : (visite['statut'] == 'Confirmer' ? Colors.green : Colors.orange);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header avec nom du locataire et statut
          Row(
            children: [
              const Icon(Icons.person, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nomComplet,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Chip(
                label: Text(visite['statut']),
                backgroundColor: statusColor.withOpacity(0.2),
                labelStyle: TextStyle(color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Détails du logement
          Row(
            children: [
              const Icon(Icons.home, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                logementNom,
              )
            ],
          ),
          const SizedBox(height: 8),

          // Date de la visite
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Envoyé le ${DateFormat('dd/MM/yyyy à HH:mm').format((visite['timestamp'] as Timestamp).toDate())}",
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.calendar_view_day_rounded,
                  size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Demandé pour le $jour à $heure",
              ),
            ],
          ),

          // Boutons d'action (uniquement pour les visites "En attente")
         if (visite['statut'] == 'En attente') ...[
  const SizedBox(height: 12),
  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    // Bouton Annuler
    OutlinedButton(
      onPressed: () => _annulerVisite(docId, context),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
      ),
      child: const Text('Annuler', style: TextStyle(color: Colors.red)),
    ),
    const SizedBox(width: 10),

    // Bouton Accepter
    ElevatedButton(
      onPressed: () => _confirmerVisite(docId, context),
      child: const Text('Accepter'),
    ),
  ]),
] 
else if (visite['statut'] == 'Confirmer') ...[
  const SizedBox(height: 12),
  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    ElevatedButton.icon(
      icon: const Icon(Icons.document_scanner_rounded,color: Colors.white,),
      label: const Text('Envoyer contrat'),
      onPressed: () => {
       envoyerContrat(docId, context, nomComplet, logementNom),
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    ),
  ])
],
          
        ]),
      ),
    );
  }

  Future<void> _confirmerVisite(String visiteId, BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Récupérer les données de la visite
      final visiteDoc =
          await firestore.collection('visite').doc(visiteId).get();
      if (!visiteDoc.exists) throw Exception("Visite introuvable");
      final visiteData = visiteDoc.data() as Map<String, dynamic>;

      final receiverId = visiteData['locataireId'];
      final logementId = visiteData['logementId'];

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
          .collection('visite')
          .doc(visiteId)
          .update({'statut': 'Confirmer'});

      // Envoyer la notification
      await NotificationServiceVisite().sendNotificationVisite(
        receiverId: receiverId,
        title: "Visite confirmée",
        body:
            "Votre visite pour **$logementNom**, appartenant à $proprietaireNom a été confirmé.",
        visiteId: visiteId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Visite confirmée et notification envoyée')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _annulerVisite(String visiteId, BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Récupérer les données de la visite
      final visiteDoc =
          await firestore.collection('visite').doc(visiteId).get();
      if (!visiteDoc.exists) throw Exception("Visite introuvable");
      final visiteData = visiteDoc.data() as Map<String, dynamic>;

      final receiverId = visiteData['locataireId'];
      final logementId = visiteData['logementId'];

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
                hintText: 'Pourquoi annulez-vous cette visite ?',
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
      await firestore.collection('visite').doc(visiteId).update({
        'statut': 'Annuler',
        'motifAnnulation': motif,
      });

      // Envoyer la notification
      await NotificationServiceVisite().sendNotificationVisite(
        receiverId: receiverId,
        title: "Visite annulée",
        body:
            "$proprietaireNom a annulé votre visite pour **$logementNom** Motif : $motif",
        visiteId: visiteId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visite annulée et notification envoyée')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

Future<void> envoyerContrat(String visiteId, BuildContext context, String nomLocataire, String logementNom) async {
  try {
    // 1. Initialisation
    final contratService = ContratService();
    final firestore = FirebaseFirestore.instance;

    // 2. Récupération des données
    final visiteDoc = await firestore.collection('visite').doc(visiteId).get();
    if (!visiteDoc.exists) throw Exception("Visite introuvable");
    
    final visiteData = visiteDoc.data() as Map<String, dynamic>;
    final locataireId = visiteData['locataireId'];
    final logementId = visiteData['logementId'];

    final logementDoc = await firestore.collection('logement').doc(logementId).get();
    if (!logementDoc.exists) throw Exception("Logement introuvable");
    final logementData = logementDoc.data() as Map<String, dynamic>;

    // 3. Préparation du contrat
    final contratData = await contratService.preparerContrat(
      locataireId: locataireId,
      logementId: logementId,
      logementData: logementData,
      typeDemande: 'visite',
      visiteId: visiteId,
    );

    // 4. Affichage du formulaire
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ContratForm(
        contratData: contratData,
        onSubmit: (dateDebut, duree, modePaiement) async {
          // 5. Envoi du contrat
          await contratService.envoyerContrat(
            contratData: {
              ...contratData,
              'modePaiement': modePaiement,
            },
            dateDebut: dateDebut,
            duree: duree,
          );

          // 6. Notification
          await NotificationServiceVisite().sendNotificationVisite(
            receiverId: locataireId,
            title: "Contrat de location prêt",
            body: "Le contrat pour $logementNom est disponible. Montant Total: ${contratData['totalInitial'].toStringAsFixed(2)} fcfa",
            visiteId: visiteId,
          );
        },
      ),
    );

    // 7. Feedback
    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contrat envoyé avec succès'),
          duration: Duration(seconds: 2),
      ));
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          duration: Duration(seconds: 2),
      ));
    }
  }
}
}
