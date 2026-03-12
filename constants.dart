/// الثوابت العامة للتطبيق
class AppConstants {
  // أسماء Collections في Firestore
  static const String usersCollection = 'users';
  static const String reportsCollection = 'reports';
  static const String departmentsCollection = 'departments';
  static const String reportImagesCollection = 'report_images';
  static const String notificationsCollection = 'notifications';

  // أنواع المستخدمين
  static const String userTypeCitizen = 'citizen';
  static const String userTypeEmployee = 'employee';
  static const String userTypeAdmin = 'admin';

  // حالات البلاغ
  static const String statusNew = 'new';
  static const String statusProcessing = 'processing';
  static const String statusResolved = 'resolved';
  static const String statusClosed = 'closed';

  // أنواع الخدمات
  static const List<Map<String, String>> serviceTypes = [
    {'id': 'electricity', 'name': 'كهرباء', 'icon': '⚡'},
    {'id': 'water', 'name': 'مياه', 'icon': '💧'},
    {'id': 'cleaning', 'name': 'نظافة', 'icon': '🧹'},
    {'id': 'roads', 'name': 'طرق وجسور', 'icon': '🛣️'},
    {'id': 'security', 'name': 'أمن', 'icon': '👮'},
    {'id': 'health', 'name': 'صحة', 'icon': '🏥'},
  ];
}
