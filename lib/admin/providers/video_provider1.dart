import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/Models/video_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoProvider1 extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Single slot for video upload
  File? selectedVideo;
  Uint8List? videoThumbnail;

  List<VideoModel> _userVideos = [];
  List<VideoModel> get userVideos => _userVideos;

  // For normal Users - only published videos
  List<VideoModel> _allVideos = [];
  List<VideoModel> get allVideos => _allVideos;

  // Scheduled videos
  List<VideoModel> _scheduledVideos = [];
  List<VideoModel> get scheduledVideos => _scheduledVideos;

  // Draft videos
  List<VideoModel> _draftVideos = [];
  List<VideoModel> get draftVideos => _draftVideos;

  // Streak variables
  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  // Single controllers for the single slot
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  // Single upload states
  double uploadProgress = 0.0;
  bool isUploading = false;
  int totalUploadsToday = 0;

  // Scheduling states
  DateTime? selectedScheduleDateTime;
  bool isScheduleMode = false;
  DateTime get utcNow => DateTime.now().toUtc();



  // Valid subscription or not
  bool _hasValidSubscription = false;
  bool get hasValidSubscription => _hasValidSubscription;


  //_______________________________________//
  // SCHEDULING METHODS

  /// Set scheduling mode
  void setScheduleMode(bool enabled) {
    isScheduleMode = enabled;
    if (!enabled) {
      selectedScheduleDateTime = null;
    }
    notifyListeners();
  }

  /// Set schedule date and time
  void setScheduleDateTime(DateTime dateTime) {
    selectedScheduleDateTime = dateTime;
    notifyListeners();
  }

  /// Clear schedule
  void clearSchedule() {
    selectedScheduleDateTime = null;
    isScheduleMode = false;
    notifyListeners();
  }

  /// Get minimum scheduleable time (15 minutes from now)
  DateTime get minimumScheduleTime => utcNow.add(const Duration(minutes: 2));

  /// Check if a datetime is valid for scheduling
  bool isValidScheduleTime(DateTime dateTime) {
    return dateTime.isAfter(minimumScheduleTime);
  }

  /// Publish scheduled videos that are due
  Future<void> publishDueVideos() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final now = utcNow; // Use UTC time
      final snapshot = await _firestore
          .collection('videos')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: VideoStatus.scheduled.name)
          .where('scheduledAt', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      for (var doc in snapshot.docs) {
        // await doc.reference.update({
        //   'status': VideoStatus.published.name,
        //   'createdAt': Timestamp.now(), // Update to actual publish time
        // });
        await doc.reference.update({
          'status': VideoStatus.published.name,
          'publishedAt': Timestamp.now(), // Add this field instead
          // Don't update createdAt - keep original creation time
        });
      }

      // Refresh videos after publishing
      await fetchUserVideos();
      await fetchScheduledVideos();
      await fetchAllVideos();
    } catch (e) {
      debugPrint('Error publishing due videos: $e');
    }
  }

  /// Fetch scheduled videos
  Future<void> fetchScheduledVideos() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await _firestore
          .collection('videos')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: VideoStatus.scheduled.name)
          .orderBy('scheduledAt', descending: false)
          .get();

      _scheduledVideos = snapshot.docs
          .map((doc) => VideoModel.fromMap(doc.data(), docId: doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching scheduled videos: $e');
    }
  }

  /// Fetch draft videos
  Future<void> fetchDraftVideos() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await _firestore
          .collection('videos')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: VideoStatus.draft.name)
          .orderBy('createdAt', descending: true)
          .get();

      _draftVideos = snapshot.docs
          .map((doc) => VideoModel.fromMap(doc.data(), docId: doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching draft videos: $e');
    }
  }

  /// Cancel scheduled video and move to draft
  Future<void> cancelScheduledVideo(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).update({
        'status': VideoStatus.draft.name,
        'scheduledAt': null,
      });

      await fetchUserVideos();
      await fetchScheduledVideos();
      await fetchDraftVideos();
    } catch (e) {
      debugPrint('Error canceling scheduled video: $e');
    }
  }

  /// Reschedule a video
  Future<void> rescheduleVideo(String videoId, DateTime newDateTime) async {
    try {
      if (!isValidScheduleTime(newDateTime)) {
        throw Exception('Invalid schedule time');
      }

      await _firestore.collection('videos').doc(videoId).update({
        'scheduledAt': Timestamp.fromDate(newDateTime),
        'status': VideoStatus.scheduled.name,
      });

      await fetchUserVideos();
      await fetchScheduledVideos();
      await fetchDraftVideos();
    } catch (e) {
      debugPrint('Error rescheduling video: $e');
      rethrow;
    }
  }

  //
  Future<void> publishVideoImmediately(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).update({
        'status': VideoStatus.published.name,
        'publishedAt': Timestamp.now(), // Use publishedAt instead of createdAt
        'scheduledAt': null,
      });

      // ... rest of the method remains the same
    } catch (e) {
      debugPrint('Error publishing video immediately: $e');
    }
  }

  //

  //_______________________________________//
  // EXISTING METHODS (updated to handle scheduling)

  /// Fetch user streak from Firestore
  Future<void> fetchUserStreak() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _currentStreak = 0;
        notifyListeners();
        return;
      }

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _currentStreak = data['currentStreak'] ?? 0;
        await _calculateAndUpdateStreak(uid);
      } else {
        _currentStreak = 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user streak: $e');
      _currentStreak = 0;
      notifyListeners();
    }
  }

  /// Calculate streak based on upload history
  Future<void> _calculateAndUpdateStreak(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final lastUploadDate = userData['lastUploadDate'] as Timestamp?;
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      if (lastUploadDate == null) {
        _currentStreak = 0;
        notifyListeners();
        return;
      }

      final lastUpload = lastUploadDate.toDate();
      final lastUploadStart = DateTime(
        lastUpload.year,
        lastUpload.month,
        lastUpload.day,
      );
      final daysDifference = todayStart.difference(lastUploadStart).inDays;

      final hasUploadedToday = await _checkTodayUpload(uid);

      if (daysDifference == 0) {
        if (hasUploadedToday && _currentStreak == 0) {
          _currentStreak = 1;
        }
      } else if (daysDifference == 1) {
        if (hasUploadedToday) {
          _currentStreak = userData['currentStreak'] ?? 1;
        } else {
          _currentStreak = 0;
        }
      } else if (daysDifference > 1) {
        if (hasUploadedToday) {
          _currentStreak = 1;
        } else {
          _currentStreak = 0;
        }
      }

      await _firestore.collection('users').doc(uid).update({
        'currentStreak': _currentStreak,
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error calculating streak: $e');
    }
  }

  Future<bool> _checkTodayUpload(String uid) async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day).toUtc();
      final todayEnd = DateTime(
        today.year,
        today.month,
        today.day,
        23,
        59,
        59,
      ).toUtc();

      final snapshot = await _firestore
          .collection('videos')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: VideoStatus.published.name)
          .where(
            'publishedAt', // Use publishedAt instead of createdAt
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
          )
          .where(
            'publishedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(todayEnd),
          )
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking today upload: $e');
      return false;
    }
  }

  /// Update streak when video is uploaded (only for published videos)
  Future<void> _updateStreakOnUpload(String uid) async {
    try {
      final today = DateTime.now();
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final lastUploadDate = userData['lastUploadDate'] as Timestamp?;
        final lastStreak = userData['currentStreak'] ?? 0;

        if (lastUploadDate == null) {
          _currentStreak = 1;
        } else {
          final lastUpload = lastUploadDate.toDate();
          final lastUploadStart = DateTime(
            lastUpload.year,
            lastUpload.month,
            lastUpload.day,
          );
          final todayStart = DateTime(today.year, today.month, today.day);
          final daysDifference = todayStart.difference(lastUploadStart).inDays;

          if (daysDifference == 0) {
            _currentStreak = lastStreak > 0 ? lastStreak : 1;
          } else if (daysDifference == 1) {
            _currentStreak = lastStreak + 1;
          } else {
            _currentStreak = 1;
          }
        }

        await _firestore.collection('users').doc(uid).update({
          'currentStreak': _currentStreak,
          'lastUploadDate': Timestamp.fromDate(today),
        });

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating streak: $e');
    }
  }

  /// Initialize all data
  Future<void> initializeStreak() async {
    await fetchUserStreak();
    await fetchTodayUploadsCount();
    await fetchScheduledVideos();
    await fetchDraftVideos();
    await publishDueVideos(); // Auto-publish due videos
  }

  /// Fetch today's upload count (only published videos)
  Future<void> fetchTodayUploadsCount() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day).toUtc();
      final todayEnd = DateTime(
        today.year,
        today.month,
        today.day,
        23,
        59,
        59,
      ).toUtc();

      final snapshot = await _firestore
          .collection('videos')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: VideoStatus.published.name)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(todayEnd))
          .get();

      totalUploadsToday = snapshot.docs.length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching today uploads count: $e');
      totalUploadsToday = 0;
      notifyListeners();
    }
  }

  // Loading Dialogue
  /// Show a blocking loading dialog
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Video conversion for iOS
  Future<File?> _convertToMp4(File originalFile) async {
    try {
      final info = await VideoCompress.compressVideo(
        originalFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      return info?.file;
    } catch (e) {
      debugPrint("Video conversion failed: $e");
      return null;
    }
  }

  /// Pick video for single slot
  Future<void> pickVideo(BuildContext context) async {
    if (isUploading) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      final fileSize = result.files.single.size;
      const maxSizeInBytes = 1024 * 1024 * 1024;

      if (fileSize > maxSizeInBytes) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please select a video smaller than 1 GB"),
            ),
          );
        }
        return;
      }

      File videoFile = File(filePath);

      // iOS MOV → MP4 conversion
      if (Platform.isIOS && path.extension(filePath).toLowerCase() == '.mov') {
        _showLoadingDialog(context, "Processing video, please wait...");
        final converted = await _convertToMp4(videoFile);
        _hideLoadingDialog(context);
        if (converted != null) {
          videoFile = converted;
        }
      }

      Uint8List? thumb = await VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 200,
        quality: 75,
      );

      selectedVideo = videoFile;
      videoThumbnail = thumb;
      notifyListeners();
    }
  }

  /// Upload video with scheduling support
  Future<void> uploadVideo(String uid, BuildContext context) async {
    if (selectedVideo == null || isUploading) return;

    // Validate schedule if in schedule mode
    if (isScheduleMode) {
      if (selectedScheduleDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a schedule time"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (!isValidScheduleTime(selectedScheduleDateTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Schedule time must be at least 2 minutes from now"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    isUploading = true;
    uploadProgress = 0.0;
    notifyListeners();

    try {
      final timestamp = utcNow.millisecondsSinceEpoch;

      // Upload video
      final videoFileName = '$timestamp${path.basename(selectedVideo!.path)}';
      final videoRef = _storage.ref('videos/$uid/$videoFileName');
      final videoUploadTask = videoRef.putFile(selectedVideo!);

      videoUploadTask.snapshotEvents.listen((event) {
        uploadProgress = event.bytesTransferred / event.totalBytes * 0.8;
        notifyListeners();
      });

      await videoUploadTask;
      final videoUrl = await videoRef.getDownloadURL();

      // Upload thumbnail
      String thumbnailUrl = '';
      if (videoThumbnail != null) {
        final thumbFileName =
            '${timestamp}_thumb_${path.basename(selectedVideo!.path)}.jpg';
        final thumbRef = _storage.ref('videos/$uid/$thumbFileName');
        final thumbUploadTask = thumbRef.putData(videoThumbnail!);

        thumbUploadTask.snapshotEvents.listen((event) {
          uploadProgress =
              0.8 + (event.bytesTransferred / event.totalBytes * 0.2);
          notifyListeners();
        });

        await thumbUploadTask;
        thumbnailUrl = await thumbRef.getDownloadURL();
      }

      // Determine status and dates based on schedule mode
      // Determine status and dates based on schedule mode
      VideoStatus status;
      DateTime createdAt;
      DateTime? scheduledAt;
      DateTime? publishedAt;

      if (isScheduleMode && selectedScheduleDateTime != null) {
        status = VideoStatus.scheduled;
        createdAt = DateTime.now(); // When it was uploaded
        scheduledAt = selectedScheduleDateTime;
        publishedAt = null; // Will be set when actually published
      } else {
        status = VideoStatus.published;
        createdAt = DateTime.now();
        scheduledAt = null;
        publishedAt =
            DateTime.now(); // Set publishedAt for immediate publishing
      }

      // Save to Firestore
      final video = VideoModel(
        id: '',
        uid: uid,
        title: titleController.text.trim(),
        description: descController.text.trim(),
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        createdAt: utcNow, // Use UTC time
        publishedAt: isScheduleMode ? null : utcNow, // Use UTC time
        scheduledAt: scheduledAt,
        status: status,
        likes: 0,
        shares: 0,
        views: 0,
        comments: [],
        likedBy: [],
        commentCount: 0,
      );

      final docRef = await _firestore.collection('videos').add(video.toMap());
      await docRef.update({'id': docRef.id});

      // Update streak only if published immediately
      if (status == VideoStatus.published) {
        await _updateStreakOnUpload(uid);
        totalUploadsToday++;
      }

      // Refresh all video lists
      await fetchUserVideos();
      await fetchScheduledVideos();
      await fetchDraftVideos();
      if (status == VideoStatus.published) {
        await fetchAllVideos();
      }

      String message;
      if (status == VideoStatus.scheduled) {
        message = 'Video scheduled for ${_formatDateTime(scheduledAt!)}';
      } else {
        message =
            'Video uploaded successfully! Today\'s uploads: $totalUploadsToday | Streak: $_currentStreak days';
      }

      if (context.mounted) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: status == VideoStatus.scheduled
                ? 'Video Scheduled 📅'
                : 'Upload Successful 🎉',
            message: message,
            contentType: ContentType.success,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }

      // Clear the slot after successful upload
      _clearUploadSlot();
    } catch (e) {
      if (context.mounted) {
        final errorSnackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Upload Failed ❌',
            message: 'Error uploading video: $e',
            contentType: ContentType.failure,
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(errorSnackBar);
      }
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  /// Format datetime for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Clear the upload slot after successful upload
  void _clearUploadSlot() {
    selectedVideo = null;
    videoThumbnail = null;
    titleController.clear();
    descController.clear();
    uploadProgress = 0.0;
    isScheduleMode = false;
    selectedScheduleDateTime = null;
    notifyListeners();
  }

  /// Reset the slot manually (if needed)
  void resetUploadSlot() {
    if (!isUploading) {
      _clearUploadSlot();
    }
  }

  // IS Premium and Valid
  Future<bool> isUserPremiumAndValid() async {
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

  //
  Future<void> updatePremiumStatus() async {
    _hasValidSubscription = await isUserPremiumAndValid();
    notifyListeners();
  }


  /// Fetch user videos (all statuses)
  Future<void> fetchUserVideos() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final snapshot = await _firestore
          .collection('videos')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      _userVideos = snapshot.docs
          .map((doc) => VideoModel.fromMap(doc.data(), docId: doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user videos: $e');
    }
  }

  /// Fetch for normal Users (only published videos)
  Future<void> fetchAllVideos() async {
    try {
      //
      await updatePremiumStatus();

      if (!hasValidSubscription) {
        _allVideos = [];
        notifyListeners();
        return;
      }
      final snapshot = await _firestore
          .collection('videos')
          .where('status', isEqualTo: VideoStatus.published.name)
          .orderBy('createdAt', descending: true)
          .get();

      _allVideos = snapshot.docs
          .map((doc) => VideoModel.fromMap(doc.data(), docId: doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching all videos: $e');
    }
  }

  // Updated code with Logic of Limit and Batch

  /// Enhanced interaction methods with real-time updates
  Future<void> likeVideo(String videoId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final docRef = _firestore.collection('videos').doc(videoId);
      final doc = await docRef.get();

      if (doc.exists) {
        final data = doc.data()!;
        final likedBy = List<String>.from(data['likedBy'] ?? []);

        if (likedBy.contains(uid)) {
          // User already liked, so unlike
          await docRef.update({
            'likes': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([uid]),
          });

          // Update local data
          _updateLocalVideoLikes(videoId, -1, uid, false);
        } else {
          // User hasn't liked, so like
          await docRef.update({
            'likes': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([uid]),
          });

          // Update local data
          _updateLocalVideoLikes(videoId, 1, uid, true);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error liking video: $e");
    }
  }

  Future<void> commentOnVideo(String videoId, String comment) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userName = userDoc.exists
          ? userDoc.data()!['name'] ?? 'User'
          : 'User';
      final userProfilePic = userDoc.exists
          ? userDoc.data()!['profilePic']
          : null;

      final commentData = {
        'uid': uid,
        'userName': userName,
        'userProfilePic': userProfilePic,
        'comment': comment,
        'timestamp': Timestamp.now(),
        'likes': 0,
        'likedBy': [],
      };

      // Save comment in subcollection
      final videoRef = _firestore.collection('videos').doc(videoId);
      await videoRef.collection('comments').add(commentData);

      // Increment comment count on video doc
      await videoRef.update({'commentCount': FieldValue.increment(1)});

      // Update local cache/UI
      _updateLocalVideoComments(videoId, commentData);
      notifyListeners();
    } catch (e) {
      debugPrint("Error commenting: $e");
    }
  }

  /// Method to get user's like status for a video
  Future<bool> isVideoLikedByUser(String videoId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      final doc = await _firestore.collection('videos').doc(videoId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final likedBy = List<String>.from(data['likedBy'] ?? []);
        return likedBy.contains(uid);
      }
      return false;
    } catch (e) {
      debugPrint("Error checking like status: $e");
      return false;
    }
  }

  /// Method to increment view count

  /// Helper methods to update local data
  void _updateLocalVideoLikes(
    String videoId,
    int increment,
    String userId,
    bool isLiked,
  ) {
    // Update in allVideos list
    for (int i = 0; i < _allVideos.length; i++) {
      if (_allVideos[i].id == videoId) {
        final updatedVideo = _allVideos[i].copyWith(
          likes: _allVideos[i].likes + increment,
        );
        _allVideos[i] = updatedVideo;
        break;
      }
    }

    // Update in userVideos list if applicable
    for (int i = 0; i < _userVideos.length; i++) {
      if (_userVideos[i].id == videoId) {
        final updatedVideo = _userVideos[i].copyWith(
          likes: _userVideos[i].likes + increment,
        );
        _userVideos[i] = updatedVideo;
        break;
      }
    }
  }

  void _updateLocalVideoComments(
    String videoId,
    Map<String, dynamic> commentData,
  ) {
    // Update in allVideos list
    for (int i = 0; i < _allVideos.length; i++) {
      if (_allVideos[i].id == videoId) {
        final updatedComments = List<String>.from(_allVideos[i].comments);
        updatedComments.add(commentData['comment']);
        final updatedVideo = _allVideos[i].copyWith(comments: updatedComments);
        _allVideos[i] = updatedVideo;
        break;
      }
    }

    // Update in userVideos list if applicable
    for (int i = 0; i < _userVideos.length; i++) {
      if (_userVideos[i].id == videoId) {
        final updatedComments = List<String>.from(_userVideos[i].comments);
        updatedComments.add(commentData['comment']);
        final updatedVideo = _userVideos[i].copyWith(comments: updatedComments);
        _userVideos[i] = updatedVideo;
        break;
      }
    }
  }

  //
  Future<Map<String, dynamic>> getVideoAnalytics(String videoId) async {
    try {
      final videoRef = _firestore.collection('videos').doc(videoId);

      // Get video doc
      final doc = await videoRef.get();
      if (!doc.exists) return {};

      final data = doc.data()!;

      // Get ALL comments (⚠️ careful with very large lists)
      final commentsSnapshot = await videoRef
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      final comments = commentsSnapshot.docs.map((c) => c.data()).toList();

      return {
        'likes': data['likes'] ?? 0,
        'shares': data['shares'] ?? 0,
        'views': data['views'] ?? 0,
        'commentCount': data['commentCount'] ?? 0,
        'likedBy': List<String>.from(data['likedBy'] ?? []),
        'comments': comments,
      };
    } catch (e) {
      debugPrint("Error getting analytics: $e");
      return {};
    }
  }

  Future<void> deleteVideo(
    String uid,
    String videoId,
    String videoUrl,
    String? thumbnailUrl,
  ) async {
    try {
      // Delete video from storage
      await _storage.refFromURL(videoUrl).delete();

      // Delete thumbnail if exists
      if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
        await _storage.refFromURL(thumbnailUrl).delete();
      }

      // Delete Firestore document
      await _firestore.collection('videos').doc(videoId).delete();

      // Remove from all local lists
      _userVideos.removeWhere((video) => video.id == videoId);
      _allVideos.removeWhere((video) => video.id == videoId);
      _scheduledVideos.removeWhere((video) => video.id == videoId);
      _draftVideos.removeWhere((video) => video.id == videoId);

      // Check if deleted video was uploaded today and update count
      VideoModel? deletedVideo;
      for (var video in _userVideos) {
        if (video.id == videoId) {
          deletedVideo = video;
          break;
        }
      }

      if (deletedVideo != null && deletedVideo.isPublished) {
        final today = DateTime.now();
        final videoDate = deletedVideo.createdAt;
        final wasUploadedToday =
            videoDate.year == today.year &&
            videoDate.month == today.month &&
            videoDate.day == today.day;

        if (wasUploadedToday && totalUploadsToday > 0) {
          totalUploadsToday--;
        }
      }

      notifyListeners();
      debugPrint(
        "✅ Video deleted successfully. Today's uploads: $totalUploadsToday",
      );
    } catch (e) {
      debugPrint("❌ Error deleting video: $e");
    }
  }

  //
}
