import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/Models/video_model.dart';
import 'package:dailydevotion/admin/providers/video_provider1.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:dailydevotion/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DevotionManagemnet extends StatefulWidget {
  final AppLocalizations tr;
  final UserModel user;
  const DevotionManagemnet({super.key, required this.user, required this.tr});

  @override
  State<DevotionManagemnet> createState() => _DevotionManagemnetState();
}

class _DevotionManagemnetState extends State<DevotionManagemnet>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadData() async {
    final videoProvider = Provider.of<VideoProvider1>(context, listen: false);
    await Future.wait([
      videoProvider.fetchUserStreak(),
      videoProvider.fetchUserVideos(),
      // videoProvider.fetchTodayUploads(widget.user.uid),
    ]);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final videoProvider = Provider.of<VideoProvider1>(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    // final tr = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: widget.tr.devotionsManagement),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: width * 0.05,
                        right: width * 0.05,
                        top: height * 0.01,
                        bottom: height * 0.1,
                      ),
                      child: Column(
                        children: [
                          _buildRecentVideosSection(
                            width,
                            themeProvider,
                            videoProvider,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentVideosSection(
    double width,
    ThemeProvider themeProvider,
    VideoProvider1 videoProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: width * 0.04),
          child: Row(
            children: [
              Icon(
                Icons.video_collection,
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : Colors.grey[800],
                size: width * 0.06,
              ),
              SizedBox(width: width * 0.02),
              Text(
                // "Recent Devotions",
                widget.tr.recentDevotions,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.045,
                  color: themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                "(${videoProvider.userVideos.length} ${widget.tr.total})",
                style: TextStyle(color: Colors.grey, fontSize: width * 0.035),
              ),
            ],
          ),
        ),
        videoProvider.userVideos.isEmpty
            ? _buildEmptyState(width, themeProvider)
            : ListView.builder(
                // itemCount: videoProvider.userVideos.length > 10
                //     ? 10
                //     : videoProvider.userVideos.length,
                itemCount: videoProvider.userVideos.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final video = videoProvider.userVideos[index];
                  return _buildVideoCard(
                    video,
                    index,
                    width,
                    themeProvider,
                    videoProvider,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState(double width, ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(width * 0.1),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.video_library_outlined,
            size: width * 0.15,
            color: Colors.grey,
          ),
          SizedBox(height: width * 0.04),
          Text(
            // "No videos uploaded yet",
            widget.tr.noVideo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: width * 0.04,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: width * 0.02),
          Text(
            widget.tr.startSharing,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: width * 0.035,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(
    VideoModel video,
    int index,
    double width,
    ThemeProvider themeProvider,
    VideoProvider1 videoProvider,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: width * 0.03),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(width * 0.03),
        leading: Hero(
          tag: 'video_thumb_${video.id}',
          child: Container(
            width: width * 0.15,
            height: width * 0.15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            ),
            child: video.thumbnailUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.purple.shade400,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.video_library,
                          color: Colors.grey[600],
                          size: width * 0.06,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.video_library,
                    color: Colors.grey[600],
                    size: width * 0.06,
                  ),
          ),
        ),
        title: Text(
          video.title.isNotEmpty ? video.title : "Untitled Video",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: width * 0.04,
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey[800],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (video.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: width * 0.01),
                child: Text(
                  video.description,
                  style: TextStyle(
                    fontSize: width * 0.032,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            SizedBox(height: width * 0.02),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: width * 0.035,
                  color: Colors.grey[500],
                ),
                SizedBox(width: width * 0.01),
                Text(
                  // _formatDate(video.createdAt),
                  timeago.format(video.createdAt, locale: widget.tr.localeName),
                  style: TextStyle(
                    fontSize: width * 0.03,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: themeProvider.isDarkMode ? Colors.white : Colors.grey[600],
          ),
          onSelected: (value) async {
            if (value == widget.tr.delete) {
              await _showDeleteDialog(video, index, videoProvider);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: widget.tr.delete,
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: width * 0.045),
                  SizedBox(width: width * 0.02),
                  Text(widget.tr.delete),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  Future<void> _showDeleteDialog(
    VideoModel video,
    int index,
    VideoProvider1 videoProvider,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Column(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 10),
              Text(
                // 'Delete Video'
                widget.tr.deleteVideo,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  // 'Are you sure you want to delete this video?'
                  widget.tr.deleteVideoConfirm,
                ),
                SizedBox(height: 8),
                Text(
                  video.title.isNotEmpty
                      ? '"${video.title}"'
                      : 'Untitled Video',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  // 'This action cannot be undone.',
                  widget.tr.actionCannotBeUndone,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                // 'Cancel'
                widget.tr.cancel,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                // 'Delete'
                widget.tr.delete,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await videoProvider.deleteVideo(
                  // index,
                  widget.user.uid,
                  video.id,
                  video.videoUrl,
                  video.thumbnailUrl,
                );
                _showSnackBar("${widget.tr.videoDeleted}!", Colors.green);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  //
}
