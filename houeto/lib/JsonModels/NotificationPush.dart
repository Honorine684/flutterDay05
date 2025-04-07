import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:houeto/Services/Firebase/push_notifications.dart';

class NotificationModel {
  final String id;
  final String? senderId;
  final String receiverId;
  final String title;
  final String body;
  final String? logementId; 
  final Timestamp timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.title,
    required this.body,
    this.logementId,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'title': title,
      'body': body,
      'logementId': logementId,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      title: map['title'],
      body: map['body'],
      logementId: map['Id'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] ?? false,
    );
  }
}



class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PushNotification _pushNotification = PushNotification();

  // Envoyer une notification (BD + Push)
  Future<void> sendNotification({
    required String receiverId,
    required String title,
    required String body,
    String? logementId,
  }) async {
    try {
      // Récupérer l'ID de l'utilisateur actuel
      String? currentUserId = _auth.currentUser?.uid;

      // Créer la notification dans Firestore
      DocumentReference notificationRef = _firestore.collection('notifications').doc();

      NotificationModel notification = NotificationModel(
        id: notificationRef.id,
        senderId: currentUserId,
        receiverId: receiverId,
        title: title,
        body: body,
        logementId: logementId,
        timestamp: Timestamp.now(),
      );

      await notificationRef.set(notification.toMap());

      // Envoyer une notification push
      await _pushNotification.sendNotificationWithPayload(
        receiverId: receiverId,
        title: title,
        body: body,
        payload: {"logementId": logementId ?? ""},
      );

      print("Notification enregistrée et envoyée avec succès !");
    } catch (e) {
      print("Erreur lors de l'envoi de la notification : $e");
    }
  }
}
