import 'package:flutter/material.dart';
import '../../../../core/consts/color_manager.dart';

class OptimizedLikeButton extends StatefulWidget {
  final bool initialIsLiked;
  final int initialLikeCount;
  final VoidCallback onLike;

  const OptimizedLikeButton({
    Key? key,
    required this.initialIsLiked,
    required this.initialLikeCount,
    required this.onLike,
  }) : super(key: key);

  @override
  State<OptimizedLikeButton> createState() => _OptimizedLikeButtonState();
}

class _OptimizedLikeButtonState extends State<OptimizedLikeButton>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked;
    _likeCount = widget.initialLikeCount;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    // Animate the like button
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Like button with animation
        ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: _handleLike,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isLiked
                    ? ColorManager.accent.withOpacity(0.1)
                    : ColorManager.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: _isLiked
                    ? Border.all(color: ColorManager.accent.withOpacity(0.3), width: 1)
                    : null,
                boxShadow: _isLiked
                    ? [
                        BoxShadow(
                          color: ColorManager.accent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isLiked ? ColorManager.accent : ColorManager.textSecondary,
                size: 22,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Like count display
        if (_likeCount > 0)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.accent.withOpacity(0.1),
                  ColorManager.primary.withOpacity(0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ColorManager.accent.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  color: ColorManager.accent,
                  size: 16,
                ),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    key: ValueKey(_likeCount),
                    '$_likeCount ${_likeCount == 1 ? 'like' : 'likes'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: ColorManager.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}