import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationVisite {
  final String id;
  final String senderId;
  final String receiverId;
  final String title;
  final String body;
  final String? visiteId; 
  final Timestamp timestamp;
  bool isRead;

  NotificationVisite({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.title,
    required this.body,
    this.visiteId,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'title': title,
      'body': body,
      'visiteId':visiteId,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory NotificationVisite.fromMap(String id, Map<String, dynamic> map) {
    return NotificationVisite(
      id: id,
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      title: map['title'],
      body: map['body'],
      visiteId: map['visiteId'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] ?? false,
    );
  }
}



class NotificationServiceVisite {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
 // final PushNotification _pushNotification = PushNotification();

  // Envoyer une notification (BD + Push)
  Future<void> sendNotificationVisite({
    required String receiverId,
    required String title,
    required String body,
    String? visiteId,
  }) async {
    try {
      // Récupérer l'ID de l'utilisateur actuel
      String? currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception("Utilisateur non connecté");
      }

      // Créer la notification dans Firestore
      DocumentReference notificationRef = _firestore.collection('visiteNotification').doc();

      NotificationVisite notification = NotificationVisite(
        id: notificationRef.id,
        senderId: currentUserId,
        receiverId: receiverId,
        title: title,
        body: body,
        visiteId: visiteId,
        timestamp: Timestamp.now(),
      );

      await notificationRef.set(notification.toMap());

      // Envoyer une notification push
     /* await _pushNotification.sendNotificationWithPayload(
        receiverId: receiverId,
        title: title,
        body: body,
        payload: {"logementId": logementId ?? ""},
      );*/

      print("Notification enregistrée et envoyée avec succès !");
    } catch (e) {
      print("Erreur lors de l'envoi de la notification : $e");
    }
  }
}
