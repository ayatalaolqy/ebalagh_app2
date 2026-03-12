import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String? id; // department_id: المفتاح الرئيسي
  final String name; // اسم الجهة
  final String serviceType; // نوع الخدمة (electricity, water, etc.)
  final ContactInfo contactInfo; // بيانات التواصل (كيان فرعي)
  final String? address; // العنوان

  DepartmentModel({
    this.id,
    required this.name,
    required this.serviceType,
    required this.contactInfo,
    this.address,
  });

  factory DepartmentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return DepartmentModel(
      id: doc.id,
      name: data['name'] ?? '',
      serviceType: data['serviceType'] ?? '',
      contactInfo: ContactInfo.fromMap(data['contactInfo'] ?? {}),
      address: data['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'serviceType': serviceType,
      'contactInfo': contactInfo.toMap(),
      'address': address,
    };
  }
}

/// بيانات التواصل - كيان فرعي
class ContactInfo {
  final String? phone; // هاتف
  final String? email; // بريد

  ContactInfo({this.phone, this.email});

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      phone: map['phone'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'email': email,
    };
  }
}
