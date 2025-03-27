import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
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
                    Text(
                      title ?? 'Nouvelle Notification',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      body ?? 'Aucune information supplémentaire disponible.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade800,
                          ),
                    ),
                    if (logementId != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.home, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Logement ID : $logementId',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              child: ElevatedButton(
                onPressed: logementId != null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Afficher détails pour $logementId')),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Voir les détails'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}