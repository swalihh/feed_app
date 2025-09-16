import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exception.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_local_data_source.dart';
import '../datasources/feed_remote_data_source.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;
  final FeedLocalDataSource localDataSource;
  final Connectivity connectivity;

  FeedRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, List<Post>>> getPosts({
    required int page,
    required int limit,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        // No internet, return cached posts
        final cachedPosts = await localDataSource.getCachedPosts();
        return Right(cachedPosts);
      }

      // Fetch from remote
      final remotePosts = await remoteDataSource.getPosts(
        page: page,
        limit: limit,
      );

      // Fetch user data for each post
      final postsWithUsers = <PostModel>[];
      for (final post in remotePosts) {
        try {
          final user = await remoteDataSource.getUser(post.userId);
          final postWithUser = post.copyWith(user: user);
          postsWithUsers.add(postWithUser);
        } catch (e) {
          // If user fetch fails, add post without user data
          postsWithUsers.add(post);
        }
      }

      // Cache the posts
      await localDataSource.cachePosts(postsWithUsers);

      return Right(postsWithUsers);
    } on APIException catch (e) {
      // If server fails, try to return cached data
      try {
        final cachedPosts = await localDataSource.getCachedPosts();
        if (cachedPosts.isNotEmpty) {
          return Right(cachedPosts);
        }
      } catch (_) {}
      
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getComments(int postId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(NetworkFailure('No internet connection'));
      }

      final comments = await remoteDataSource.getComments(postId);
      return Right(comments);
    } on APIException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getUser(int userId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(NetworkFailure('No internet connection'));
      }

      final user = await remoteDataSource.getUser(userId);
      return Right(user);
    } on APIException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Post>> likePost(int postId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(NetworkFailure('No internet connection'));
      }

      final post = await remoteDataSource.likePost(postId);

      // Update cached post
      final cachedPost = await localDataSource.getCachedPost(postId);
      if (cachedPost != null) {
        final updatedPost = cachedPost.copyWith(
          isLiked: true,
          likeCount: cachedPost.likeCount + 1,
        );
        await localDataSource.updateCachedPost(updatedPost);
      }

      return Right(post);
    } on APIException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Post>> unlikePost(int postId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return Left(NetworkFailure('No internet connection'));
      }

      final post = await remoteDataSource.unlikePost(postId);

      // Update cached post
      final cachedPost = await localDataSource.getCachedPost(postId);
      if (cachedPost != null) {
        final updatedPost = cachedPost.copyWith(
          isLiked: false,
          likeCount: cachedPost.likeCount - 1,
        );
        await localDataSource.updateCachedPost(updatedPost);
      }

      return Right(post);
    } on APIException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment({
    required int postId,
    required String name,
    required String email,
    required String body,
  }) async {
    try {
      final comment = await remoteDataSource.addComment(
        postId: postId,
        name: name,
        email: email,
        body: body,
      );

      // Update cached post comment count
      final cachedPost = await localDataSource.getCachedPost(postId);
      if (cachedPost != null) {
        final updatedPost = cachedPost.copyWith(
          commentCount: cachedPost.commentCount + 1,
          comments: [...cachedPost.comments, CommentModel.fromEntity(comment)],
        );
        await localDataSource.updateCachedPost(updatedPost);
      }

      return Right(comment as Comment);
    } on APIException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getCachedPosts() async {
    try {
      final cachedPosts = await localDataSource.getCachedPosts();
      return Right(cachedPosts);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cachePosts(List<Post> posts) async {
    try {
      final postModels = posts.map((post) => PostModel.fromEntity(post)).toList();
      await localDataSource.cachePosts(postModels);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unexpected error: $e'));
    }
  }
}