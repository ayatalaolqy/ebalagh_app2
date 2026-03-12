import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

/// خدمة الإشعارات - إدارة إرسال واستقبال الإشعارات
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _notificationsRef =>
      _firestore.collection('notifications');

  /// إنشاء إشعار جديد
  Future<String?> createNotification(NotificationModel notification) async {
    try {
      DocumentReference doc = await _notificationsRef.add(notification.toMap());
      return doc.id;
    } catch (e) {
      print('Error creating notification: $e');
      return null;
    }
  }

  /// جلب إشعارات مستخدم معين (Real-time)
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// عدد الإشعارات غير المقروءة
  Stream<int> getUnreadCount(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// تحديث حالة القراءة
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({'isRead': true});
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// إرسال إشعار عند تغيير حالة البلاغ
  Future<void> sendStatusUpdateNotification({
    required String userId,
    required String reportId,
    required String newStatus,
  }) async {
    String statusText = _getStatusText(newStatus);

    NotificationModel notification = NotificationModel(
      userId: userId,
      reportId: reportId,
      title: 'تحديث حالة البلاغ',
      body: 'تم تحديث حالة بلاغك إلى: $statusText',
      type: 'status_update',
      createdAt: DateTime.now(),
    );

    await createNotification(notification);
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'new':
        return 'جديد';
      case 'processing':
        return 'قيد المعالجة';
      case 'resolved':
        return 'تم الحل';
      case 'closed':
        return 'مغلق';
      default:
        return status;
    }
  }
}
