import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'payment',
      'title': 'Retard de Paiement',
      'subtitle': 'Loyer en retard pour l\'appartement Paris 10ème',
      'date': 'Il y a 2 jours',
      'icon': Icons.payment_outlined,
      'color': Colors.orange[700],
      'status': 'Urgent'
    },
    {
      'type': 'complaint',
      'title': 'Nouvelle Plainte',
      'subtitle': 'Problème de chauffage signalé par le locataire',
      'date': 'Hier',
      'icon': Icons.report_problem_outlined,
      'color': Colors.red[700],
      'status': 'À traiter'
    },
    {
      'type': 'visit',
      'title': 'Visite Programmée',
      'subtitle': 'Nouvelle visite confirmée pour le bien Marseille',
      'date': 'Aujourd\'hui',
      'icon': Icons.calendar_today,
      'color': Colors.green[700],
      'status': 'Confirmé'
    },
    {
      'type': 'solvency',
      'title': 'Rapport de Solvabilité',
      'subtitle': 'Nouveau rapport disponible pour un candidat locataire',
      'date': 'Il y a 3 jours',
      'icon': Icons.security_outlined,
      'color': Colors.blue[700],
      'status': 'Nouveau'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              // Options supplémentaires
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification['icon'],
                  color: notification['color'],
                  size: 28,
                ),
              ),
              title: Text(
                notification['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Text(
                    notification['subtitle'],
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: notification['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      notification['status'],
                      style: TextStyle(
                        color: notification['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Text(
                notification['date'],
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              onTap: () {
                // Action lors du tap sur une notification
              },
            ),
          );
        },
      ),
    );
  }
}
