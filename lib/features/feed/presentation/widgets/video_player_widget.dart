import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../core/consts/color_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final String? postId;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.autoPlay = false,
    this.postId,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isVisible = false;
  bool _showControls = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      _controller.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          if (widget.autoPlay) {
            _controller.play();
          }
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return VisibilityDetector(
      key: Key('video_${widget.postId ?? widget.videoUrl}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: _toggleControls,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  _buildPlayPauseOverlay(),
                  if (_showControls) _buildVideoControls(),
                  _buildMuteButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    setState(() {
      _isVisible = info.visibleFraction > 0.5;
    });

    if (_isVisible && widget.autoPlay) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.shimmerBase,
            ColorManager.shimmerHighlight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            ColorManager.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorManager.error.withOpacity(0.1),
            ColorManager.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorManager.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              color: ColorManager.error,
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load video',
              style: TextStyle(
                color: ColorManager.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _retryVideo,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: ColorManager.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _retryVideo() {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });
    _controller.dispose();
    _initializeVideo();
  }

  Widget _buildPlayPauseOverlay() {
    return Center(
      child: AnimatedOpacity(
        opacity: _controller.value.isPlaying && !_showControls ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: ColorManager.primaryGradient.map((c) => c.withOpacity(0.8)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: ColorManager.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: ColorManager.textPrimary,
              size: 40,
            ),
            onPressed: () {
              setState(() {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMuteButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _controller.setVolume(_controller.value.volume == 0 ? 1.0 : 0.0);
            });
          },
          child: Icon(
            _controller.value.volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: ColorManager.textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      _formatDuration(_controller.value.position),
                      style: TextStyle(
                        color: ColorManager.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _controller.value.position.inMilliseconds.toDouble().clamp(
                          0.0,
                          _controller.value.duration.inMilliseconds.toDouble(),
                        ),
                        min: 0.0,
                        max: _controller.value.duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          _controller.seekTo(Duration(milliseconds: value.toInt()));
                        },
                        activeColor: ColorManager.primary,
                        inactiveColor: ColorManager.textTertiary.withOpacity(0.3),
                        thumbColor: ColorManager.primary,
                      ),
                    ),
                    Text(
                      _formatDuration(_controller.value.duration),
                      style: TextStyle(
                        color: ColorManager.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}