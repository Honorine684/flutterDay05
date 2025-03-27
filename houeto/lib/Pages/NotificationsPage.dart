import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {


  Map<String, dynamic> _getNotificationStyle(String type) {
    switch (type) {
      case 'payment':
        return {
          'icon': Icons.payment_outlined,
          'color': Colors.orange[700],
        };
      case 'complaint':
        return {
          'icon': Icons.report_problem_outlined,
          'color': Colors.red[700],
        };
      case 'visit':
        return {
          'icon': Icons.calendar_today,
          'color': Colors.green[700],
        };
      case 'solvency':
        return {
          'icon': Icons.security_outlined,
          'color': Colors.grey[700],
        };
      default:
        return {
          'icon': Icons.notifications_outlined,
          'color': Colors.blue[700],
        };
    }
  }

  // Méthode pour formater la date relative
  String _formatRelativeTime(Timestamp timestamp) {
    DateTime notificationTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(notificationTime);

    if (difference.inHours < 24) {
      return 'Aujourd\'hui';
    } else if (difference.inHours < 48) {
      return 'Hier';
    } else {
      return 'Il y a ${difference.inDays} jours';
    }
  }

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseAuth.instance.currentUser == null
            ? null
            : FirebaseFirestore.instance
                .collection('notifications')
                .where('receiverId',
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          // Vérification des erreurs
          if (snapshot.hasError) {
            print("Erreur de snapshot: ${snapshot.error}");
            return Center(
                child: Text("Erreur de chargement des notifications"));
          }

          // Vérification si l'utilisateur est connecté
          if (FirebaseAuth.instance.currentUser == null) {
            return Center(
                child: Text(
                    "Veuillez vous connecter pour voir les notifications"));
          }

          // Vérification si les données sont disponibles
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Aucune notification',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var notification = snapshot.data!.docs[index];
              var notificationData =
                  notification.data() as Map<String, dynamic>;

              // Déterminer le type et le style de la notification
              String type = notificationData['logementId'] != null
                  ? _determineNotificationType(
                      notificationData['logementId'])
                  : 'default';
              var style = _getNotificationStyle(type);

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
                      color: style['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      style['icon'],
                      color: style['color'],
                      size: 28,
                    ),
                  ),
                  title: Text(
                    notificationData['title'],
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
                        notificationData['body'],
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: style['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notificationData['isRead'] ? 'Lu' : 'Nouveau',
                          style: TextStyle(
                            color: style['color'],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: notificationData['isRead']
                      ? Text(
                          _formatRelativeTime(notificationData['timestamp']),
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            String currentUserId =
                                FirebaseAuth.instance.currentUser!.uid;
                            String currentUserName = FirebaseAuth
                                    .instance.currentUser!.displayName ??
                                "Gestionnaire inconnu";

                            if (notificationData['logementId'] != null) {
                              try {
                                // Mettre à jour le logement dans Firestore
                                await FirebaseFirestore.instance
                                    .collection('logement')
                                    .doc(notificationData['logementId'])
                                    .update({
                                  'mode': 'Confier',
                                  'gestionnaireId': currentUserId,
                                  'gestionnaireNom': currentUserName,
                                });

                                // Marquer la notification comme lue
                                await FirebaseFirestore.instance
                                    .collection('notifications')
                                    .doc(notification.id)
                                    .update({'isRead': true});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Le logement a été confié avec succès !"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                print(
                                    "Erreur lors de l'acceptation du logement : $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "Erreur lors de l'acceptation du logement."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Aucun logement associé à cette notification."),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                          ),
                          child: Text(
                            "Accepter",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                  onTap: () {
                    // Marquer comme lu
                    FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(notification.id)
                        .update({'isRead': true});
                          // Redirection vers la page de notification
                  if (notificationData['logementId'] != null) {
                    String logementId = notificationData['logementId'];

                    Navigator.pushNamed(
                      context,
                      '/pages/pageNotification', 
                      arguments: logementId,
                    );
                  }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Méthode pour déterminer le type de notification
  String _determineNotificationType(String? entityId) {
    // Logique pour déterminer le type de notification
    // Par exemple, en fonction du préfixe de l'ID ou d'autres critères
    if (entityId == null) return 'default';

    if (entityId.startsWith('logement')) return 'visit';
    if (entityId.startsWith('payment')) return 'payment';
    if (entityId.startsWith('complaint')) return 'complaint';

    return 'default';
  }
}
