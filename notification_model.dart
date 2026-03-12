import 'package:cloud_firestore/cloud_firestore.dart';

/// يمثل الإشعارات المرسلة للمستخدمين
class NotificationModel {
  final String? id; // notification_id: المفتاح الرئيسي
  final String userId; // مرجع للمستخدم المستهدف
  final String? reportId; // مرجع للبلاغ المرتبط (اختياري)
  final String title; // عنوان الإشعار
  final String body; // نص الإشعار
  final String type; // نوع الإشعار: status_update, new_report, comment
  final bool isRead; // هل تم قراءته؟
  final DateTime createdAt; // تاريخ الإنشاء

  NotificationModel({
    this.id,
    required this.userId,
    this.reportId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      reportId: data['reportId'],
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'reportId': reportId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
