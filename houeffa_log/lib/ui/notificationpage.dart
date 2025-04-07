import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:houeffa_log/screens/contrat.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required String title,
    required String body,
    required logementId,
  });

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<DocumentSnapshot> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('visiteNotification')
              .orderBy('timestamp', descending: true)
              .get();
      setState(() {
        notifications = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des notifications : $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> navigateToContract(String locationId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('locations')
              .doc(locationId)
              .get();

      if (doc.exists) {
        final contratData = doc.data();
        if (contratData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ContractPage(contratData: contratData),
            ),
          );
        }
      }
    } catch (e) {
      print('Erreur de chargement du contrat : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? const Center(child: Text('Aucune notification disponible.'))
              : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification =
                      notifications[index].data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ExpansionTile(
                      leading: Icon(
                        notification['isRead'] == false
                            ? Icons.notifications_active
                            : Icons.notifications,
                        color: Colors.orange,
                      ),
                      title: Text(
                        notification['title'] ?? 'Notification',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Date : ${DateFormat('dd MMM yyyy à HH:mm').format((notification['timestamp'] as Timestamp).toDate())}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8,
                          ),
                          child: Text(
                            notification['body'] ?? 'Détails non disponibles',
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('visiteNotification')
                                    .doc(notifications[index].id)
                                    .update({'isRead': true});
                                setState(() {
                                  notification['isRead'] = true;
                                });
                              },
                              icon: const Icon(Icons.visibility),
                              label: const Text('Marquer comme lu'),
                            ),
                            if (notification['typeDemande'] == 'contrat' &&
                                notification['locationId'] != null)
                              TextButton.icon(
                                onPressed: () {
                                  navigateToContract(
                                    notification['locationId'],
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Voir contrat'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
