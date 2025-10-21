import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PremiumProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool? hasValidSubscription;
  bool get isLoading => hasValidSubscription == null;

  PremiumProvider() {
    checkSubscriptionStatus();
  }

  Future<void> checkSubscriptionStatus() async {
    hasValidSubscription = await _isUserPremiumAndValid();
    notifyListeners();
  }

 Future<bool> _isUserPremiumAndValid() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      // 1️⃣ Check global premium flag
      final configDoc = await _firestore
          .collection('config')
          .doc('appSettings')
          .get();
      final premiumEnabled =
          configDoc['premiumEnabled'] ?? true; // default true

      if (!premiumEnabled) {
        // Premium globally disabled → all users can access
        return true;
      }

      // 2️⃣ Check user subscription
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();

      final isPremium = userData?['isPremium'] ?? false;
      final premiumActivatedAt = userData?['premiumActivatedAt']?.toDate();

      if (!isPremium || premiumActivatedAt == null) return false;

      final expiryDate = premiumActivatedAt.add(const Duration(days: 30));
      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }

  /// Call this after successful payment
  Future<void> refreshSubscription() async {
    await checkSubscriptionStatus();
  }
}
