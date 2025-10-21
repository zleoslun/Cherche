
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class VideoPlayerWidget extends StatefulWidget {
//   final String videoUrl;
//   final String? thumbnailUrl;

//   const VideoPlayerWidget({
//     super.key,
//     required this.videoUrl,
//     this.thumbnailUrl,
//   });

//   @override
//   State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
// }

// class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
//     with TickerProviderStateMixin {
//   VideoPlayerController? _controller;
//   bool _isInitialized = false;
//   bool _isPlaying = false;
//   bool _showControls = true;
//   late AnimationController _shimmerController;

//   @override
//   void initState() {
//     super.initState();
//     _shimmerController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();
//     _initializeVideo();
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       _controller = VideoPlayerController.networkUrl(
//         Uri.parse(widget.videoUrl),
//       );
//       await _controller!.initialize();

//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//         _shimmerController.stop();
//       }

//       // Auto-hide controls after 3 seconds
//       _hideControlsAfterDelay();
//     } catch (e) {
//       debugPrint('Error initializing video: $e');
//     }
//   }

//   void _hideControlsAfterDelay() {
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted && _showControls) {
//         setState(() {
//           _showControls = false;
//         });
//       }
//     });
//   }

//   void _togglePlayPause() {
//     if (_controller != null && _controller!.value.isInitialized) {
//       if (_controller!.value.isPlaying) {
//         _controller!.pause();
//         setState(() {
//           _isPlaying = false;
//         });
//       } else {
//         _controller!.play();
//         setState(() {
//           _isPlaying = true;
//         });
//         _hideControlsAfterDelay();
//       }
//     }
//   }

//   void _toggleControls() {
//     setState(() {
//       _showControls = !_showControls;
//     });

//     if (_showControls) {
//       _hideControlsAfterDelay();
//     }
//   }

//   @override
//   void dispose() {
//     _shimmerController.dispose();
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       child: Stack(
//         children: [
//           // Video Player or Thumbnail
//           if (_isInitialized && _controller != null)
//             GestureDetector(
//               onTap: _toggleControls,
//               child: Center(
//                 child: AspectRatio(
//                   aspectRatio: _controller!.value.aspectRatio,
//                   child: VideoPlayer(_controller!),
//                 ),
//               ),
//             )
//           else
//             // Show thumbnail or placeholder while loading
//             Center(
//               child:
//                   widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty
//                   ? Image.network(
//                       widget.thumbnailUrl!,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                       errorBuilder: (context, error, stackTrace) {
//                         return _buildPlaceholder();
//                       },
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return _buildPlaceholder();
//                       },
//                     )
//                   : _buildPlaceholder(),
//             ),

//           // Full screen shimmer loading effect
//           if (!_isInitialized)
//             Positioned.fill(
//               child: AnimatedBuilder(
//                 animation: _shimmerController,
//                 builder: (context, child) {
//                   return Container(
//                     width: double.infinity,
//                     height: double.infinity,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment(-1.0, -0.3),
//                         end: Alignment(1.0, 0.3),
//                         colors: [
//                           Colors.grey[700]!,
//                           Colors.grey[500]!,
//                           Colors.grey[300]!,
//                           Colors.grey[500]!,
//                           Colors.grey[700]!,
//                         ],
//                         stops: [
//                           0.0,
//                           0.35 + (_shimmerController.value * 0.3),
//                           0.5 + (_shimmerController.value * 0.3),
//                           0.65 + (_shimmerController.value * 0.3),
//                           1.0,
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//           // Play/Pause overlay
//           if (_showControls && _isInitialized)
//             Center(
//               child: GestureDetector(
//                 onTap: _togglePlayPause,
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.6),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     _isPlaying ? Icons.pause : Icons.play_arrow,
//                     color: Colors.white,
//                     size: 40,
//                   ),
//                 ),
//               ),
//             ),

//           // Progress bar
//           if (_showControls && _isInitialized && _controller != null)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                     colors: [Colors.black.withOpacity(0.7), Colors.transparent],
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ValueListenableBuilder(
//                       valueListenable: _controller!,
//                       builder: (context, VideoPlayerValue value, child) {
//                         return LinearProgressIndicator(
//                           value: value.duration.inMilliseconds > 0
//                               ? value.position.inMilliseconds /
//                                     value.duration.inMilliseconds
//                               : 0.0,
//                           backgroundColor: Colors.white.withOpacity(0.3),
//                           valueColor: const AlwaysStoppedAnimation<Color>(
//                             Colors.deepPurple,
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         ValueListenableBuilder(
//                           valueListenable: _controller!,
//                           builder: (context, VideoPlayerValue value, child) {
//                             return Text(
//                               _formatDuration(value.position),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                               ),
//                             );
//                           },
//                         ),
//                         ValueListenableBuilder(
//                           valueListenable: _controller!,
//                           builder: (context, VideoPlayerValue value, child) {
//                             return Text(
//                               _formatDuration(value.duration),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlaceholder() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.grey[800],
//       child: const Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.video_library, color: Colors.white, size: 60),
//           SizedBox(height: 16),
//           Text(
//             'Loading video...',
//             style: TextStyle(color: Colors.white, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

//     if (duration.inHours > 0) {
//       return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//     } else {
//       return "$twoDigitMinutes:$twoDigitSeconds";
//     }
//   }
// }


// 2
import 'package:dailydevotion/widgets/full_screen_video.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _shimmerController.stop();
      }

      // Auto-hide controls after 3 seconds
      _hideControlsAfterDelay();
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_controller != null && _controller!.value.isInitialized) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        _controller!.play();
        setState(() {
          _isPlaying = true;
        });
        _hideControlsAfterDelay();
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use intrinsic dimensions when video is initialized
    if (_isInitialized && _controller != null) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              // Video Player
              GestureDetector(
                onTap: _toggleControls,
                child: VideoPlayer(_controller!),
              ),

              // Play/Pause overlay
              if (_showControls)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),

              // Progress bar
              if (_showControls)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _controller!,
                          builder: (context, VideoPlayerValue value, child) {
                            return LinearProgressIndicator(
                              value: value.duration.inMilliseconds > 0
                                  ? value.position.inMilliseconds /
                                        value.duration.inMilliseconds
                                  : 0.0,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ValueListenableBuilder(
                              valueListenable: _controller!,
                              builder:
                                  (context, VideoPlayerValue value, child) {
                                    return Text(
                                      _formatDuration(value.position),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                            ),
                            ValueListenableBuilder(
                              valueListenable: _controller!,
                              builder:
                                  (context, VideoPlayerValue value, child) {
                                    return Text(
                                      _formatDuration(value.duration),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                            ),

                            //
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _goFullScreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Loading state with placeholder height
    return Container(
      height:
          MediaQuery.of(context).size.width *
          9 /
          16, // 16:9 aspect ratio placeholder
      color: Colors.black,
      child: Stack(
        children: [
          // Show thumbnail or placeholder while loading
          Center(
            child:
                widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty
                ? Image.network(
                    widget.thumbnailUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),

          // Full screen shimmer loading effect
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1.0, -0.3),
                      end: Alignment(1.0, 0.3),
                      colors: [
                        Colors.grey[700]!,
                        Colors.grey[500]!,
                        Colors.grey[300]!,
                        Colors.grey[500]!,
                        Colors.grey[700]!,
                      ],
                      stops: [
                        0.0,
                        0.35 + (_shimmerController.value * 0.3),
                        0.5 + (_shimmerController.value * 0.3),
                        0.65 + (_shimmerController.value * 0.3),
                        1.0,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[800],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library, color: Colors.white, size: 60),
          SizedBox(height: 16),
          Text(
            'Loading video...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  //
  void _goFullScreen() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final wasPlaying = _controller!.value.isPlaying;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(controller: _controller!),
      ),
    );

    // Resume play state when returning
    if (wasPlaying) {
      _controller!.play();
    }
  }

}
