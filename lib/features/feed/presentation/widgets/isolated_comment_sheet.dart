import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import '../../domain/entities/comment.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';

class IsolatedCommentSheet extends StatefulWidget {
  final int postId;
  final FeedBloc feedBloc;

  const IsolatedCommentSheet({
    Key? key,
    required this.postId,
    required this.feedBloc,
  }) : super(key: key);

  @override
  State<IsolatedCommentSheet> createState() => _IsolatedCommentSheetState();
}

class _IsolatedCommentSheetState extends State<IsolatedCommentSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = true;
  String? _error;
  List<Comment> _comments = [];
  String _currentText = '';

  StreamSubscription<FeedState>? _stateSubscription;

  // Hardcoded colors to avoid any context dependencies
  static const Color _background = Color(0xFF0F0F23);
  static const Color _surface = Color(0xFF1E1E3F);
  static const Color _surfaceVariant = Color(0xFF2A2A4A);
  static const Color _primary = Color(0xFF6C5CE7);
  static const Color _accent = Color(0xFF764BA2);
  static const Color _textPrimary = Color(0xFFE1E3E6);
  static const Color _textSecondary = Color(0xFFB0B3B8);
  static const Color _textTertiary = Color(0xFF888899);
  static const Color _border = Color(0xFF444466);
  static const Color _success = Color(0xFF00D2AA);

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _stateSubscription = widget.feedBloc.stream.listen(_onStateChanged);

    // Load comments
    _loadComments();
  }

  void _onFocusChanged() {
    // Trigger rebuild when focus changes to adjust for keyboard
    if (mounted) {
      setState(() {});
    }
  }

  void _onTextChanged() {
    if (mounted && _controller.text != _currentText) {
      setState(() {
        _currentText = _controller.text;
      });
    }
  }

  void _loadComments() {
    if (mounted) {
      widget.feedBloc.add(LoadCommentsEvent(widget.postId));
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

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && mounted) {
      widget.feedBloc.add(
        AddCommentEvent(
          postId: widget.postId,
          comment: text,
        ),
      );
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_surface, _background],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 30,
              offset: Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildDragHandle(),
              _buildHeader(),
              Expanded(child: _buildCommentsList()),
              _buildCommentInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: _textTertiary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 20, 20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: _textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Comments',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: _surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                if (mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.close_rounded,
                color: _textSecondary,
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
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: _textTertiary),
            const SizedBox(height: 16),
            const Text(
              'Failed to load comments',
              style: TextStyle(fontSize: 16, color: _textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadComments,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: _textPrimary,
              ),
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
                  colors: [
                    _primary.withOpacity(0.1),
                    _accent.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _primary.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: _primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No comments yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to comment!',
              style: TextStyle(fontSize: 14, color: _textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _comments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildCommentItem(_comments[index]),
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
            _surface.withOpacity(0.8),
            _surfaceVariant.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00CEC9), Color(0xFF74B9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Text(
                comment.name.isNotEmpty ? comment.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _textPrimary,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: _textPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _textTertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatTimeAgo(comment.createdAt),
                        style: const TextStyle(
                          color: _textTertiary,
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
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: _textSecondary,
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

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _border, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _surfaceVariant,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(color: _textTertiary, fontSize: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                    borderSide: BorderSide(color: _primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  filled: false,
                ),
                style: const TextStyle(color: _textPrimary, fontSize: 15, height: 1.4),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: _currentText.trim().isNotEmpty
                  ? const LinearGradient(
                      colors: [_primary, _accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: _currentText.trim().isEmpty ? _surfaceVariant : null,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _currentText.trim().isNotEmpty
                  ? [
                      BoxShadow(
                        color: _primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              onPressed: _currentText.trim().isEmpty ? null : _submitComment,
              icon: Icon(
                Icons.send_rounded,
                color: _currentText.trim().isNotEmpty ? _textPrimary : _textTertiary,
              ),
              iconSize: 22,
            ),
          ),
        ],
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