import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  final String? visiteId; 

  const NotificationPage({
    super.key,
    this.visiteId, 
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<DocumentSnapshot?> _fetchVisiteNotification(String visiteId) async { 
    try {
      return await FirebaseFirestore.instance
          .collection('visiteNotification')
          .doc(visiteId) 
          .get();
    } catch (e) {
      print("Erreur lors de la récupération de la notification : $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.visiteId == null 
            ? const Center(
                child: Text(
                  'Aucune notification sélectionnée.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : FutureBuilder<DocumentSnapshot?>(
                future: _fetchVisiteNotification(widget.visiteId!), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        'Notification introuvable ou erreur de chargement.',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }

                  
                  final visiteNotification = snapshot.data!;
                  final String title = visiteNotification['title'] ?? 'Nouvelle Notification';
                  final String body = visiteNotification['body'] ?? 'Aucune information supplémentaire.';
                  final bool isRead = visiteNotification['isRead'] ?? false;
                  final String receiverId = visiteNotification['receiverId'] ?? 'Inconnu';
                  final String senderId = visiteNotification['senderId'] ?? 'Inconnu';
                  final Timestamp? timestamp = visiteNotification['timestamp'];
                  final String visiteId = visiteNotification['visiteId'] ?? 'Non spécifié';

                  
                  String formattedDate = timestamp != null
                      ? DateFormat('dd MMMM yyyy à HH:mm:ss').format(timestamp.toDate())
                      : 'Date non disponible';

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.notifications_active,
                                        color: Colors.deepOrange, size: 28),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              color: Colors.blue.shade900,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  body,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.grey.shade800,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Visite ID : $visiteId',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.date_range, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Date : $formattedDate',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.blue),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                                      color: isRead ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Statut : ${isRead ? "Lue" : "Non lue"}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: isRead ? Colors.green : Colors.red),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Envoyé par : $senderId',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Destinataire : $receiverId',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Fermer',
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}