import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification.dart' as app_notification;

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeNotifications() async {
    try {
      // Request permissions
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        _handleMessageClick(message);
      });
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  void _handleMessageClick(RemoteMessage message) {
    // Handle notification tap
    final data = message.data;
    print('Handling message click with data: $data');
  }

  Future<String?> getDeviceToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Failed to get device token: $e');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Failed to subscribe to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Failed to unsubscribe from topic: $e');
    }
  }

  void showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    // This would typically use a local notification package
    print('Local notification: $title - $body');
  }

  app_notification.Notification parseNotification(RemoteMessage message) {
    return app_notification.Notification(
      id: message.messageId ?? '',
      userId: message.data['userId'] ?? '',
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? 'system',
      data: message.data,
      createdAt: DateTime.now(),
      relatedBinId: message.data['binId'],
    );
  }
}
