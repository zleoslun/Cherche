import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServiceProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }


  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    // required String professionalstatus,
    // required String bio,
  }) async {
    try {
      _setLoading(true);

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'name': name,
        // 'professional_status' : professionalstatus,
        // 'bio': bio,
        'created_at': FieldValue.serverTimestamp(),
        'role' : 'user',
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign up failed.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }



  Future<void> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Reset failed.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  //
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);

      final user = _auth.currentUser;
      if (user == null) throw Exception("No user logged in");

      // Reauthenticate the user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Password change failed.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    } finally {
      _setLoading(false);
    }
  }
}
