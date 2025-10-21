import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/pages/rooms/models/room_comment_model.dart';
import 'package:flutter/foundation.dart';

class PrayerModel {
  final String id; // Firestore auto-generated document ID
  final String uid; // User ID of the poster
  final String prayerText;
  final DateTime createdAt;
  final List<String> likes;
  final int likesCount;
  final List<RoomCommentModel> comments;
  final int commentsCount;

  const PrayerModel({
    required this.id,
    required this.uid,
    required this.prayerText,
    required this.createdAt,
    required this.likes,
    required this.likesCount,
    required this.comments,
    required this.commentsCount,
  });

  /// ✅ Create a PrayerModel directly from Firestore DocumentSnapshot
  factory PrayerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrayerModel(
      id: doc.id, // <-- auto-generated Firestore document ID
      uid: data['uid'] ?? '',
      prayerText: data['prayerText'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      likesCount: data['likesCount']?.toInt() ?? 0,
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((c) => RoomCommentModel.fromMap(c))
          .toList(),
      commentsCount: data['commentsCount']?.toInt() ?? 0,
    );
  }

  /// Convert PrayerModel to JSON / Map (for Firestore saving)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'prayerText': prayerText,
      'createdAt': createdAt,
      'likes': likes,
      'likesCount': likesCount,
      'comments': comments.map((c) => c.toMap()).toList(),
      'commentsCount': commentsCount,
    };
  }

  /// Regular fromMap (if not using Firestore doc directly)
  factory PrayerModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return PrayerModel(
      id: id ?? map['id'] ?? '',
      uid: map['uid'] ?? '',
      prayerText: map['prayerText'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] ?? []),
      likesCount: map['likesCount']?.toInt() ?? 0,
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((c) => RoomCommentModel.fromMap(c))
          .toList(),
      commentsCount: map['commentsCount']?.toInt() ?? 0,
    );
  }

  PrayerModel copyWith({
    String? id,
    String? uid,
    String? prayerText,
    DateTime? createdAt,
    List<String>? likes,
    int? likesCount,
    List<RoomCommentModel>? comments,
    int? commentsCount,
  }) {
    return PrayerModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      prayerText: prayerText ?? this.prayerText,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  String toJson() => json.encode(toMap());

  factory PrayerModel.fromJson(String source) =>
      PrayerModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PrayerModel(id: $id, uid: $uid, prayerText: $prayerText, createdAt: $createdAt, likes: $likes, likesCount: $likesCount, commentsCount: $commentsCount,comments: $comments)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PrayerModel &&
        other.id == id &&
        other.uid == uid &&
        other.prayerText == prayerText &&
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
        prayerText.hashCode ^
        createdAt.hashCode ^
        likes.hashCode ^
        likesCount.hashCode ^
        comments.hashCode ^
        commentsCount.hashCode;
  }
}
