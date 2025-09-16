import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/get_posts.dart';
import '../../domain/usecases/get_comments.dart';
import '../../domain/usecases/like_post.dart';
import '../../domain/usecases/unlike_post.dart';
import '../../domain/usecases/add_comment.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetPosts getPosts;
  final GetComments getComments;
  final LikePost likePost;
  final UnlikePost unlikePost;
  final AddComment addComment;

  static const int _postsPerPage = 10;
  int _currentPage = 1;

  FeedBloc({
    required this.getPosts,
    required this.getComments,
    required this.likePost,
    required this.unlikePost,
    required this.addComment,
  }) : super(const FeedInitial()) {
    on<LoadFeedEvent>(_onLoadFeed);
    on<LoadMorePostsEvent>(_onLoadMorePosts);
    on<LikePostEvent>(_onLikePost);
    on<UnlikePostEvent>(_onUnlikePost);
    on<AddCommentEvent>(_onAddComment);
    on<LoadCommentsEvent>(_onLoadComments);
  }

  Future<void> _onLoadFeed(
    LoadFeedEvent event,
    Emitter<FeedState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 1;
    } else {
      emit(const FeedLoading());
    }

    final result = await getPosts(GetPostsParams(
      page: _currentPage,
      limit: _postsPerPage,
    ));

    result.fold(
      (failure) => emit(FeedError(_mapFailureToMessage(failure))),
      (posts) {
        emit(FeedLoaded(
          posts: posts,
          hasReachedMax: posts.length < _postsPerPage,
        ));
        _currentPage++;
      },
    );
  }

  Future<void> _onLoadMorePosts(
    LoadMorePostsEvent event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedLoaded && !currentState.hasReachedMax) {
      emit(currentState.copyWith(isLoadingMore: true));

      final result = await getPosts(GetPostsParams(
        page: _currentPage,
        limit: _postsPerPage,
      ));

      result.fold(
        (failure) => emit(FeedError(_mapFailureToMessage(failure))),
        (newPosts) {
          final allPosts = List<Post>.from(currentState.posts)..addAll(newPosts);
          emit(FeedLoaded(
            posts: allPosts,
            hasReachedMax: newPosts.length < _postsPerPage,
            isLoadingMore: false,
          ));
          _currentPage++;
        },
      );
    }
  }

  Future<void> _onLikePost(
    LikePostEvent event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      emit(PostLikeUpdating(
        posts: currentState.posts,
        postId: event.postId,
      ));

      final result = await likePost(LikePostParams(postId: event.postId));

      result.fold(
        (failure) => emit(FeedError(_mapFailureToMessage(failure))),
        (_) {
          final updatedPosts = currentState.posts.map((post) {
            if (post.id == event.postId) {
              return post.copyWith(
                isLiked: true,
                likeCount: post.likeCount + 1,
              );
            }
            return post;
          }).toList();

          emit(PostLikeUpdated(
            posts: updatedPosts,
            postId: event.postId,
            isLiked: true,
          ));

          // Return to normal loaded state
          emit(FeedLoaded(
            posts: updatedPosts,
            hasReachedMax: currentState.hasReachedMax,
            isLoadingMore: currentState.isLoadingMore,
          ));
        },
      );
    }
  }

  Future<void> _onUnlikePost(
    UnlikePostEvent event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      emit(PostLikeUpdating(
        posts: currentState.posts,
        postId: event.postId,
      ));

      final result = await unlikePost(UnlikePostParams(postId: event.postId));

      result.fold(
        (failure) => emit(FeedError(_mapFailureToMessage(failure))),
        (_) {
          final updatedPosts = currentState.posts.map((post) {
            if (post.id == event.postId) {
              return post.copyWith(
                isLiked: false,
                likeCount: post.likeCount > 0 ? post.likeCount - 1 : 0,
              );
            }
            return post;
          }).toList();

          emit(PostLikeUpdated(
            posts: updatedPosts,
            postId: event.postId,
            isLiked: false,
          ));

          // Return to normal loaded state
          emit(FeedLoaded(
            posts: updatedPosts,
            hasReachedMax: currentState.hasReachedMax,
            isLoadingMore: currentState.isLoadingMore,
          ));
        },
      );
    }
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      emit(CommentAdding(
        posts: currentState.posts,
        postId: event.postId,
      ));

      final result = await addComment(AddCommentParams(
        postId: event.postId,
        comment: event.comment,
      ));

      result.fold(
        (failure) => emit(FeedError(_mapFailureToMessage(failure))),
        (comment) {
          final updatedPosts = currentState.posts.map((post) {
            if (post.id == event.postId) {
              return post.copyWith(
                commentCount: post.commentCount + 1,
                comments: [...post.comments, comment],
              );
            }
            return post;
          }).toList();

          emit(CommentAdded(
            posts: updatedPosts,
            postId: event.postId,
            comment: comment,
          ));

          // Return to normal loaded state
          emit(FeedLoaded(
            posts: updatedPosts,
            hasReachedMax: currentState.hasReachedMax,
            isLoadingMore: currentState.isLoadingMore,
          ));
        },
      );
    }
  }

  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedLoaded) {
      emit(CommentsLoading(
        posts: currentState.posts,
        postId: event.postId,
      ));

      final result = await getComments(GetCommentsParams(postId: event.postId));

      result.fold(
        (failure) => emit(FeedError(_mapFailureToMessage(failure))),
        (comments) {
          emit(CommentsLoaded(
            posts: currentState.posts,
            postId: event.postId,
            comments: comments,
          ));

          // Return to normal loaded state
          emit(FeedLoaded(
            posts: currentState.posts,
            hasReachedMax: currentState.hasReachedMax,
            isLoadingMore: currentState.isLoadingMore,
          ));
        },
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case CacheFailure:
        return failure.message;
      case NetworkFailure:
        return failure.message;
      case ValidationFailure:
        return failure.message;
      case UnknownFailure:
        return failure.message;
      default:
        return 'Unexpected error occurred';
    }
  }
}