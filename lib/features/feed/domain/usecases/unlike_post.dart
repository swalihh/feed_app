import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/post.dart';
import '../repositories/feed_repository.dart';

class UnlikePost {
  final FeedRepository repository;

  UnlikePost(this.repository);

  Future<Either<Failure, Post>> call(UnlikePostParams params) async {
    return await repository.unlikePost(params.postId);
  }
}

class UnlikePostParams extends Equatable {
  final int postId;

  const UnlikePostParams({required this.postId});

  @override
  List<Object> get props => [postId];
}