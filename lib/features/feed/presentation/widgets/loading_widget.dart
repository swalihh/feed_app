import 'package:flutter/material.dart';
import '../../../../core/consts/color_manager.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.linear,
      ),
    );

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: ColorManager.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorManager.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PostCardSkeleton extends StatefulWidget {
  const PostCardSkeleton({Key? key}) : super(key: key);

  @override
  State<PostCardSkeleton> createState() => _PostCardSkeletonState();
}

class _PostCardSkeletonState extends State<PostCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ColorManager.cardGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorManager.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(
                          width: 48,
                          height: 48,
                          borderRadius: 24,
                          shimmerColor: ColorManager.shimmerBase,
                          highlightColor: ColorManager.shimmerHighlight,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(
                                width: 140,
                                height: 16,
                                borderRadius: 8,
                                shimmerColor: ColorManager.shimmerBase,
                                highlightColor: ColorManager.shimmerHighlight,
                              ),
                              const SizedBox(height: 8),
                              SkeletonBox(
                                width: 90,
                                height: 12,
                                borderRadius: 6,
                                shimmerColor: ColorManager.shimmerBase,
                                highlightColor: ColorManager.shimmerHighlight,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SkeletonBox(
                      width: double.infinity,
                      height: 20,
                      borderRadius: 10,
                      shimmerColor: ColorManager.shimmerBase,
                      highlightColor: ColorManager.shimmerHighlight,
                    ),
                    const SizedBox(height: 12),
                    SkeletonBox(
                      width: double.infinity,
                      height: 16,
                      borderRadius: 8,
                      shimmerColor: ColorManager.shimmerBase,
                      highlightColor: ColorManager.shimmerHighlight,
                    ),
                    const SizedBox(height: 12),
                    SkeletonBox(
                      width: 220,
                      height: 16,
                      borderRadius: 8,
                      shimmerColor: ColorManager.shimmerBase,
                      highlightColor: ColorManager.shimmerHighlight,
                    ),
                    const SizedBox(height: 20),

                    SkeletonBox(
                      width: double.infinity,
                      height: 220,
                      borderRadius: 16,
                      shimmerColor: ColorManager.shimmerBase,
                      highlightColor: ColorManager.shimmerHighlight,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        SkeletonBox(
                          width: 44,
                          height: 44,
                          borderRadius: 12,
                          shimmerColor: ColorManager.shimmerBase,
                          highlightColor: ColorManager.shimmerHighlight,
                        ),
                        const SizedBox(width: 12),
                        SkeletonBox(
                          width: 44,
                          height: 44,
                          borderRadius: 12,
                          shimmerColor: ColorManager.shimmerBase,
                          highlightColor: ColorManager.shimmerHighlight,
                        ),
                        const SizedBox(width: 12),
                        SkeletonBox(
                          width: 44,
                          height: 44,
                          borderRadius: 12,
                          shimmerColor: ColorManager.shimmerBase,
                          highlightColor: ColorManager.shimmerHighlight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(_slideAnimation.value - 1, 0),
                        end: Alignment(_slideAnimation.value + 1, 0),
                        colors: [
                          Colors.transparent,
                          ColorManager.primary.withOpacity(0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color shimmerColor;
  final Color highlightColor;

  const SkeletonBox({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
    required this.shimmerColor,
    required this.highlightColor,
  }) : super(key: key);

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              widget.shimmerColor,
              widget.highlightColor,
              _animation.value,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: ColorManager.border.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        );
      },
    );
  }
}