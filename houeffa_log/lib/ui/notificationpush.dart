import 'package:flutter/material.dart';
import 'package:houeffa_log/screens/logementDetailsPage.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
class NotificationPage extends StatefulWidget {
  final String? title;
  final String? body;
  final String? logementId;

  const NotificationPage({
    super.key,
    this.title,
    this.body,
    this.logementId,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<DocumentSnapshot?> _fetchLogementDetails(String logementId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('logement')
          .doc(logementId)
          .get();
    } catch (e) {
      print("Erreur lors de la récupération du logement : $e");
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
                            widget.title ?? 'Nouvelle Notification',
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
                      widget.body ?? 'Aucune information supplémentaire disponible.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade800,
                          ),
                    ),
                    if (widget.logementId != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.home, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Logement ID : ${widget.logementId}',
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
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: widget.logementId != null
                        ? () async {
                            
                            final logementDoc =
                                await _fetchLogementDetails(widget.logementId!);
                            if (logementDoc != null && logementDoc.exists) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LogementDetailsPage(
                                      logement: logementDoc),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Logement introuvable ou erreur de chargement')),
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Voir les détails'),
                  ),
                  if (widget.logementId == null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Aucune action disponible pour cette notification.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); 
                    },
                    child: const Text(
                      'Fermer',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}