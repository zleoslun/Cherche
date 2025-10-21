import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/admin/providers/video_provider1.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/providers/user_provider.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailydevotion/Models/user.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserAvatar extends StatelessWidget {
  final UserModel? user;
  final double radius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const UserAvatar({
    Key? key,
    required this.user,
    this.radius = 20,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Color(0xFF130E6A),
        backgroundImage: _buildBackgroundImage(),
        child: _buildChild(),
      ),
    );
  }

  ImageProvider<Object>? _buildBackgroundImage() {
    if (user?.profilePic != null && user!.profilePic!.isNotEmpty) {
      return CachedNetworkImageProvider(user!.profilePic!);
    }
    return null;
  }

  Widget? _buildChild() {
    // Only show text if there's no profile picture
    if (user?.profilePic != null && user!.profilePic!.isNotEmpty) {
      return null;
    }

    return Text(
      _getInitials(),
      style: TextStyle(
        color: Colors.white,
        fontSize: radius * 0.6,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _getInitials() {
    if (user?.name == null || user!.name!.isEmpty) return 'U';

    final words = user!.name!.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}

class CommentItem extends StatefulWidget {
  final DetailedComment comment;
  final void Function(String) onLike;
  final void Function(String) onReply;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.onLike,
    required this.onReply,
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  UserModel? commentUser;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = await userProvider.getUserById(widget.comment.uid);

      if (mounted) {
        setState(() {
          commentUser = user;
          isLoadingUser = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading comment user: $e');
      if (mounted) {
        setState(() {
          isLoadingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(user: commentUser, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(themeProvider, tr),
                const SizedBox(height: 4),
                _buildCommentText(themeProvider),
                const SizedBox(height: 8),
                // _buildActions(themeProvider),
                // const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider, AppLocalizations tr) {
    return Row(
      children: [
        Text(
          commentUser?.name ?? 'Loading...',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timeago.format(widget.comment.timestamp, locale: tr.localeName),
          style: TextStyle(
            fontSize: 12,
            color: themeProvider.isDarkMode
                ? Colors.grey[400]
                : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentText(ThemeProvider themeProvider) {
    return Text(
      widget.comment.comment,
      style: TextStyle(
        fontSize: 14,
        height: 1.4,
        color: themeProvider.isDarkMode ? Colors.grey[200] : Colors.grey[800],
      ),
    );
  }
}

class CommentSheet extends StatefulWidget {
  final String videoId;
  final List<String> existingComments;
  final Future<void> Function(String)? onComment;

  const CommentSheet({
    super.key,
    required this.videoId,
    this.existingComments = const [],
    this.onComment,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  List<DetailedComment> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadComments();
  }

  void _initializeAnimation() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _slideController.forward();
  }

  Future<void> _loadComments() async {
    try {
      final videoProvider = Provider.of<VideoProvider1>(context, listen: false);
      final analytics = await videoProvider.getVideoAnalytics(widget.videoId);

      debugPrint('🔍 Analytics data: $analytics');

      final commentData = List<Map<String, dynamic>>.from(
        analytics['comments'] ?? [],
      );

      debugPrint('🔍 Comment data: $commentData');

      if (mounted) {
        setState(() {
          comments = commentData
              .map((data) => DetailedComment.fromMap(data))
              .toList();
          comments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          isLoading = false;

          debugPrint(
            '🔍 Loaded ${comments.length} comments with IDs: ${comments.map((c) => c.id).toList()}',
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _submitComment() async {
    if (_commentController.text.trim().isNotEmpty) {
      final commentText = _commentController.text.trim();

      _commentController.clear();
      _focusNode.unfocus();

      try {
        if (widget.onComment != null) {
          await widget.onComment!(commentText);
        }
        await _loadComments();
      } catch (e) {
        debugPrint('Error submitting comment: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to post comment. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _likeComment(String commentId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final commentIndex = comments.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) return;

      final comment = comments[commentIndex];
      final hasLiked = comment.likedBy.contains(currentUser.uid);

      // Optimistic update: update UI immediately
      setState(() {
        comments[commentIndex] = comment.copyWith(
          likes: hasLiked ? comment.likes - 1 : comment.likes + 1,
          likedBy: hasLiked
              ? comment.likedBy.where((uid) => uid != currentUser.uid).toList()
              : [...comment.likedBy, currentUser.uid],
        );
      });

      // Update backend
      // await updateCommentLike(commentId, currentUser.uid, !hasLiked);
      await updateCommentLike(
        widget.videoId,
        commentId,
        currentUser.uid,
        !hasLiked,
      );

      // Optional: reload comments to ensure consistency
      await _loadComments();
    } catch (e) {
      debugPrint('Error liking comment: $e');
      // Revert optimistic update on error
      await _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update like: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> updateCommentLike(
    String videoId,
    String commentId,
    String userId,
    bool isLiking,
  ) async {
    final commentRef = FirebaseFirestore.instance
        .collection('videos')
        .doc(videoId)
        .collection('comments')
        .doc(commentId);

    if (isLiking) {
      await commentRef.update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    } else {
      await commentRef.update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    }
  }

  void _replyToComment(String userName) {
    _focusNode.requestFocus();
    _commentController.text = '@$userName ';
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final tr = AppLocalizations.of(context)!;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: size.height * 0.8,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHandle(themeProvider),
            _buildHeader(themeProvider, tr),
            const Divider(height: 1),
            _buildCommentsList(themeProvider, tr),
            _buildCommentInput(themeProvider, userProvider, keyboardHeight, tr),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(ThemeProvider themeProvider) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[600] : Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider, AppLocalizations tr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            // 'Comments',
            tr.comment,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF130E6A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${comments.length}',
              style: const TextStyle(
                color: Color(0xFF130E6A),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: themeProvider.isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(ThemeProvider themeProvider, AppLocalizations tr) {
    return Expanded(
      child: isLoading
          ? const Center(child: SizedBox())
          : comments.isEmpty
          ? _buildEmptyState(themeProvider, tr)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return CommentItem(
                  comment: comment,
                  onLike: _likeComment,
                  onReply: _replyToComment,
                );
              },
            ),
    );
  }

  Widget _buildCommentInput(
    ThemeProvider themeProvider,
    UserProvider userProvider,
    double keyboardHeight,
    AppLocalizations tr,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + keyboardHeight,
      ),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: themeProvider.isDarkMode
                ? Colors.grey[700]!
                : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          UserAvatar(user: userProvider.user, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.grey[800]
                    : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!,
                ),
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _focusNode,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "${tr.addComment}...",
                  hintStyle: TextStyle(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF130E6A),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _submitComment,
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider, AppLocalizations tr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.comment_outlined,
            size: 64,
            color: themeProvider.isDarkMode
                ? Colors.grey[600]
                : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            // 'No comments yet',
            tr.noComments,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: themeProvider.isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr.beFirstToSharePrayer,
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode
                  ? Colors.grey[500]
                  : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep your existing DetailedComment class
class DetailedComment {
  final String id;
  final String uid;
  final String userName;
  final String? userProfilePic;
  final String comment;
  final DateTime timestamp;
  final int likes;
  final List<String> likedBy;

  DetailedComment({
    required this.id,
    required this.uid,
    required this.userName,
    this.userProfilePic,
    required this.comment,
    required this.timestamp,
    required this.likes,
    required this.likedBy,
  });

  factory DetailedComment.fromMap(Map<String, dynamic> map) {
    return DetailedComment(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? 'User',
      userProfilePic: map['userProfilePic'],
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'likedBy': likedBy,
    };
  }

  DetailedComment copyWith({
    String? id,
    String? uid,
    String? userName,
    String? userProfilePic,
    String? comment,
    DateTime? timestamp,
    int? likes,
    List<String>? likedBy,
  }) {
    return DetailedComment(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      userProfilePic: userProfilePic ?? this.userProfilePic,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}
