import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/post.dart';
import '../repositories/feed_repository.dart';

class LikePost {
  final FeedRepository repository;

  LikePost(this.repository);

  Future<Either<Failure, Post>> call(LikePostParams params) async {
    return await repository.likePost(params.postId);
  }
}

class LikePostParams extends Equatable {
  final int postId;

  const LikePostParams({required this.postId});

  @override
  List<Object> get props => [postId];
}