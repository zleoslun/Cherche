import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/Models/video_model.dart';
import 'package:dailydevotion/admin/providers/video_provider1.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/providers/user_provider.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:dailydevotion/widgets/comment_sheet.dart';
import 'package:dailydevotion/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommunityPost extends StatefulWidget {
  final VideoModel videoModel;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final AppLocalizations tr;
  final Function(String)? onComment;

  const CommunityPost({
    super.key,
    required this.videoModel,
    this.onLike,
    this.onShare,
    this.onComment,
    required this.tr,
  });

  @override
  State<CommunityPost> createState() => _CommunityPostState();
}

class _CommunityPostState extends State<CommunityPost>
    with TickerProviderStateMixin {
  bool isLiked = false;
  bool isFollowing = false;

  late AnimationController _likeAnimationController;
  late AnimationController _followAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    super.initState();

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _followAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Check if user already liked this video
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    if (mounted) {
      final videoProvider = Provider.of<VideoProvider1>(context, listen: false);
      final liked = await videoProvider.isVideoLikedByUser(
        widget.videoModel.id,
      );
      if (mounted) {
        setState(() {
          isLiked = liked;
        });
      }
    }
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _followAnimationController.dispose();
    super.dispose();
  }

  void _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
    });

    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    // Update in Firebase
    final videoProvider = Provider.of<VideoProvider1>(context, listen: false);
    await videoProvider.likeVideo(widget.videoModel.id);

    if (widget.onLike != null) {
      widget.onLike!();
    }
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSheet(
        videoId: widget.videoModel.id,
        existingComments: widget.videoModel.comments,
        onComment: (comment) async {
          // Update in Firebase
          final videoProvider = Provider.of<VideoProvider1>(
            context,
            listen: false,
          );
          await videoProvider.commentOnVideo(widget.videoModel.id, comment);

          if (widget.onComment != null) {
            widget.onComment!(comment);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: height * 0.01,
        horizontal: width * 0.02,
      ),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          _buildHeader(width, height, themeProvider),

          // Video Player Section
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: SizedBox(
              width: double.infinity,
              // height: height * 0.4,
              child: VideoPlayerWidget(
                videoUrl: widget.videoModel.videoUrl,
                thumbnailUrl: widget.videoModel.thumbnailUrl,
              ),
            ),
          ),

          // Content Section
          _buildContent(width, height, themeProvider),

          // Engagement Stats
          _buildEngagementStats(width, height, themeProvider),

          // Action Buttons
          _buildActionButtons(width, height, themeProvider),
        ],
      ),
    );
  }

  Widget _buildHeader(
    double width,
    double height,
    ThemeProvider themeProvider,
  ) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return FutureBuilder<UserModel?>(
      future: userProvider.getUserById(widget.videoModel.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // return const SizedBox(
          //   height: 45,
          //   width: 45,
          //   child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          // );
          return _buildHeaderShimmer(width, height, themeProvider);
        }

        final user = snapshot.data!;
        final hasImage = user.profilePic != null && user.profilePic!.isNotEmpty;

        return Padding(
          padding: EdgeInsets.all(width * 0.04),
          child: Row(
            children: [
              // Profile Picture / Initial
              CircleAvatar(
                radius: 22,
                backgroundImage: hasImage
                    ? NetworkImage(user.profilePic!)
                    : null,
                backgroundColor: Color(0xFF130E6A),
                child: !hasImage
                    ? Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),

              SizedBox(width: width * 0.03),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.04,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.003),
                    Text(
                      // timeago.format(widget.videoModel.createdAt),
                      timeago.format(
                        widget.videoModel.createdAt,
                        locale: widget.tr.localeName, // 'en' or 'fr'
                      ),
                      style: TextStyle(
                        fontSize: width * 0.03,
                        color: themeProvider.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(
    double width,
    double height,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.015,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.videoModel.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: width * 0.045,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: height * 0.01),

          // Description
          if (widget.videoModel.description.isNotEmpty)
            Text(
              widget.videoModel.description,
              style: TextStyle(
                fontSize: width * 0.035,
                color: themeProvider.isDarkMode
                    ? Colors.grey[300]
                    : Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildEngagementStats(
    double width,
    double height,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: Row(
        children: [
          _buildStatItem(
            Icons.favorite,
            widget.videoModel.likes.toString(),
            Colors.red,
            themeProvider,
            width,
          ),
          SizedBox(width: width * 0.04),
          _buildStatItem(
            Icons.comment_outlined,
            widget.videoModel.commentCount.toString(),
            Colors.blue,
            themeProvider,
            width,
          ),

          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.grey
                  : Color(0xFF130E6A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.tr.devotion,
              style: TextStyle(
                fontSize: width * 0.025,
                color: Color(0xFF130E6A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String count,
    Color color,
    ThemeProvider themeProvider,
    double width,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: width * 0.04, color: color),
        SizedBox(width: width * 0.01),
        Text(
          count,
          style: TextStyle(
            fontSize: width * 0.03,
            color: themeProvider.isDarkMode
                ? Colors.grey[300]
                : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    double width,
    double height,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: EdgeInsets.all(width * 0.04),
      child: Row(
        children: [
          // Like Button
          Expanded(
            child: AnimatedBuilder(
              animation: _likeAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _likeAnimation.value,
                  child: InkWell(
                    onTap: _toggleLike,
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: height * 0.012),
                      decoration: BoxDecoration(
                        color: isLiked
                            ? Colors.red.withOpacity(0.1)
                            : (themeProvider.isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isLiked
                              ? Colors.red.withOpacity(0.3)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked
                                ? Colors.red
                                : (themeProvider.isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[600]),
                            size: width * 0.05,
                          ),
                          SizedBox(width: width * 0.02),
                          Text(
                            isLiked ? widget.tr.liked : widget.tr.like,
                            style: TextStyle(
                              color: isLiked
                                  ? Colors.red
                                  : (themeProvider.isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[600]),
                              fontWeight: FontWeight.w600,
                              fontSize: width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(width: width * 0.03),

          // Comment Button
          Expanded(
            child: InkWell(
              onTap: _openComments,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: height * 0.012),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      color: themeProvider.isDarkMode
                          ? Colors.grey[300]
                          : Colors.grey[600],
                      size: width * 0.05,
                    ),
                    SizedBox(width: width * 0.02),
                    Text(
                      // "Comment",
                      widget.tr.comment,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.grey[300]
                            : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: width * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer(
    double width,
    double height,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: EdgeInsets.all(width * 0.04),
      child: Row(
        children: [
          // Profile Picture Shimmer
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(-1.0, -0.3),
                    end: Alignment(1.0, 0.3),
                    colors: themeProvider.isDarkMode
                        ? [
                            Colors.grey[700]!,
                            Colors.grey[500]!,
                            Colors.grey[300]!,
                            Colors.grey[500]!,
                            Colors.grey[700]!,
                          ]
                        : [
                            Colors.grey[300]!,
                            Colors.grey[200]!,
                            Colors.grey[100]!,
                            Colors.grey[200]!,
                            Colors.grey[300]!,
                          ],
                    stops: [
                      0.0,
                      0.35 + (value * 0.3),
                      0.5 + (value * 0.3),
                      0.65 + (value * 0.3),
                      1.0,
                    ],
                  ),
                ),
              );
            },
            onEnd: () {
              // Restart animation
              if (mounted) {
                setState(() {});
              }
            },
          ),
          SizedBox(width: width * 0.03),
          // User info shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name shimmer
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Container(
                      width: width * 0.3,
                      height: width * 0.04,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment(-1.0, -0.3),
                          end: Alignment(1.0, 0.3),
                          colors: themeProvider.isDarkMode
                              ? [
                                  Colors.grey[700]!,
                                  Colors.grey[500]!,
                                  Colors.grey[300]!,
                                  Colors.grey[500]!,
                                  Colors.grey[700]!,
                                ]
                              : [
                                  Colors.grey[300]!,
                                  Colors.grey[200]!,
                                  Colors.grey[100]!,
                                  Colors.grey[200]!,
                                  Colors.grey[300]!,
                                ],
                          stops: [
                            0.0,
                            0.35 + (value * 0.3),
                            0.5 + (value * 0.3),
                            0.65 + (value * 0.3),
                            1.0,
                          ],
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
                SizedBox(height: height * 0.006),
                // Time shimmer
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Container(
                      width: width * 0.2,
                      height: width * 0.03,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment(-1.0, -0.3),
                          end: Alignment(1.0, 0.3),
                          colors: themeProvider.isDarkMode
                              ? [
                                  Colors.grey[700]!,
                                  Colors.grey[500]!,
                                  Colors.grey[300]!,
                                  Colors.grey[500]!,
                                  Colors.grey[700]!,
                                ]
                              : [
                                  Colors.grey[300]!,
                                  Colors.grey[200]!,
                                  Colors.grey[100]!,
                                  Colors.grey[200]!,
                                  Colors.grey[300]!,
                                ],
                          stops: [
                            0.0,
                            0.35 + (value * 0.3),
                            0.5 + (value * 0.3),
                            0.65 + (value * 0.3),
                            1.0,
                          ],
                        ),
                      ),
                    );
                  },
                  onEnd: () {
                    if (mounted) {
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
