
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/pages/rooms/models/prayer_model.dart';
import 'package:dailydevotion/pages/rooms/models/room_comment_model.dart';
import 'package:flutter/material.dart';

class PrayerProvider extends ChangeNotifier {
  final List<PrayerModel> _prayers = [];
  bool _isLoading = false;
  bool _hasInitialized = false;

  List<PrayerModel> get prayers => List.unmodifiable(_prayers);
  bool get isLoading => _isLoading;
  bool get hasInitialized => _hasInitialized;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Add a prayer
  Future<void> addPrayer(PrayerModel prayer) async {
    try {
      // Optimistically add to local list first
      _prayers.insert(0, prayer);
      notifyListeners();

      // Then save to Firestore
      await FirebaseFirestore.instance
          .collection('prayers')
          .doc(prayer.id)
          .set(prayer.toMap());
    } catch (e) {
      // Remove from local list if Firestore save fails
      _prayers.removeWhere((p) => p.id == prayer.id);
      notifyListeners();

      debugPrint("Error adding prayer: $e");
      rethrow;
    }
  }

  /// Fetch prayers once
  Future<void> fetchPrayers() async {
    // Only show loading if we don't have any prayers yet
    if (_prayers.isEmpty) {
      _setLoading(true);
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('prayers')
          .orderBy('createdAt', descending: true)
          .get();

      _prayers
        ..clear()
        ..addAll(
          snapshot.docs.map((doc) {
            return PrayerModel.fromMap(doc.data(), id: doc.id);
          }),
        );

      _hasInitialized = true;
    } catch (e) {
      debugPrint("Error fetching prayers: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Real-time listener for prayers (optional - use if you want real-time updates)
  void listenToPrayers() {
    if (_prayers.isEmpty) {
      _setLoading(true);
    }

    FirebaseFirestore.instance
        .collection('prayers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _prayers
              ..clear()
              ..addAll(
                snapshot.docs.map((doc) {
                  return PrayerModel.fromMap(doc.data(), id: doc.id);
                }),
              );
            _hasInitialized = true;
            _setLoading(false);
          },
          onError: (error) {
            debugPrint("Error listening to prayers: $error");
            _setLoading(false);
          },
        );
  }

  /// Toggle like/unlike with optimistic updates
  Future<void> toggleLike(String prayerId, String currentUserId) async {
    try {
      final prayerIndex = _prayers.indexWhere((p) => p.id == prayerId);
      if (prayerIndex == -1) return;

      final prayer = _prayers[prayerIndex];
      final isLiked = prayer.likes.contains(currentUserId);

      // Optimistic update
      if (isLiked) {
        _prayers[prayerIndex] = prayer.copyWith(
          likes: List.from(prayer.likes)..remove(currentUserId),
          likesCount: prayer.likesCount - 1,
        );
      } else {
        _prayers[prayerIndex] = prayer.copyWith(
          likes: List.from(prayer.likes)..add(currentUserId),
          likesCount: prayer.likesCount + 1,
        );
      }
      notifyListeners();

      // Then update Firestore
      final prayerRef = FirebaseFirestore.instance
          .collection('prayers')
          .doc(prayerId);

      if (isLiked) {
        await prayerRef.update({
          'likes': FieldValue.arrayRemove([currentUserId]),
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        await prayerRef.update({
          'likes': FieldValue.arrayUnion([currentUserId]),
          'likesCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      debugPrint("Error toggling like: $e");
      // Revert optimistic update on error
      await fetchPrayers();
    }
  }

  Future<void> addComment({
    required String prayerId,
    required RoomCommentModel comment,
  }) async {
    try {
      final prayerIndex = _prayers.indexWhere((p) => p.id == prayerId);
      if (prayerIndex == -1) return;

      // Optimistic update: insert comment locally for instant UI feedback
      final updatedComments = List<RoomCommentModel>.from(
        _prayers[prayerIndex].comments,
      )..insert(0, comment);

      _prayers[prayerIndex] = _prayers[prayerIndex].copyWith(
        comments: updatedComments,
        commentsCount: _prayers[prayerIndex].commentsCount + 1,
      );
      notifyListeners();

      // Firestore references
      final prayerRef = FirebaseFirestore.instance
          .collection('prayers')
          .doc(prayerId);

      final commentsRef = prayerRef.collection('comments');

      // Add comment to subcollection
      await commentsRef.doc(comment.id).set(comment.toMap());

      // Increment commentsCount in parent document
      await prayerRef.update({'commentsCount': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('Error adding comment: $e');
      // Revert optimistic update on error
      await fetchPrayers();
    }
  }


  /// Clear all data (useful for logout)
  void clear() {
    _prayers.clear();
    _isLoading = false;
    _hasInitialized = false;
    notifyListeners();
  }
}
