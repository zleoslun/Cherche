



// 2
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? profilePic;
  final String? bio;
  final String? professionalStatus;
  final Timestamp createdAt;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profilePic,
    this.bio,
    this.professionalStatus,
    required this.createdAt,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'bio': bio,
      'professionalStatus': professionalStatus,
      'createdAt': createdAt,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return UserModel(
      uid: map['uid'] ?? docId ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'],
      bio: map['bio'],
      professionalStatus: map['professionalStatus'],
      createdAt:
          _parseTimestamp(map['createdAt'] ?? map['created_at']) ??
          Timestamp.now(),
      followersCount: (map['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (map['followingCount'] as num?)?.toInt() ?? 0,
    );
  }

  static Timestamp? _parseTimestamp(dynamic timestampData) {
    if (timestampData == null) return null;

    if (timestampData is Timestamp) {
      return timestampData;
    }

    if (timestampData is Map<String, dynamic>) {
      final seconds = timestampData['_seconds'] ?? timestampData['seconds'];
      final nanoseconds =
          timestampData['_nanoseconds'] ?? timestampData['nanoseconds'] ?? 0;

      if (seconds != null) {
        return Timestamp(seconds, nanoseconds);
      }
    }

    if (timestampData is String) {
      try {
        return Timestamp.fromDate(DateTime.parse(timestampData));
      } catch (e) {
        return null;
      }
    }

    if (timestampData is int) {
      return Timestamp.fromMillisecondsSinceEpoch(timestampData);
    }

    return null;
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profilePic,
    String? bio,
    String? professionalStatus,
    Timestamp? createdAt,
    int? followersCount,
    int? followingCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
      professionalStatus: professionalStatus ?? this.professionalStatus,
      createdAt: createdAt ?? this.createdAt,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  String toJson() {
    final map = toMap();
    map['createdAt'] = {
      '_seconds': createdAt.seconds,
      '_nanoseconds': createdAt.nanoseconds,
    };
    return json.encode(map);
  }

  factory UserModel.fromJson(String source) {
    return UserModel.fromMap(json.decode(source));
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, profilePic: $profilePic, bio: $bio, professionalStatus: $professionalStatus, createdAt: $createdAt, followersCount: $followersCount, followingCount: $followingCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.profilePic == profilePic &&
        other.bio == bio &&
        other.professionalStatus == professionalStatus &&
        other.createdAt == createdAt &&
        other.followersCount == followersCount &&
        other.followingCount == followingCount;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        profilePic.hashCode ^
        bio.hashCode ^
        professionalStatus.hashCode ^
        createdAt.hashCode ^
        followersCount.hashCode ^
        followingCount.hashCode;
  }
}
