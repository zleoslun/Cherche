// lib/Models/video_model.dart
import 'package:dailydevotion/Models/user.dart';

class VideoModel1 {
  final String id;
  final String title;
  final String description;
  final String filePath;
  final UserModel uploader;
  final DateTime uploadedAt;

  int likes;
  int shares;
  List<String> comments; // simple list of comment texts for now

  VideoModel1({
    required this.id,
    required this.title,
    required this.description,
    required this.filePath,
    required this.uploader,
    required this.uploadedAt,
    this.likes = 0,
    this.shares = 0,
    List<String>? comments,
  }) : comments = comments ?? [];

  // methods for interactions
  void addLike() => likes++;
  void addShare() => shares++;
  void addComment(String comment) => comments.add(comment);

  // convert to/from map (useful for Firebase/REST API later)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'filePath': filePath,
      'uploader': uploader.toMap(),
      'uploadedAt': uploadedAt.toIso8601String(),
      'likes': likes,
      'shares': shares,
      'comments': comments,
    };
  }

  factory VideoModel1.fromMap(Map<String, dynamic> map) {
    return VideoModel1(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      filePath: map['filePath'],
      uploader: UserModel.fromMap(map['uploader']),
      uploadedAt: DateTime.parse(map['uploadedAt']),
      likes: map['likes'] ?? 0,
      shares: map['shares'] ?? 0,
      comments: List<String>.from(map['comments'] ?? []),
    );
  }
}
