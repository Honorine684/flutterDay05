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
    final locataireDoc = await _firestore.collection('users').doc(locataireId).get();
    final nomComplet = locataireDoc.exists 
        ? '${locataireDoc.get('prenom')} ${locataireDoc.get('nom')}'
        : 'Locataire inconnu';
    final bool hasLoyerMois = logementData.containsKey('loyerMois') && logementData['loyerMois'] != null;
    final bool hasLoyerJour = logementData.containsKey('loyerJour') && logementData['loyerJour'] != null;
        final String modePaiementDefaut = hasLoyerMois ? 'Mensuel' : (hasLoyerJour ? 'Journalier' : 'Mensuel');
        final double loyerMois = hasLoyerMois ? (logementData['loyerMois'] as num).toDouble() : 0.0;
    final double loyerJour = hasLoyerJour ? (logementData['loyerJour'] as num).toDouble() : 0.0;
        final double loyerDefaut = hasLoyerMois ? loyerMois : loyerJour;
      
    final avance = (logementData['avance'] as num?)?.toDouble() ?? 0;
    final caution = (logementData['caution'] as num?)?.toDouble() ?? 0;

    final typeBail = logementData['typeDeBail'] ?? 'Standard';
    

    return {
      'demandeLocationId':demandeLocationId,
      'visiteId': visiteId,
      'locataireId': locataireId,
      'logementId': logementId,
      'nomDemandeur': nomComplet,
      'typeDemande': typeDemande,
      'composition': getCompositionLogement(logementData),
      'conditionsSpeciales': getConditionsSpeciales(logementData),
            'loyer': loyerDefaut,
      'loyerMois': hasLoyerMois ? loyerMois : null,
      'loyerJour': hasLoyerJour ? loyerJour : null,
      'modesDisponibles': {
        'mensuel': hasLoyerMois,
        'journalier': hasLoyerJour,
      },
      'modePaiement': modePaiementDefaut,
      'avance': avance,
      'caution':caution,
      'typeBail': typeBail,
      'totalInitial': _calculerTotalInitial(loyerDefaut, avance, typeBail,caution),
      
      'detailsLogement': {
        'titre': logementData['titre'] ?? 'Sans titre',
        'adresse': logementData['adresse'] ?? 'Adresse non renseignée',
        'loyerMois': hasLoyerMois ? loyerMois : null,
        'loyerJour': hasLoyerJour ? loyerJour : null,
        'surface': logementData['surface']?.toString(),
      },
      
      'dateCreation': Timestamp.now(),
      'statut': 'En préparation',
    };
  }

  double _calculerTotalInitial(double loyer, double avance, String typeBail, double caution) {
  return avance + caution + loyer; 
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
      'parking': '${logementData['parking'] ?? 0}',
    };
  }

Future<String> envoyerContrat({
  required Map<String, dynamic> contratData,
  required String dateDebut,
  required String duree,
  required String modePaiement,
}) async {
  double totalCalcule;
  final caution = (contratData['caution'] as num?)?.toDouble() ?? 0.0;

  if (modePaiement == 'Journalier') {
    final loyer = contratData['loyerJour'] ?? 0.0;
    final jours = int.tryParse(duree) ?? 1;
    totalCalcule = caution + (loyer * jours);
  } else {
    final avance = (contratData['avance'] as num?)?.toDouble() ?? 0.0;
    final loyer = contratData['loyerMois'] ?? 0.0;
    final typeBail = contratData['typeBail'] ?? 'Standard';
    totalCalcule = avance + caution + (typeBail == 'Avancé' ? loyer * 6 : loyer);
  }

  final dateParts = dateDebut.split('/');
  if (dateParts.length != 3) throw Exception("Format de date invalide (JJ/MM/AAAA attendu)");

  final dateDebutTimestamp = Timestamp.fromDate(
    DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]))
  );

  DateTime dateFinCalculee;
  if (modePaiement == 'Journalier') {
    final jours = int.tryParse(duree) ?? 1;
    dateFinCalculee = DateTime(
      int.parse(dateParts[2]), 
      int.parse(dateParts[1]), 
      int.parse(dateParts[0]) + jours
    );
  } else {
    dateFinCalculee = DateTime(
      int.parse(dateParts[2]), 
      int.parse(dateParts[1]) + (int.tryParse(duree) ?? 12), 
      int.parse(dateParts[0])
    );
  }

  final contratRef = _firestore.collection('contrats').doc();
  
  await contratRef.set({
    ...contratData,
    'modePaiement': modePaiement,
    'totalInitial': totalCalcule,
    'dateDebut': dateDebutTimestamp,
    'dateFin': Timestamp.fromDate(dateFinCalculee),
    'duree': int.tryParse(duree) ?? (modePaiement == 'Journalier' ? 1 : 12),
    'dureeType': modePaiement == 'Journalier' ? 'jours' : 'mois',
    'statut': 'Envoyé',
    'dateEnvoi': FieldValue.serverTimestamp(),
  });

  if (contratData['visiteId'] != null) {
    await _firestore.collection('visite')
      .doc(contratData['visiteId'])
      .update({
        'statut': 'Contrat envoyé',
        'contratId': contratRef.id,
      });
  }else if(contratData['demandeLocationId'] != null){
    await _firestore.collection('demandes_logement')
      .doc(contratData['demandeId'])
      .update({
        'statut': 'Contrat envoyé',
        'contratId': contratRef.id,
      });
  }
  
  return contratRef.id;
}
}