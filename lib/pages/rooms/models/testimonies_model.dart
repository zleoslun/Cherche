import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/pages/rooms/models/room_comment_model.dart';
import 'package:flutter/foundation.dart';

class TestimoniesModel {
  final String id; // Firestore auto-generated document ID
  final String uid; // User ID of the poster
  final String testimonyText;
  final DateTime createdAt;
  final List<String> likes;
  final int likesCount;
  final List<RoomCommentModel> comments;
  final int commentsCount;

  const TestimoniesModel({
    required this.id,
    required this.uid,
    required this.testimonyText,
    required this.createdAt,
    required this.likes,
    required this.likesCount,
    required this.comments,
    required this.commentsCount,
  });

  /// ✅ Create a TestimoniesModel directly from Firestore DocumentSnapshot
  factory TestimoniesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestimoniesModel(
      id: doc.id, // <-- auto-generated Firestore document ID
      uid: data['uid'] ?? '',
      testimonyText: data['testimonyText'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      likesCount: data['likesCount']?.toInt() ?? 0,
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((c) => RoomCommentModel.fromMap(c))
          .toList(),
      commentsCount: data['commentsCount']?.toInt() ?? 0,
    );
  }

  /// Convert TestimoniesModel to JSON / Map (for Firestore saving)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'testimonyText': testimonyText,
      'createdAt': createdAt,
      'likes': likes,
      'likesCount': likesCount,
      'comments': comments.map((c) => c.toMap()).toList(),
      'commentsCount': commentsCount,
    };
  }

  /// Regular fromMap (if not using Firestore doc directly)
  factory TestimoniesModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TestimoniesModel(
      id: id ?? map['id'] ?? '',
      uid: map['uid'] ?? '',
      testimonyText: map['testimonyText'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] ?? []),
      likesCount: map['likesCount']?.toInt() ?? 0,
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((c) => RoomCommentModel.fromMap(c))
          .toList(),
      commentsCount: map['commentsCount']?.toInt() ?? 0,
    );
  }

  TestimoniesModel copyWith({
    String? id,
    String? uid,
    String? testimonyText,
    DateTime? createdAt,
    List<String>? likes,
    int? likesCount,
    List<RoomCommentModel>? comments,
    int? commentsCount,
  }) {
    return TestimoniesModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      testimonyText: testimonyText ?? this.testimonyText,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  String toJson() => json.encode(toMap());

  factory TestimoniesModel.fromJson(String source) =>
      TestimoniesModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TestimoniesModel(id: $id, uid: $uid, testimonyText: $testimonyText, createdAt: $createdAt, likes: $likes, likesCount: $likesCount, commentsCount: $commentsCount, comments: $comments)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TestimoniesModel &&
        other.id == id &&
        other.uid == uid &&
        other.testimonyText == testimonyText &&
        other.createdAt == createdAt &&
        listEquals(other.likes, likes) &&
        listEquals(other.comments, comments) &&
        other.likesCount == likesCount &&
        other.commentsCount == commentsCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        testimonyText.hashCode ^
        createdAt.hashCode ^
        likes.hashCode ^
        likesCount.hashCode ^
        comments.hashCode ^
        commentsCount.hashCode;
  }
}
