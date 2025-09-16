import 'package:equatable/equatable.dart';
import 'user.dart';
import 'comment.dart';

class Post extends Equatable {
  final int id;
  final int userId;
  final String title;
  final String body;
  final User? user;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final List<Comment> comments;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.user,
    this.imageUrl,
    this.videoUrl,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.comments = const [],
  });

  Post copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
    User? user,
    String? imageUrl,
    String? videoUrl,
    DateTime? createdAt,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      user: user ?? this.user,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        user,
        imageUrl,
        videoUrl,
        createdAt,
        likeCount,
        commentCount,
        isLiked,
        comments,
      ];
}