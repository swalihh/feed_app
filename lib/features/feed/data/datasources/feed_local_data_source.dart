import '../models/post_model.dart';

abstract class FeedLocalDataSource {
  Future<List<PostModel>> getCachedPosts();
  Future<void> cachePosts(List<PostModel> posts);
  Future<void> cachePost(PostModel post);
  Future<PostModel?> getCachedPost(int postId);
  Future<void> updateCachedPost(PostModel post);
  Future<void> clearCache();
}