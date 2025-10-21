
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomCommentModel {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final String text;
  final Timestamp createdAt;
  final List<RoomCommentModel> replies; // Nested replies (optional)

  RoomCommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.text,
    required this.createdAt,
    this.replies = const [],
  });

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'text': text,
      'createdAt': createdAt,
      'replies': replies.map((r) => r.toMap()).toList(),
    };
  }

  /// Create from Firestore map safely
  factory RoomCommentModel.fromMap(Map<String, dynamic> map) {
    return RoomCommentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'User',
      userImage: map['userImage'],
      text: map['text'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt']
          : Timestamp.fromDate(
              DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
                  DateTime.now(),
            ),
      replies: map['replies'] != null
          ? List<RoomCommentModel>.from(
              (map['replies'] as List).map(
                (x) => RoomCommentModel.fromMap(Map<String, dynamic>.from(x)),
              ),
            )
          : [],
    );
  }

  /// Optional: toJson alias
  Map<String, dynamic> toJson() => toMap();

  /// Immutable updates
  RoomCommentModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImage,
    String? text,
    Timestamp? createdAt,
    List<RoomCommentModel>? replies,
  }) {
    return RoomCommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }
}
