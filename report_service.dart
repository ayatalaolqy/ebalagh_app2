import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

/// خدمة إدارة البلاغات - CRUD operations
/// تتعامل مع collection "reports" في Firestore
class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference للـ collection
  CollectionReference get _reportsRef => _firestore.collection('reports');

  /// إنشاء بلاغ جديد (المواطن)
  Future<String?> createReport(ReportModel report) async {
    try {
      DocumentReference doc = await _reportsRef.add(report.toMap());
      return doc.id;
    } catch (e) {
      print('Error creating report: $e');
      return null;
    }
  }

  /// جلب بلاغات مستخدم معين (للمواطن لمتابعة بلاغاته)
  Stream<List<ReportModel>> getUserReports(String userId) {
    return _reportsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ReportModel.fromFirestore(doc))
                  .toList(),
        );
  }

  /// جلب بلاغات جهة معينة (للموظف)
  Stream<List<ReportModel>> getDepartmentReports(String departmentId) {
    return _reportsRef
        .where('departmentId', isEqualTo: departmentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ReportModel.fromFirestore(doc))
                  .toList(),
        );
  }

  /// جلب بلاغ محدد بالـ ID
  Future<ReportModel?> getReportById(String reportId) async {
    try {
      DocumentSnapshot doc = await _reportsRef.doc(reportId).get();
      if (doc.exists) {
        return ReportModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching report: $e');
      return null;
    }
  }

  /// تحديث حالة البلاغ (الموظف أو الإدارة)
  Future<bool> updateReportStatus({
    required String reportId,
    required String newStatus,
    String? assignedTo,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'status': newStatus,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (assignedTo != null) {
        updateData['assignedTo'] = assignedTo;
      }

      await _reportsRef.doc(reportId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating report: $e');
      return false;
    }
  }

  /// إحصائيات البلاغات (للإدارة)
  Future<Map<String, int>> getReportStatistics() async {
    try {
      QuerySnapshot snapshot = await _reportsRef.get();

      int newCount = 0;
      int processingCount = 0;
      int resolvedCount = 0;

      for (var doc in snapshot.docs) {
        String status = doc['status'] ?? 'new';
        switch (status) {
          case 'new':
            newCount++;
            break;
          case 'processing':
            processingCount++;
            break;
          case 'resolved':
            resolvedCount++;
            break;
        }
      }

      return {
        'new': newCount,
        'processing': processingCount,
        'resolved': resolvedCount,
        'total': snapshot.docs.length,
      };
    } catch (e) {
      return {};
    }
  }
}
