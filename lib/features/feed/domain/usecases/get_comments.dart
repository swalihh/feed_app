import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/post.dart';
import '../entities/comment.dart';
import '../repositories/feed_repository.dart';

class GetComments {
  final FeedRepository repository;

  GetComments(this.repository);

  Future<Either<Failure, List<Comment>>> call(GetCommentsParams params) async {
    return await repository.getComments(params.postId);
  }
}

class GetCommentsParams extends Equatable {
  final int postId;

  const GetCommentsParams({required this.postId});

  @override
  List<Object> get props => [postId];
}