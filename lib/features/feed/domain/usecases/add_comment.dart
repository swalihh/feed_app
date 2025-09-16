import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/comment.dart';
import '../repositories/feed_repository.dart';

class AddComment {
  final FeedRepository repository;

  AddComment(this.repository);

  Future<Either<Failure, Comment>> call(AddCommentParams params) async {
    return await repository.addComment(
      postId: params.postId,
      name: 'Anonymous User', // Default name for now
      email: 'user@example.com', // Default email for now
      body: params.comment,
    );
  }
}

class AddCommentParams extends Equatable {
  final int postId;
  final String comment;

  const AddCommentParams({
    required this.postId,
    required this.comment,
  });

  @override
  List<Object> get props => [postId, comment];
}