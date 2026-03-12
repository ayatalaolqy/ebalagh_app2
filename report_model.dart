import 'package:cloud_firestore/cloud_firestore.dart';

/// يمثل بلاغ مواطن عن عطل في الخدمات العامة
class ReportModel {
  final String? id; // report_id: المفتاح الرئيسي
  final String userId; // مرجع للمستخدم (يقدم)
  final String departmentId; // مرجع للجهة الخدمية (يوجه إليها)
  final String title; // عنوان البلاغ
  final String description; // وصف البلاغ
  final String status; // حالة البلاغ: new, processing, resolved, closed
  final ReportLocation location; // الموقع الجغرافي (كيان فرعي)
  final DateTime createdAt; // تاريخ الإنشاء
  final DateTime? updatedAt; // تاريخ آخر تحديث
  final String? assignedTo; // مرجع للموظف المعالج
  final String? adminId; // مرجع للإدارة المشرفة

  ReportModel({
    this.id,
    required this.userId,
    required this.departmentId,
    required this.title,
    required this.description,
    this.status = 'new',
    required this.location,
    required this.createdAt,
    this.updatedAt,
    this.assignedTo,
    this.adminId,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      departmentId: data['departmentId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'new',
      location: ReportLocation.fromMap(data['location'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      assignedTo: data['assignedTo'],
      adminId: data['adminId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'departmentId': departmentId,
      'title': title,
      'description': description,
      'status': status,
      'location': location.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'assignedTo': assignedTo,
      'adminId': adminId,
    };
  }

  /// ترجمة حالة البلاغ للعربية
  String get statusArabic {
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
        return 'غير معروف';
    }
  }

  /// لون الحالة للعرض في UI
  int get statusColor {
    switch (status) {
      case 'new':
        return 0xFFFFA726; // برتقالي
      case 'processing':
        return 0xFF42A5F5; // أزرق
      case 'resolved':
        return 0xFF66BB6A; // أخضر
      case 'closed':
        return 0xFF757575; // رمادي
      default:
        return 0xFF000000;
    }
  }
}

/// نموذج الموقع الجغرافي - كيان فرعي من البلاغ
class ReportLocation {
  final double latitude; // خط العرض (GPS)
  final double longitude; // خط الطول (GPS)
  final String? city; // المدينة
  final String? district; // المديرية
  final String? street; // الشارع

  ReportLocation({
    required this.latitude,
    required this.longitude,
    this.city,
    this.district,
    this.street,
  });

  factory ReportLocation.fromMap(Map<String, dynamic> map) {
    return ReportLocation(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      city: map['city'],
      district: map['district'],
      street: map['street'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'district': district,
      'street': street,
    };
  }

  /// الحصول على العنوان الكامل كنص
  String get fullAddress {
    List<String> parts = [];
    if (city != null) parts.add(city!);
    if (district != null) parts.add(district!);
    if (street != null) parts.add(street!);
    return parts.isEmpty ? 'الموقع غير محدد' : parts.join('، ');
  }
}
