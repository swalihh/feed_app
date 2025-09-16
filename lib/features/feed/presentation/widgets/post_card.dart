import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/post.dart';
import 'cached_video_player_widget.dart';
import 'optimized_like_button.dart';
import '../../../../core/consts/color_manager.dart';
import '../pages/user_profile_page.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onUserTap;

  const PostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onUserTap,
  }) : super(key: key);

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: ColorManager.primary.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -10,
          ),
        ],
        border: Border.all(
          color: ColorManager.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          _buildUserHeader(context),

          // Post content
          _buildPostContent(),

          // Media content
          if (post.imageUrl != null || post.videoUrl != null)
            _buildMediaContent(),

          // Action buttons
          _buildActionButtons(context),

          // Post stats
          _buildPostStats(),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ColorManager.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.transparent,
                child: post.user?.name != null
                    ? Text(
                        post.user!.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: ColorManager.textPrimary,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        color: ColorManager.textPrimary,
                        size: 20,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onUserTap,
                      child: Text(
                        post.user?.name ?? 'Unknown User',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: ColorManager.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ColorManager.verified,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        color: ColorManager.textPrimary,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: ColorManager.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(post.createdAt),
                      style: TextStyle(
                        color: ColorManager.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ColorManager.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: ColorManager.textSecondary,
              ),
              onPressed: () {
                // TODO: Show post options
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: ColorManager.textPrimary,
              letterSpacing: -0.3,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            post.body.length > 200
                ? '${post.body.substring(0, 200)}...'
                : post.body,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: ColorManager.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: post.videoUrl != null
            ? AspectRatio(
                aspectRatio: 16 / 9, // Standard video aspect ratio
                child: CachedVideoPlayerWidget(
                  videoUrl: post.videoUrl!,
                  autoPlay: true,
                  postId: post.id.toString(),
                ),
              )
            : post.imageUrl != null
                ? AspectRatio(
                    aspectRatio: 4 / 3, // Standard image aspect ratio
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorManager.shimmerBase,
                              ColorManager.shimmerHighlight,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ColorManager.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorManager.surface,
                              ColorManager.surfaceVariant,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_rounded,
                                color: ColorManager.textTertiary,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: ColorManager.textTertiary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Row(
        children: [
          OptimizedLikeButton(
            initialIsLiked: post.isLiked,
            initialLikeCount: post.likeCount,
            onLike: onLike,
          ),
          const Spacer(),
          _buildActionButton(
            icon: Icons.bookmark_border_rounded,
            color: ColorManager.warning,
            backgroundColor: ColorManager.warning.withOpacity(0.1),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Bookmark functionality coming soon!'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: ColorManager.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: color.withOpacity(0.3), width: 1)
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildPostStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          // Comments container
          if (post.commentCount > 0)
            Expanded(
              child: GestureDetector(
                onTap: onComment,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorManager.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ColorManager.info.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_rounded,
                        color: ColorManager.info,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'View all ${post.commentCount} comments',
                          style: TextStyle(
                            color: ColorManager.info,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}