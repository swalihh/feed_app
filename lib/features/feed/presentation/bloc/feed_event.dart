import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedEvent extends FeedEvent {
  final bool isRefresh;

  const LoadFeedEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class LoadMorePostsEvent extends FeedEvent {
  const LoadMorePostsEvent();
}

class LikePostEvent extends FeedEvent {
  final int postId;

  const LikePostEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class UnlikePostEvent extends FeedEvent {
  final int postId;

  const UnlikePostEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}

class AddCommentEvent extends FeedEvent {
  final int postId;
  final String comment;

  const AddCommentEvent({
    required this.postId,
    required this.comment,
  });

  @override
  List<Object?> get props => [postId, comment];
}

class LoadCommentsEvent extends FeedEvent {
  final int postId;

  const LoadCommentsEvent(this.postId);

  @override
  List<Object?> get props => [postId];
}