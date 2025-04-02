import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:houeto/JsonModels/Logement.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatistiquePage extends StatefulWidget {
  const StatistiquePage({super.key});

  @override
  State<StatistiquePage> createState() => _StatistiquePageState();
}

class _StatistiquePageState extends State<StatistiquePage> {
  late Future<List<Logement>> _logementsFuture;

  @override
  void initState() {
    super.initState();
    _logementsFuture = _fetchLogements();
  }

    Future<List<Logement>> _fetchLogements() async {
  // Récupérer l'UID de l'utilisateur connecté
  final userId = FirebaseAuth.instance.currentUser?.uid;
  
  // Si aucun utilisateur connecté, retourner liste vide
  if (userId == null || userId.isEmpty) return [];
  
  try {
    // Récupérer les logements de l'utilisateur
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('logement')
        .where('proprietaireId', isEqualTo: userId)
        .get();

    // Convertir les documents en objets Logement
    return snapshot.docs.map((doc) => Logement.fromFirestore(doc)).toList();
    
  } catch (e) {
    print('Erreur lors de la récupération des logements: $e');
    return [];
  }
}

  Map<String, int> _groupByType(List<Logement> logements) {
    Map<String, int> result = {};
    for (var logement in logements) {
      result.update(
        logement.typeProperty,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return result;
  }

  Map<String, int> _groupByStatut(List<Logement> logements) {
    Map<String, int> result = {'Occuper': 0, 'Inocupper': 0};
    for (var logement in logements) {
      if (logement.statut.toLowerCase().contains('occuper')) {
        result['Occuper'] = result['Occuper']! + 1;
      } else {
        result['Inocupper'] = result['Inocupper']! + 1;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Statistiques Immobilières")),
      body: FutureBuilder<List<Logement>>(
        future: _logementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          
          final logements = snapshot.data!;
          final biensParType = _groupByType(logements);
          final statuts = _groupByStatut(logements);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCard("Répartition par Type", _buildPieChart(biensParType)),
                _buildCard("Statut des Biens", _buildBarChart(statuts)),
                SizedBox(height: 20,),
                Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Statistique de vos revenus",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        SizedBox(height: 8,width: 8,),
                        buildRevenusRadialChart()
                      ],
                    ),
                      )
                  ),
                _buildTopBiensCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, Widget chart) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap
      ),
      series: <CircularSeries>[
        PieSeries<MapEntry<String, int>, String>(
          dataSource: data.entries.toList(),
          xValueMapper: (entry, _) => entry.key,
          yValueMapper: (entry, _) => entry.value,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
          ),
          explode: true,
          explodeIndex: 0,
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, int> data) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(minimum: 0),
      series: <CartesianSeries>[
        ColumnSeries<MapEntry<String, int>, String>(
          dataSource: data.entries.toList(),
          xValueMapper: (entry, _) => entry.key,
          yValueMapper: (entry, _) => entry.value,
          color: Colors.blue,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
Future<List<Map<String, dynamic>>> getTopBiens() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return [];

  try {
    // 1. Récupérer les logements de l'utilisateur
    final userLogements = await FirebaseFirestore.instance
        .collection('logement')
        .where('proprietaireId', isEqualTo: currentUser.uid)
        .get();

    if (userLogements.docs.isEmpty) return [];

    // 2. Créer une map {id: nom} des logements
    final logementsMap = {
      for (var doc in userLogements.docs) 
        doc.id: doc.get('titre') ?? 'Nom inconnu'
    };

    // 3. Récupérer les visites non annulées
    final visitesSnapshot = await FirebaseFirestore.instance
        .collection('visite')
        .where('statut', isNotEqualTo: 'Annuler')
        .get();

    // 4. Compter les visites par logement
    final compteur = <String, int>{};
    for (final doc in visitesSnapshot.docs) {
      final logementId = doc['logementId'] as String;
      if (logementsMap.containsKey(logementId)) {
        compteur.update(logementId, (count) => count + 1, ifAbsent: () => 1);
      }
    }

    // 5. CORRECTION ICI : Séparer le tri et le take(3)
    // D'abord convertir en liste
    final entriesList = compteur.entries.toList();
    
    // Puis trier (cette opération modifie la liste existante)
    entriesList.sort((a, b) => b.value.compareTo(a.value));
    
    // Enfin prendre les 3 premiers
    final top3 = entriesList.take(3).toList();

    // 6. Formater le résultat
    return top3.map((entry) {
      return {
        'logementId': entry.key,
        'logementNom': logementsMap[entry.key] ?? 'Nom inconnu',
        'visites': entry.value,
      };
    }).toList();

  } catch (e) {
    print('Erreur lors de la récupération des top biens: $e');
    return [];
  }

}
 Widget _buildTopBiensCard() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: getTopBiens(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text("Aucune donnée de visite disponible"),
          ),
        );
      }

      final topBiens = snapshot.data!;

      return Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Top 3 des Biens", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...topBiens.map((bien) => ListTile(
                title: Text(bien['logementNom']),
                subtitle: Text("${bien['visites']} visites"),
                onTap: () {
                },
              )),
            ],
          ),
        ),
      );
    },
  );
}
Widget buildRevenusRadialChart() {
  final revenusData = [
    {'type': 'Mensuel', 'montant': 8500, 'color': Colors.blue[400]!},
    {'type': 'Journalier', 'montant': 4200, 'color': Colors.teal[300]!},
    {'type': 'Mixte', 'montant': 3100, 'color': Colors.amber[600]!},
    {'type': 'Services', 'montant': 1200, 'color': Colors.deepPurple[300]!},
  ];

  return SfCircularChart(
    palette: [Colors.blue[400]!, Colors.teal[300]!, Colors.amber[600]!, Colors.deepPurple[300]!],
    series: <CircularSeries>[
      RadialBarSeries<Map<String, dynamic>, String>(
        dataSource: revenusData,
        xValueMapper: (data, _) => data['type'],
        yValueMapper: (data, _) => data['montant'],
        cornerStyle: CornerStyle.bothCurve,
        maximumValue: 10000,
        radius: '100%',
        gap: '5%',
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          useSeriesColor: true,
          labelPosition: ChartDataLabelPosition.outside,
        ),
      ),
    ],
    annotations: <CircularChartAnnotation>[
      CircularChartAnnotation(
       widget: Text.rich(
  TextSpan(
    children: [
      TextSpan(
        text: 'Total Revenus\n',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.grey[700],
        ),
      ),
      TextSpan(
        text: '${NumberFormat.currency(
          locale: 'fr_FR',
          symbol: '',
          decimalDigits: 0,
        ).format(revenusData.fold(0, (sum, item) => sum))} FCFA',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    ],
  ),
  textAlign: TextAlign.center,
),
      ),
    ],
  );
}
}