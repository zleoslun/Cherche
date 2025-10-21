import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/Models/user.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final Map<String, UserModel> _userCache = {};
  UserModel? get user => _user;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _user = UserModel.fromMap(doc.data()!, docId: doc.id);
        notifyListeners();
      } else {
        debugPrint("⚠️ User document not found for uid: $uid");
      }
    } catch (e) {
      debugPrint("❌ Error fetching user: $e");
    }
  }

  //
  /// 🔹 Update user in Firestore + local state
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedUser.uid)
          .update(updatedUser.toMap());
      _user = updatedUser; // update local cache
      notifyListeners();
      debugPrint("✅ User updated successfully");
    } catch (e) {
      debugPrint("❌ Error updating user: $e");
      rethrow; // so UI can also catch errors if needed
    }
  }

  // Optional helper: check if user is loaded
  bool get isUserLoaded => _user != null;


  //


  Future<UserModel?> getUserById(String uid) async {
    if (_userCache.containsKey(uid)) {
      return _userCache[uid];
    }

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (doc.exists && doc.data() != null) {
      final user = UserModel.fromMap(doc.data()!);
      _userCache[uid] = user;
      return user;
    }
    return null;
  }
}
