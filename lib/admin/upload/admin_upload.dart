import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/Models/video_model.dart';
import 'package:dailydevotion/admin/providers/video_provider1.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:dailydevotion/widgets/custom_button.dart';
import 'package:dailydevotion/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminUpload extends StatefulWidget {
  final UserModel user;
  final AppLocalizations tr;
  const AdminUpload({super.key, required this.user, required this.tr});

  @override
  State<AdminUpload> createState() => _AdminUploadState();
}

class _AdminUploadState extends State<AdminUpload> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final videoProvider = Provider.of<VideoProvider1>(context, listen: false);
      videoProvider.initializeStreak();
    });
  }

  Future<void> _selectScheduleDateTime(VideoProvider1 videoProvider) async {
    final minimumTime = videoProvider.minimumScheduleTime;

    // Select Date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: minimumTime,
      firstDate: minimumTime,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      // Select Time
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(minimumTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            ),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        final scheduledDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        if (videoProvider.isValidScheduleTime(scheduledDateTime)) {
          videoProvider.setScheduleDateTime(scheduledDateTime);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.tr.scheduleTimeLimit),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Widget _buildScheduleSection(VideoProvider1 videoProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: videoProvider.isScheduleMode
              ? Colors.blue
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: videoProvider.isScheduleMode,
                onChanged: videoProvider.isUploading
                    ? null
                    : videoProvider.setScheduleMode,
                activeColor: Colors.blue,
              ),

              Text(
                widget.tr.scheduleForLater,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: videoProvider.isScheduleMode ? Colors.blue : null,
                ),
              ),
            ],
          ),
          if (videoProvider.isScheduleMode) ...[
            const SizedBox(height: 12),
            Text(
              widget.tr.videoAutoPublish,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: videoProvider.isUploading
                  ? null
                  : () => _selectScheduleDateTime(videoProvider),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        videoProvider.selectedScheduleDateTime != null
                            ? _formatDateTime(
                                videoProvider.selectedScheduleDateTime!,
                              )
                            : widget.tr.selectDateTime,
                        style: TextStyle(
                          color: videoProvider.selectedScheduleDateTime != null
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (videoProvider.selectedScheduleDateTime != null)
                      IconButton(
                        onPressed: videoProvider.isUploading
                            ? null
                            : videoProvider.clearSchedule,
                        icon: const Icon(Icons.clear, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
            if (videoProvider.selectedScheduleDateTime != null) ...[
              const SizedBox(height: 8),
              Text(
                "Will publish in ${_getTimeUntil(videoProvider.selectedScheduleDateTime!)}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildScheduledVideosList(VideoProvider1 videoProvider) {
    if (videoProvider.scheduledVideos.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${widget.tr.scheduledVideos} (${videoProvider.scheduledVideos.length})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...videoProvider.scheduledVideos.map(
            (video) => _buildScheduledVideoCard(video, videoProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledVideoCard(
    VideoModel video,
    VideoProvider1 videoProvider,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (video.thumbnailUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    video.thumbnailUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.video_library),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${widget.tr.publishesIn} ${_getTimeUntil(video.scheduledAt!)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRescheduleDialog(video, videoProvider),
                  icon: const Icon(Icons.edit_calendar, size: 16),
                  label: Text(
                    widget.tr.reschedule,
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      videoProvider.publishVideoImmediately(video.id),
                  icon: const Icon(Icons.publish, size: 16),
                  label: Text(
                    widget.tr.publishNow,
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => videoProvider.cancelScheduledVideo(video.id),
                  icon: Icon(Icons.cancel, size: 16),
                  label: Text(widget.tr.cancel, style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showRescheduleDialog(
    VideoModel video,
    VideoProvider1 videoProvider,
  ) async {
    DateTime? newDateTime;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: video.scheduledAt ?? videoProvider.minimumScheduleTime,
      firstDate: videoProvider.minimumScheduleTime,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null && mounted) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          video.scheduledAt ?? videoProvider.minimumScheduleTime,
        ),
      );

      if (selectedTime != null) {
        newDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        if (videoProvider.isValidScheduleTime(newDateTime)) {
          try {
            await videoProvider.rescheduleVideo(video.id, newDateTime);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "${widget.tr.videoRescheduledFor} ${_formatDateTime(newDateTime)}",
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error rescheduling video: $e"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.tr.scheduleTimeLimit),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    }
  }

  // String _formatDateTime(DateTime dateTime) {
  //   return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  // }

  // String _getTimeUntil(DateTime dateTime) {
  //   final now = DateTime.now();
  //   final difference = dateTime.difference(now);

  //   if (difference.inDays > 0) {
  //     return '${difference.inDays} days, ${difference.inHours % 24} hours';
  //   } else if (difference.inHours > 0) {
  //     return '${difference.inHours} hours, ${difference.inMinutes % 60} minutes';
  //   } else if (difference.inMinutes > 0) {
  //     return '${difference.inMinutes} minutes';
  //   } else {
  //     return 'any moment';
  //   }
  // }

  // 2
  String _formatDateTime(DateTime dateTime) {
    final locale = Localizations.localeOf(context).toString();

    // This automatically formats date and time according to the user's locale
    // French: 25/12/2024 à 14:30
    // English: 12/25/2024 at 2:30 PM
    final dateFormat = DateFormat.yMd(locale);
    final timeFormat = DateFormat.Hm(locale);

    return '${dateFormat.format(dateTime)} ${widget.tr.atTime} ${timeFormat.format(dateTime)}';
  }

  // Replace your existing _getTimeUntil method with this:
  String _getTimeUntil(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      final days = difference.inDays;
      final hours = difference.inHours % 24;

      // Always show days and hours together (like "3 days 18 hours")
      final dayText = days == 1 ? widget.tr.day : widget.tr.days;
      final hourText = hours == 1 ? widget.tr.hour : widget.tr.hours;

      return '$days $dayText $hours $hourText';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      // Always show hours and minutes together (like "18 hours 30 minutes")
      final hourText = hours == 1 ? widget.tr.hour : widget.tr.hours;
      final minuteText = minutes == 1 ? widget.tr.minute : widget.tr.minutes;

      return '$hours $hourText $minutes $minuteText';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      final minuteText = minutes == 1 ? widget.tr.minute : widget.tr.minutes;

      return '$minutes $minuteText';
    } else {
      return widget.tr.anyMoment;
    }
  }

  Widget buildVideoUploadSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final videoProvider = Provider.of<VideoProvider1>(context);
    final size = MediaQuery.of(context).size;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
        child: Container(
          width: size.width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _buildUploadState(videoProvider),
        ),
      ),
    );
  }

  Widget _buildUploadState(VideoProvider1 videoProvider) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.movie,
              size: 60,
              color: videoProvider.selectedVideo != null
                  ? Colors.blue
                  : Colors.grey,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.tr.uploadNewVideo, // "Upload New Video"
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          widget
              .tr
              .shareDevotionComunity, // "Share your devotion with the community"
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (videoProvider.videoThumbnail != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                videoProvider.videoThumbnail!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
        CustomButton(
          label: Text(
            videoProvider.selectedVideo != null
                ? widget.tr.changeVideo
                : widget.tr.chooseVideo,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: videoProvider.isUploading
              ? null
              : () => videoProvider.pickVideo(context),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hint: widget.tr.videoTitle,
          textInputType: TextInputType.text,
          controller: videoProvider.titleController,
          enabled: !videoProvider.isUploading,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          hint: widget.tr.description,
          textInputType: TextInputType.text,
          maxLines: 3,
          controller: videoProvider.descController,
          enabled: !videoProvider.isUploading,
        ),
        const SizedBox(height: 16),

        // Schedule Section
        _buildScheduleSection(videoProvider),

        const SizedBox(height: 16),
        CustomButton(
          label: videoProvider.isUploading
              ? Text(
                  "${widget.tr.uploading}: ${(videoProvider.uploadProgress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(color: Colors.white),
                )
              : Text(
                  videoProvider.isScheduleMode
                      ? widget.tr.shareCommunity
                      : widget.tr.shareCommunity,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          onTap:
              videoProvider.isUploading || videoProvider.selectedVideo == null
              ? null
              : () {
                  if (videoProvider.titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.tr.enterVideoTitle),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  videoProvider.uploadVideo(widget.user.uid, context);
                },
        ),
        if (videoProvider.isUploading)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(
              value: videoProvider.uploadProgress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final videoProvider = Provider.of<VideoProvider1>(context);
    final size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: width * 0.05,
            right: width * 0.05,
            top: height * 0.02,
            bottom: height * 0.15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.tr.shareDevotions,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.05,
                ),
              ),

              // Streak Display
              if (videoProvider.currentStreak > 0)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.01),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${videoProvider.currentStreak} ${widget.tr.dayStreak}!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Today's Uploads Progress
              Padding(
                padding: EdgeInsets.symmetric(vertical: height * 0.01),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[900]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.tr.todaysUploads,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: videoProvider.totalUploadsToday > 0
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${videoProvider.totalUploadsToday} ${widget.tr.uploaded}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: videoProvider.totalUploadsToday > 0
                                      ? Colors.green
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (videoProvider.scheduledVideos.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: height * 0.01),
                            child: Text(
                              "${videoProvider.scheduledVideos.length} ${widget.tr.videosScheduled}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        if (videoProvider.totalUploadsToday > 0)
                          Padding(
                            padding: EdgeInsets.only(top: height * 0.01),
                            child: Text(
                              widget.tr.unlimitedDevotions,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Success message if not currently uploading and no video selected
              if (!videoProvider.isUploading &&
                  videoProvider.selectedVideo == null &&
                  videoProvider.totalUploadsToday > 0)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: height * 0.01),
                  child: Center(
                    child: Container(
                      width: width,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            textAlign: TextAlign.center,
                            widget.tr.readyForNextUpload,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.tr.uploadAnotherDevotion,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Single Upload Section
              buildVideoUploadSection(),

              // Scheduled Videos List
              _buildScheduledVideosList(videoProvider),

              // Reset button (optional - for clearing current selection)
              if (videoProvider.selectedVideo != null &&
                  !videoProvider.isUploading)
                Padding(
                  padding: EdgeInsets.only(top: height * 0.02),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        videoProvider.resetUploadSlot();
                      },
                      child: Text(
                        widget.tr.clearSelection,
                        style: TextStyle(
                          color: Colors.red[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
