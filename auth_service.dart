import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// خدمة المصادقة - إدارة تسجيل الدخول والمستخدمين
/// تتعامل مع Firebase Auth و Firestore
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  /// تسجيل مستخدم جديد (مواطن)
  Future<bool> registerCitizen({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // إنشاء حساب في Firebase Auth باستخدام رقم الهاتف + كلمة مرور
      // ملاحظة: Firebase Auth يدعم Phone Auth OTP، لكن هنا نستخدم Email/Password
      // مع تنسيق خاص: phone@ebalagh.ye

      String email = '${phoneNumber.replaceAll('+', '')}@ebalagh.ye';

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // إنشاء مستند المستخدم في Firestore
      UserModel newUser = UserModel(
        id: cred.user!.uid,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        userType: 'citizen',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(newUser.toMap());

      _currentUser = newUser;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthError(e));
      return false;
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل الدخول
  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      String email = '${phoneNumber.replaceAll('+', '')}@ebalagh.ye';

      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // جلب بيانات المستخدم من Firestore
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(cred.user!.uid).get();

      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        notifyListeners();
        return true;
      } else {
        _setError('المستخدم غير موجود في قاعدة البيانات');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_handleAuthError(e));
      return false;
    } catch (e) {
      _setError('حدث خطأ في الاتصال');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// جلب بيانات المستخدم الحالي
  Future<void> fetchCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        notifyListeners();
      }
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'المستخدم غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'رقم الهاتف مسجل مسبقاً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'صيغة البريد غير صحيحة';
      default:
        return 'خطأ في المصادقة: ${e.message}';
    }
  }
}
