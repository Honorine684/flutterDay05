import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, String? title, required logementId, String? body});

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
      final snapshot = await FirebaseFirestore.instance
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('Aucune notification disponible.'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification['body'] ?? 'Détails non disponibles'),
                            const SizedBox(height: 5),
                            Text(
                              'Date : ${DateFormat('dd MMM yyyy à HH:mm').format((notification['timestamp'] as Timestamp).toDate())}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('visiteNotification')
                                .doc(notifications[index].id)
                                .update({'isRead': true});
                            setState(() {
                              notification['isRead'] = true;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}