import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../core/consts/color_manager.dart';
import '../../../../core/services/media_cache_service.dart';
import 'dart:io';

class CachedVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final String? postId;

  const CachedVideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.autoPlay = false,
    this.postId,
  }) : super(key: key);

  @override
  State<CachedVideoPlayerWidget> createState() => _CachedVideoPlayerWidgetState();
}

class _CachedVideoPlayerWidgetState extends State<CachedVideoPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isVisible = false;
  bool _showControls = false;
  bool _isLoading = true;
  File? _cachedFile;
  final MediaCacheService _cacheService = MediaCacheService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Try to get cached file first
      _cachedFile = await _cacheService.getCachedFile(widget.videoUrl);

      VideoPlayerController controller;
      if (_cachedFile != null && await _cachedFile!.exists()) {
        // Use cached file
        controller = VideoPlayerController.file(_cachedFile!);
      } else {
        // Use network URL and cache in background
        controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
        _cacheVideoInBackground();
      }

      _controller = controller;

      await _controller.initialize();

      if (mounted) {
        try {
          setState(() {
            _isInitialized = true;
            _isLoading = false;
          });

          if (widget.autoPlay && _isVisible) {
            _controller.play();
          }
        } catch (e) {
          // Ignore setState errors during disposal
        }
      }
    } catch (error) {
      if (mounted) {
        try {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        } catch (e) {
          // Ignore setState errors during disposal
        }
      }
    }
  }

  Future<void> _cacheVideoInBackground() async {
    try {
      await _cacheService.cacheMedia(widget.videoUrl);
    } catch (e) {
      print('Background caching failed: $e');
    }
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
    } catch (e) {
      // Ignore disposal errors
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    return VisibilityDetector(
      key: Key('cached_video_${widget.postId ?? widget.videoUrl}'),
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
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
                _buildPlayPauseOverlay(),
                if (_showControls) _buildVideoControls(),
                _buildMuteButton(),
                if (_cachedFile != null) _buildCacheIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCacheIndicator() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: ColorManager.success.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.offline_pin_rounded,
              color: ColorManager.textPrimary,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'Cached',
              style: TextStyle(
                color: ColorManager.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;

    try {
      setState(() {
        _isVisible = info.visibleFraction > 0.5;
      });

      if (_isVisible && widget.autoPlay) {
        _controller.play();
      } else {
        _controller.pause();
      }
    } catch (e) {
      // Ignore setState errors during disposal
    }
  }

  void _toggleControls() {
    if (!mounted) return;

    try {
      setState(() {
        _showControls = !_showControls;
      });

      if (_showControls) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            try {
              setState(() {
                _showControls = false;
              });
            } catch (e) {
              // Ignore setState errors during disposal
            }
          }
        });
      }
    } catch (e) {
      // Ignore setState errors during disposal
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorManager.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading video...',
              style: TextStyle(
                color: ColorManager.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
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
    if (!mounted) return;

    try {
      setState(() {
        _hasError = false;
        _isInitialized = false;
      });
      _controller.dispose();
      _initializeVideo();
    } catch (e) {
      // Ignore setState errors during disposal
    }
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
              if (!mounted) return;

              try {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              } catch (e) {
                // Ignore setState errors during disposal
              }
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
            if (!mounted) return;

            try {
              setState(() {
                _controller.setVolume(_controller.value.volume == 0 ? 1.0 : 0.0);
              });
            } catch (e) {
              // Ignore setState errors during disposal
            }
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