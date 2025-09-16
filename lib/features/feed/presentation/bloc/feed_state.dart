import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';

abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedLoaded extends FeedState {
  final List<Post> posts;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const FeedLoaded({
    required this.posts,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  FeedLoaded copyWith({
    List<Post>? posts,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return FeedLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [posts, hasReachedMax, isLoadingMore];
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object?> get props => [message];
}

class PostLikeUpdating extends FeedState {
  final List<Post> posts;
  final int postId;

  const PostLikeUpdating({
    required this.posts,
    required this.postId,
  });

  @override
  List<Object?> get props => [posts, postId];
}

class PostLikeUpdated extends FeedState {
  final List<Post> posts;
  final int postId;
  final bool isLiked;

  const PostLikeUpdated({
    required this.posts,
    required this.postId,
    required this.isLiked,
  });

  @override
  List<Object?> get props => [posts, postId, isLiked];
}

class CommentAdding extends FeedState {
  final List<Post> posts;
  final int postId;

  const CommentAdding({
    required this.posts,
    required this.postId,
  });

  @override
  List<Object?> get props => [posts, postId];
}

class CommentAdded extends FeedState {
  final List<Post> posts;
  final int postId;
  final Comment comment;

  const CommentAdded({
    required this.posts,
    required this.postId,
    required this.comment,
  });

  @override
  List<Object?> get props => [posts, postId, comment];
}

class CommentsLoading extends FeedState {
  final List<Post> posts;
  final int postId;

  const CommentsLoading({
    required this.posts,
    required this.postId,
  });

  @override
  List<Object?> get props => [posts, postId];
}

class CommentsLoaded extends FeedState {
  final List<Post> posts;
  final int postId;
  final List<Comment> comments;

  const CommentsLoaded({
    required this.posts,
    required this.postId,
    required this.comments,
  });

  @override
  List<Object?> get props => [posts, postId, comments];
}