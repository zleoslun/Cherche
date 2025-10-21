// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:video_player/video_player.dart';

// class FullScreenVideoPlayer extends StatefulWidget {
//   final VideoPlayerController controller;

//   const FullScreenVideoPlayer({super.key, required this.controller});

//   @override
//   State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
// }

// class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
//   bool _showControls = true;

//   void _toggleControls() {
//     setState(() => _showControls = !_showControls);
//   }

//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//   }

//   @override
//   void dispose() {
//     SystemChrome.setEnabledSystemUIMode(
//       SystemUiMode.manual,
//       overlays: SystemUiOverlay.values,
//     );
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             GestureDetector(
//               onTap: _toggleControls,
//               child: Center(
//                 child: AspectRatio(
//                   aspectRatio: widget.controller.value.aspectRatio,
//                   child: VideoPlayer(widget.controller),
//                 ),
//               ),
//             ),
//             if (_showControls)
//               Positioned(
//                 top: 16,
//                 left: 8,
//                 child: IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white, size: 28),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// 2
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayer({super.key, required this.controller});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _showControls = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;

    // Lock orientation and hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _hideControlsAfterDelay();

    // Listen for controller updates
    widget.controller.addListener(() {
      if (mounted) {
        setState(() => _isPlaying = widget.controller.value.isPlaying);
      }
    });
  }

  @override
  void dispose() {
    // Restore UI and portrait orientation
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _hideControlsAfterDelay();
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
    setState(() => _isPlaying = widget.controller.value.isPlaying);
    _hideControlsAfterDelay();
  }

  /// Clamp helper for safe seek positions
  Duration _clampDuration(Duration d, Duration min, Duration max) {
    if (d < min) return min;
    if (d > max) return max;
    return d;
  }

  void _seekRelative(Duration offset) {
    final duration = widget.controller.value.duration;
    final position = widget.controller.value.position + offset;
    final newPos = _clampDuration(position, Duration.zero, duration);
    widget.controller.seekTo(newPos);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),

            // === CONTROLS OVERLAY ===
            if (_showControls)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // --- Top bar (exit fullscreen) ---
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // --- Middle controls (seek/play) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: () =>
                                _seekRelative(const Duration(seconds: -10)),
                          ),
                          IconButton(
                            icon: Icon(
                              _isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 60,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: () =>
                                _seekRelative(const Duration(seconds: 10)),
                          ),
                        ],
                      ),

                      // --- Bottom progress bar + timestamps ---
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            ValueListenableBuilder(
                              valueListenable: widget.controller,
                              builder:
                                  (context, VideoPlayerValue value, child) {
                                    final posMs = value.position.inMilliseconds
                                        .clamp(
                                          0,
                                          value.duration.inMilliseconds,
                                        );
                                    final durMs = value.duration.inMilliseconds;
                                    return Slider(
                                      activeColor: Colors.deepPurpleAccent,
                                      inactiveColor: Colors.white38,
                                      value: posMs.toDouble(),
                                      min: 0,
                                      max: durMs.toDouble(),
                                      onChanged: (v) =>
                                          widget.controller.seekTo(
                                            Duration(milliseconds: v.toInt()),
                                          ),
                                    );
                                  },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ValueListenableBuilder(
                                  valueListenable: widget.controller,
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
                                  valueListenable: widget.controller,
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
                              ],
                            ),
                          ],
                        ),
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
}
