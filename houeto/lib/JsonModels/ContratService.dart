import 'package:cloud_firestore/cloud_firestore.dart';

class ContratService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> preparerContrat({
    required String locataireId,
    required String logementId,
    required Map<String, dynamic> logementData,
    required String typeDemande,
    String? visiteId,
    String? demandeLocationId,
  }) async {
    // 1. Récupérer les données du locataire
    final locataireDoc = await _firestore.collection('users').doc(locataireId).get();
    final nomComplet = locataireDoc.exists 
        ? '${locataireDoc.get('prenom')} ${locataireDoc.get('nom')}'
        : 'Locataire inconnu';

    // 2. Récupérer les données du logement
    final logementDoc = await _firestore.collection('logement').doc(logementId).get();
    if (!logementDoc.exists) throw Exception("Logement introuvable");

    final logementData = logementDoc.data()!;
    final modePaiement = logementData.containsKey('loyerMois') ? 'Mois' : 'Jour';
    final loyer = modePaiement == 'Mois'
    ? (logementData['loyerMois'] as num?)?.toDouble() ?? 0
    : (logementData['loyerJour'] as num?)?.toDouble() ?? 0;
    
    final avance = (logementData['avance'] as num?)?.toDouble() ?? 0;
    final typeBail = logementData['typeDeBail'] ?? 'Standard';

    return {
      // Informations de base
      'visiteId': visiteId,
      'locataireId': locataireId,
      'logementId': logementId,
      'nomDemandeur': nomComplet,
      'typeDemande':typeDemande,
      'composition': getCompositionLogement(logementData),
      'conditionsSpeciales': getConditionsSpeciales(logementData),

      
      // Détails financiers
      'loyer': loyer,
      'avance': avance,
      'typeBail': typeBail,
      'modePaiement': modePaiement,
      'totalInitial': _calculerTotalInitial(loyer, avance, typeBail),
      
      // Détails du logement
      'detailsLogement': {
        'titre': logementData['titre'] ?? 'Sans titre',
        'adresse': logementData['adresse'] ?? 'Adresse non renseignée',
        'loyerMois': (logementData['loyerMois'] as num?)?.toDouble(),
        'loyerJour': (logementData['loyerJour'] as num?)?.toDouble(),
        'surface': logementData['surface']?.toString(),
      },
      
      // Métadonnées
      'dateCreation': Timestamp.now(),
      'statut': 'En préparation',
    };
  }

  double _calculerTotalInitial(double loyer, double avance, String typeBail) {
    return avance + (typeBail == 'Avancé' ? loyer * 6 : loyer);
  }
    
    List<String> getConditionsSpeciales(Map<String, dynamic> logementData) {
    final conditions = <String>[];
    if (logementData['estMeuble'] == true) conditions.add('✓ Logement meublé');
    if (logementData['estClimatise'] == true) conditions.add('✓ Climatisation');
     return conditions;
    }

  Map<String, String> getCompositionLogement(Map<String, dynamic> logementData) {
    return {
      'chambres': '${logementData['chambres'] ?? 0}',
      'sallesBain': '${logementData['salles_de_bain'] ?? 0}',
      'cuisines': '${logementData['cuisines'] ?? 0}',
      'salons': '${logementData['salons'] ?? 0}',
      'parking': '${logementData['salons'] ?? 0}',

    };
  }

Future<void> envoyerContrat({
  required Map<String, dynamic> contratData,
  required String dateDebut,
  required String duree,
}) async {
  final contratRef = _firestore.collection('contrats');
  
  final modePaiement = contratData['modePaiement'];
  final loyer = modePaiement == 'Mensuel' || modePaiement == 'Trimestriel' || modePaiement == 'Semestriel'
    ? (contratData['detailsLogement']['loyerMois'] as num?)?.toDouble() ?? 0.0
    : (contratData['detailsLogement']['loyerJour'] as num?)?.toDouble() ?? 0.0;
  
  await contratRef.add({
    ...contratData,
    'loyer': loyer, 
    'dateDebut': dateDebut,
    'duree': int.tryParse(duree) ?? 12,
    'statut': 'Envoyé',
    'dateEnvoi': FieldValue.serverTimestamp(),
  });

    await _firestore.collection('visite')
      .doc(contratData['visiteId'])
      .update({
        'statut': 'Contrat envoyé',
        'contratId': contratRef.id,
      });
  }
}