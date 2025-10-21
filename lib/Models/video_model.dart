
import 'package:cloud_firestore/cloud_firestore.dart';

enum VideoStatus {
  draft, // Not yet scheduled
  scheduled, // Scheduled for future publication
  published, // Currently published
  failed, // Failed to publish
}

class VideoModel {
  final String id;
  final String uid;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final DateTime createdAt; // When the video was originally created/uploaded
  final DateTime? scheduledAt; // When the video should be published
  final DateTime? publishedAt; // When the video was actually published
  final VideoStatus status;
  final int likes;
  final int shares;
  final int views;
  final List<String> comments;
  final List<String> likedBy;
  final int commentCount;

  VideoModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.createdAt,
    this.scheduledAt,
    this.publishedAt,
    this.status = VideoStatus.published,
    this.likes = 0,
    this.shares = 0,
    this.views = 0,
    this.comments = const [],
    this.likedBy = const [],
    this.commentCount = 0,
  });

  factory VideoModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return VideoModel(
      id: docId ?? map['id'] ?? '',
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      scheduledAt: map['scheduledAt'] != null
          ? (map['scheduledAt'] as Timestamp).toDate()
          : null,
      publishedAt: map['publishedAt'] != null
          ? (map['publishedAt'] as Timestamp).toDate()
          : null,
      status: VideoStatus.values.firstWhere(
        (status) => status.name == (map['status'] ?? 'published'),
        orElse: () => VideoStatus.published,
      ),
      likes: map['likes'] ?? 0,
      shares: map['shares'] ?? 0,
      views: map['views'] ?? 0,
      comments: List<String>.from(
        (map['comments'] ?? []).map((comment) {
          if (comment is Map<String, dynamic>) {
            return comment['comment'] ?? '';
          }
          return comment.toString();
        }),
      ),
      likedBy: List<String>.from(map['likedBy'] ?? []),
      commentCount: map['commentCount'] ?? (map['comments']?.length ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'scheduledAt': scheduledAt != null
          ? Timestamp.fromDate(scheduledAt!)
          : null,
      'publishedAt': publishedAt != null
          ? Timestamp.fromDate(publishedAt!)
          : null,
      'status': status.name,
      'likes': likes,
      'shares': shares,
      'views': views,
      'comments': comments,
      'likedBy': likedBy,
      'commentCount': commentCount,
    };
  }

  VideoModel copyWith({
    String? id,
    String? uid,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? scheduledAt,
    DateTime? publishedAt,
    VideoStatus? status,
    int? likes,
    int? shares,
    int? views,
    List<String>? comments,
    List<String>? likedBy,
    int? commentCount,
  }) {
    return VideoModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      publishedAt: publishedAt ?? this.publishedAt,
      status: status ?? this.status,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      comments: comments ?? this.comments,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  // Helper methods for scheduling
  bool get isScheduled => status == VideoStatus.scheduled;
  bool get isPublished => status == VideoStatus.published;
  bool get isDraft => status == VideoStatus.draft;
  bool get isFailed => status == VideoStatus.failed;

  bool get shouldBePublished {
    if (scheduledAt == null || !isScheduled) return false;
    return DateTime.now().isAfter(scheduledAt!);
  }

  String get statusDisplayText {
    switch (status) {
      case VideoStatus.draft:
        return 'Draft';
      case VideoStatus.scheduled:
        return 'Scheduled';
      case VideoStatus.published:
        return 'Published';
      case VideoStatus.failed:
        return 'Failed';
    }
  }

  // Get the actual publish date - either publishedAt or createdAt for legacy videos
  DateTime get effectivePublishDate {
    if (publishedAt != null) {
      return publishedAt!;
    }
    // For videos published before publishedAt field was added
    if (isPublished) {
      return createdAt;
    }
    // For scheduled videos, return the scheduled time
    return scheduledAt ?? createdAt;
  }

  // Check if this video was published today
  bool get wasPublishedToday {
    if (!isPublished) return false;

    final publishDate = effectivePublishDate;
    final now = DateTime.now();
    return publishDate.year == now.year &&
        publishDate.month == now.month &&
        publishDate.day == now.day;
  }

  @override
  String toString() {
    return 'VideoModel(id: $id, uid: $uid, title: $title, status: $status, scheduledAt: $scheduledAt, publishedAt: $publishedAt, likes: $likes, shares: $shares, views: $views, commentCount: $commentCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoModel &&
        other.id == id &&
        other.uid == uid &&
        other.title == title &&
        other.description == description &&
        other.videoUrl == videoUrl &&
        other.thumbnailUrl == thumbnailUrl &&
        other.createdAt == createdAt &&
        other.scheduledAt == scheduledAt &&
        other.publishedAt == publishedAt &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uid.hashCode ^
        title.hashCode ^
        description.hashCode ^
        videoUrl.hashCode ^
        thumbnailUrl.hashCode ^
        createdAt.hashCode ^
        scheduledAt.hashCode ^
        publishedAt.hashCode ^
        status.hashCode;
  }
}
