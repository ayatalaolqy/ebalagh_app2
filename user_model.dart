import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المستخدم - يتوافق مع كيان "المستخدم" في ERM
/// يمثل: مواطن، موظف جهة، أو إدارة محلية
class UserModel {
  final String? id; // user_id: المفتاح الرئيسي
  final String firstName; // الاسم الأول
  final String lastName; // الاسم الثاني
  final String phoneNumber; // رقم الهاتف (للتسجيل)
  final String userType; // نوع المستخدم: citizen, employee, admin
  final String? departmentId; // مرجع للجهة الخدمية (للموظفين فقط)
  final DateTime createdAt; // تاريخ الإنشاء

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.userType,
    this.departmentId,
    required this.createdAt,
  });

  /// تحويل من Firestore Document إلى UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      userType: data['userType'] ?? 'citizen',
      departmentId: data['departmentId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// تحويل من UserModel إلى Map للتخزين في Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'userType': userType,
      'departmentId': departmentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// الحصول على الاسم الكامل
  String get fullName => '$firstName $lastName';

  /// التحقق إذا كان المستخدم موظف
  bool get isEmployee => userType == 'employee';

  /// التحقق إذا كان المستخدم إدارة
  bool get isAdmin => userType == 'admin';

  /// التحقق إذا كان المستخدم مواطن
  bool get isCitizen => userType == 'citizen';
}
