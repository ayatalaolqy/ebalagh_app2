import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// خدمة التخزين - رفع الصور
/// تتعامل مع Firebase Storage و Firestore (report_images)
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  /// اختيار صورة من الكاميرا أو المعرض
  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85, // ضغط الصورة لتقليل الحجم
      );

      if (picked != null) {
        return File(picked.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// رفع صورة بلاغ إلى Storage وإنشاء سجل في Firestore
  Future<String?> uploadReportImage({
    required File imageFile,
    required String reportId,
  }) async {
    try {
      // إنشاء مسار فريد للصورة
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String storagePath = 'reports/$reportId/$fileName';

      // رفع الملف
      Reference ref = _storage.ref().child(storagePath);
      UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // إنشاء سجل في Firestore (collection: report_images)
      await _firestore.collection('report_images').add({
        'reportId': reportId,
        'imageUrl': downloadUrl,
        'storagePath': storagePath,
        'uploadedAt': Timestamp.fromDate(DateTime.now()),
      });

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// جلب صور بلاغ معين
  Future<List<Map<String, dynamic>>> getReportImages(String reportId) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('report_images')
              .where('reportId', isEqualTo: reportId)
              .orderBy('uploadedAt')
              .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// حذف صورة (للإدارة إذا لزم)
  Future<bool> deleteImage(String imageId, String storagePath) async {
    try {
      // حذف من Storage
      await _storage.ref().child(storagePath).delete();
      // حذف من Firestore
      await _firestore.collection('report_images').doc(imageId).delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
