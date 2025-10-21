import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/pages/rooms/models/testimonies_model.dart';
import 'package:dailydevotion/pages/rooms/models/room_comment_model.dart';
import 'package:flutter/material.dart';

class TestimoniesProvider extends ChangeNotifier {
  final List<TestimoniesModel> _testimonies = [];
  bool _isLoading = false;

  List<TestimoniesModel> get testimonies => List.unmodifiable(_testimonies);
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Add a testimony
  Future<void> addTestimony(TestimoniesModel testimony) async {
    _setLoading(true);
    try {
      await FirebaseFirestore.instance
          .collection('testimonies')
          .doc(testimony.id)
          .set(testimony.toMap());
      _testimonies.insert(0, testimony);
    } catch (e) {
      debugPrint("Error adding testimony: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch testimonies once
  Future<void> fetchTestimonies() async {
    _setLoading(true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('testimonies')
          .orderBy('createdAt', descending: true)
          .get();

      _testimonies
        ..clear()
        ..addAll(
          snapshot.docs.map((doc) {
            return TestimoniesModel.fromMap(doc.data(), id: doc.id);
          }),
        );
    } catch (e) {
      debugPrint("Error fetching testimonies: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Real-time listener for testimonies
  void listenToTestimonies() {
    _setLoading(true);
    FirebaseFirestore.instance
        .collection('testimonies')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _testimonies
            ..clear()
            ..addAll(
              snapshot.docs.map((doc) {
                return TestimoniesModel.fromMap(doc.data(), id: doc.id);
              }),
            );
          _setLoading(false);
        });
  }

  /// Toggle like/unlike
  Future<void> toggleLike(String testimonyId, String currentUserId) async {
    try {
      final index = _testimonies.indexWhere((t) => t.id == testimonyId);
      if (index == -1) return;

      final testimony = _testimonies[index];
      final isLiked = testimony.likes.contains(currentUserId);

      final testimonyRef = FirebaseFirestore.instance
          .collection('testimonies')
          .doc(testimonyId);

      if (isLiked) {
        await testimonyRef.update({
          'likes': FieldValue.arrayRemove([currentUserId]),
          'likesCount': FieldValue.increment(-1),
        });
        _testimonies[index] = testimony.copyWith(
          likes: List.from(testimony.likes)..remove(currentUserId),
          likesCount: testimony.likesCount - 1,
        );
      } else {
        await testimonyRef.update({
          'likes': FieldValue.arrayUnion([currentUserId]),
          'likesCount': FieldValue.increment(1),
        });
        _testimonies[index] = testimony.copyWith(
          likes: List.from(testimony.likes)..add(currentUserId),
          likesCount: testimony.likesCount + 1,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error toggling like: $e");
    }
  }

  Future<void> addComment({
    required String testimonyId,
    required RoomCommentModel comment,
  }) async {
    try {
      final commentsRef = FirebaseFirestore.instance
          .collection('testimonies')
          .doc(testimonyId)
          .collection('comments');

      final testimonyRef = FirebaseFirestore.instance
          .collection('testimonies')
          .doc(testimonyId);

      // Add comment to subcollection
      await commentsRef.doc(comment.id).set(comment.toMap());

      // Increment commentsCount in parent testimony document
      await testimonyRef.update({'commentsCount': FieldValue.increment(1)});

      // Optional: Update local state for UI
      final index = _testimonies.indexWhere((t) => t.id == testimonyId);
      if (index != -1) {
        final updatedComments = List<RoomCommentModel>.from(
          _testimonies[index].comments,
        )..insert(0, comment);

        _testimonies[index] = _testimonies[index].copyWith(
          comments: updatedComments,
          commentsCount: _testimonies[index].commentsCount + 1,
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }
}
