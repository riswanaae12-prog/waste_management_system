import 'package:flutter/material.dart';
import '../models/notification.dart' as app_notification;
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<app_notification.Notification> _notifications = [];
  int _unreadCount = 0;
  bool _isInitialized = false;

  // Getters
  List<app_notification.Notification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isInitialized => _isInitialized;

  Future<void> initializeNotifications() async {
    if (_isInitialized) return;

    try {
      await _notificationService.initializeNotifications();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  Future<void> subscribeToUserTopic(String userId) async {
    try {
      await _notificationService.subscribeToTopic('user_$userId');
    } catch (e) {
      print('Failed to subscribe to user topic: $e');
    }
  }

  Future<void> unsubscribeFromUserTopic(String userId) async {
    try {
      await _notificationService.unsubscribeFromTopic('user_$userId');
    } catch (e) {
      print('Failed to unsubscribe from user topic: $e');
    }
  }

  Future<void> subscribeToDriverNotifications(String driverId) async {
    try {
      await _notificationService.subscribeToTopic('driver_$driverId');
      await _notificationService.subscribeToTopic('all_drivers');
    } catch (e) {
      print('Failed to subscribe to driver notifications: $e');
    }
  }

  void addNotification(app_notification.Notification notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();
    notifyListeners();
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  List<app_notification.Notification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }
}
