import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import 'post_card.dart';
import '../pages/user_profile_page.dart';

class PostItemWidget extends StatefulWidget {
  final Post post;
  final FeedBloc feedBloc;
  final VoidCallback onComment;

  const PostItemWidget({
    Key? key,
    required this.post,
    required this.feedBloc,
    required this.onComment,
  }) : super(key: key);

  @override
  State<PostItemWidget> createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  late ValueNotifier<bool> _isLikedNotifier;
  late ValueNotifier<int> _likeCountNotifier;

  @override
  void initState() {
    super.initState();
    _isLikedNotifier = ValueNotifier<bool>(widget.post.isLiked);
    _likeCountNotifier = ValueNotifier<int>(widget.post.likeCount);
  }

  @override
  void dispose() {
    _isLikedNotifier.dispose();
    _likeCountNotifier.dispose();
    super.dispose();
  }

  void _handleLike() {
    final wasLiked = _isLikedNotifier.value;
    _isLikedNotifier.value = !wasLiked;
    _likeCountNotifier.value += wasLiked ? -1 : 1;
  }

  void _handleUserTap() {
    if (widget.post.user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(user: widget.post.user!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLikedNotifier,
      builder: (context, isLiked, child) {
        return ValueListenableBuilder<int>(
          valueListenable: _likeCountNotifier,
          builder: (context, likeCount, child) {
            final updatedPost = Post(
              id: widget.post.id,
              userId: widget.post.userId,
              title: widget.post.title,
              body: widget.post.body,
              user: widget.post.user,
              imageUrl: widget.post.imageUrl,
              videoUrl: widget.post.videoUrl,
              createdAt: widget.post.createdAt,
              likeCount: likeCount,
              commentCount: widget.post.commentCount,
              isLiked: isLiked,
              comments: widget.post.comments,
            );

            return PostCard(
              post: updatedPost,
              onLike: _handleLike,
              onComment: widget.onComment,
              onUserTap: _handleUserTap,
            );
          },
        );
      },
    );
  }
}