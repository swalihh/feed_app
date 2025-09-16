import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/post.dart';
import '../entities/user.dart';
import '../entities/comment.dart';

abstract class FeedRepository {
  Future<Either<Failure, List<Post>>> getPosts({
    required int page,
    required int limit,
  });

  Future<Either<Failure, List<Comment>>> getComments(int postId);

  Future<Either<Failure, User>> getUser(int userId);

  Future<Either<Failure, Post>> likePost(int postId);

  Future<Either<Failure, Post>> unlikePost(int postId);

  Future<Either<Failure, Comment>> addComment({
    required int postId,
    required String name,
    required String email,
    required String body,
  });

  Future<Either<Failure, List<Post>>> getCachedPosts();

  Future<Either<Failure, void>> cachePosts(List<Post> posts);
}