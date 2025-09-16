import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exception.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import 'feed_remote_data_source.dart';

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final http.Client client;
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  FeedRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PostModel>> getPosts({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/posts?_page=$page&_limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => PostModel.fromJson(json)).toList();
      } else {
        throw APIException(message: 'Failed to fetch posts', statusCode: response.statusCode);
      }
    } catch (e) {
      throw APIException(message: 'Network error: $e', statusCode: 500);
    }
  }

  @override
  Future<List<CommentModel>> getComments(int postId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => CommentModel.fromJson(json)).toList();
      } else {
        throw APIException(message: 'Failed to fetch comments', statusCode: response.statusCode);
      }
    } catch (e) {
      throw APIException(message: 'Network error: $e', statusCode: 500);
    }
  }

  @override
  Future<UserModel> getUser(int userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return UserModel.fromJson(jsonMap);
      } else {
        throw APIException(message: 'Failed to fetch user', statusCode: response.statusCode);
      }
    } catch (e) {
      throw APIException(message: 'Network error: $e', statusCode: 500);
    }
  }

  @override
  Future<PostModel> likePost(int postId) async {
    // Simulate API call for liking a post
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app, this would make an actual API call
      // For now, we'll return a mock response
      final mockPost = PostModel(
        id: postId,
        userId: 1,
        title: 'Mock Post',
        body: 'Mock body',
        createdAt: DateTime.now(),
        likeCount: 1,
        isLiked: true,
      );
      
      return mockPost;
    } catch (e) {
      throw APIException(message: 'Failed to like post: $e', statusCode: 500);
    }
  }

  @override
  Future<PostModel> unlikePost(int postId) async {
    // Simulate API call for unliking a post
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app, this would make an actual API call
      final mockPost = PostModel(
        id: postId,
        userId: 1,
        title: 'Mock Post',
        body: 'Mock body',
        createdAt: DateTime.now(),
        likeCount: 0,
        isLiked: false,
      );
      
      return mockPost;
    } catch (e) {
      throw APIException(message: 'Failed to unlike post: $e', statusCode: 500);
    }
  }

  @override
  Future<CommentModel> addComment({
    required int postId,
    required String name,
    required String email,
    required String body,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'postId': postId,
          'name': name,
          'email': email,
          'body': body,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return CommentModel.fromJson({
          ...jsonMap,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } else {
        throw APIException(message: 'Failed to add comment', statusCode: response.statusCode);
      }
    } catch (e) {
      throw APIException(message: 'Network error: $e', statusCode: 500);
    }
  }
}