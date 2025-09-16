import '../models/post_model.dart';
import '../models/user_model.dart';

abstract class FeedRemoteDataSource {
  Future<List<PostModel>> getPosts({
    required int page,
    required int limit,
  });

  Future<List<CommentModel>> getComments(int postId);

  Future<UserModel> getUser(int userId);

  Future<PostModel> likePost(int postId);

  Future<PostModel> unlikePost(int postId);

  Future<CommentModel> addComment({
    required int postId,
    required String name,
    required String email,
    required String body,
  });
}