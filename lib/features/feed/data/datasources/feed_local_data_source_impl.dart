import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../../core/error/exception.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import 'feed_local_data_source.dart';

class FeedLocalDataSourceImpl implements FeedLocalDataSource {
  static Database? _database;
  static const String tableName = 'posts';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'feed_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        user_data TEXT,
        imageUrl TEXT,
        videoUrl TEXT,
        createdAt TEXT NOT NULL,
        likeCount INTEGER DEFAULT 0,
        commentCount INTEGER DEFAULT 0,
        isLiked INTEGER DEFAULT 0,
        comments TEXT
      )
    ''');
  }

  @override
  Future<List<PostModel>> getCachedPosts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'createdAt DESC',
      );

      return maps.map((map) => _mapToPostModel(map)).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached posts: $e', statusCode: 500);
    }
  }

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    try {
      final db = await database;
      final batch = db.batch();

      for (final post in posts) {
        batch.insert(
          tableName,
          _postModelToMap(post),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();
    } catch (e) {
      throw CacheException(message: 'Failed to cache posts: $e', statusCode: 500);
    }
  }

  @override
  Future<void> cachePost(PostModel post) async {
    try {
      final db = await database;
      await db.insert(
        tableName,
        _postModelToMap(post),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache post: $e', statusCode: 500);
    }
  }

  @override
  Future<PostModel?> getCachedPost(int postId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [postId],
      );

      if (maps.isNotEmpty) {
        return _mapToPostModel(maps.first);
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached post: $e', statusCode: 500);
    }
  }

  @override
  Future<void> updateCachedPost(PostModel post) async {
    try {
      final db = await database;
      await db.update(
        tableName,
        _postModelToMap(post),
        where: 'id = ?',
        whereArgs: [post.id],
      );
    } catch (e) {
      throw CacheException(message: 'Failed to update cached post: $e', statusCode: 500);
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final db = await database;
      await db.delete(tableName);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e', statusCode: 500);
    }
  }

  Map<String, dynamic> _postModelToMap(PostModel post) {
    return {
      'id': post.id,
      'userId': post.userId,
      'title': post.title,
      'body': post.body,
      'user_data': post.userModel != null ? json.encode(post.userModel!.toJson()) : null,
      'imageUrl': post.imageUrl,
      'videoUrl': post.videoUrl,
      'createdAt': post.createdAt.toIso8601String(),
      'likeCount': post.likeCount,
      'commentCount': post.commentCount,
      'isLiked': post.isLiked ? 1 : 0,
      'comments': json.encode(post.comments.map((c) => (c as CommentModel).toJson()).toList()),
    };
  }

  PostModel _mapToPostModel(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      body: map['body'],
      userModel: map['user_data'] != null 
          ? UserModel.fromJson(json.decode(map['user_data']))
          : null,
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      likeCount: map['likeCount'],
      commentCount: map['commentCount'],
      isLiked: map['isLiked'] == 1,
      commentModels: map['comments'] != null
          ? (json.decode(map['comments']) as List)
              .map((c) => CommentModel.fromJson(c))
              .toList()
          : [],
    );
  }
}