import 'dart:async';
import 'package:feeds_task/features/feed/presentation/bloc/feed_event.dart';
import 'package:feeds_task/features/feed/presentation/bloc/feed_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import '../../domain/entities/comment.dart';
import '../bloc/feed_bloc.dart';
import 'loading_widget.dart';
import 'isolated_comment_input.dart';
import '../../../../core/consts/color_manager.dart';

class CommentBottomSheet extends StatefulWidget {
  final int postId;

  const CommentBottomSheet({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  late final FeedBloc _feedBloc;

  // Local state management instead of relying on BlocBuilder
  bool _isLoading = true;
  String? _error;
  List<Comment> _comments = [];

  StreamSubscription<FeedState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    _feedBloc = context.read<FeedBloc>();

    // Listen to state changes manually
    _stateSubscription = _feedBloc.stream.listen(_onStateChanged);

    // Load comments when sheet opens
    _loadComments();
  }

  void _loadComments() {
    if (mounted) {
      _feedBloc.add(LoadCommentsEvent(widget.postId));
    }
  }

  void _onStateChanged(FeedState state) {
    if (!mounted) return;

    try {
      if (state is FeedLoaded) {
        final post = state.posts.where((post) => post.id == widget.postId).firstOrNull;
        if (post != null) {
          setState(() {
            _isLoading = false;
            _error = null;
            _comments = post.comments;
          });
        }
      } else if (state is FeedError) {
        setState(() {
          _isLoading = false;
          _error = state.message;
        });
      } else if (state is FeedLoading) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }
    } catch (e) {
      // Ignore setState errors during disposal
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: (MediaQuery.maybeOf(context)?.size.height ?? 800) * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorManager.cardBackground,
            ColorManager.backgroundSecondary,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        border: Border.all(
          color: ColorManager.border.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(),
          Expanded(
            child: _buildCommentsList(),
          ),
          IsolatedCommentInput(
            onSubmit: (comment) {
              if (mounted) {
                _submitComment(comment);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: ColorManager.textTertiary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 20, 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ColorManager.divider.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: ColorManager.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              color: ColorManager.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Comments',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: ColorManager.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: ColorManager.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                if (mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                Icons.close_rounded,
                color: ColorManager.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_isLoading) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load comments',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  _loadComments();
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ColorManager.primaryGradient.map((c) => c.withOpacity(0.1)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ColorManager.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: ColorManager.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorManager.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to comment!',
              style: TextStyle(
                fontSize: 14,
                color: ColorManager.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _comments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildCommentItem(_comments[index]);
      },
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorManager.surface.withOpacity(0.8),
            ColorManager.surfaceVariant.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorManager.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorManager.secondary,
                  ColorManager.secondaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.secondary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Text(
                comment.name.isNotEmpty
                    ? comment.name[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: ColorManager.textPrimary,
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
                    Flexible(
                      child: Text(
                        comment.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: ColorManager.textPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorManager.textTertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatTimeAgo(comment.createdAt),
                        style: TextStyle(
                          color: ColorManager.textTertiary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.body,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: ColorManager.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _submitComment(String content) {
    if (!mounted || content.trim().isEmpty) return;

    _feedBloc.add(
      AddCommentEvent(
        postId: widget.postId,
        comment: content.trim(),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}