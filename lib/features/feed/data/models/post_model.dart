import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/user.dart';
import 'user_model.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel extends Post {
  @JsonKey(name: 'user')
  final UserModel? userModel;
  
  @JsonKey(name: 'comments')
  final List<CommentModel> commentModels;

  const PostModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    this.userModel,
    super.imageUrl,
    super.videoUrl,
    required super.createdAt,
    super.likeCount = 0,
    super.commentCount = 0,
    super.isLiked = false,
    this.commentModels = const [],
  }) : super(user: userModel, comments: commentModels);

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final postId = json['id'] as int;
    String? imageUrl;
    String? videoUrl;

    final mediaType = postId % 10;

    if (mediaType < 4) {
      final videoUrls = [
        'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
        'https://storage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
      ];
      videoUrl = videoUrls[postId % videoUrls.length];
    } else if (mediaType < 9) {
      final imageCategories = [
        'nature',
        'architecture',
        'people',
        'animals',
        'food',
        'technology',
        'travel',
        'art',
        'sports',
        'fashion'
      ];
      final category = imageCategories[postId % imageCategories.length];
      imageUrl = 'https://picsum.photos/400/300?random=${postId}&category=${category}';
    }

    return PostModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userModel: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now().subtract(Duration(hours: postId % 72)), // Posts from last 3 days
      likeCount: json['likeCount'] as int? ?? _generateLikeCount(postId, videoUrl != null),
      commentCount: json['commentCount'] as int? ?? _generateCommentCount(postId, videoUrl != null),
      isLiked: json['isLiked'] as bool? ?? false,
      commentModels: json['comments'] != null
          ? (json['comments'] as List)
              .map((comment) => CommentModel.fromJson(comment))
              .toList()
          : _generateMockComments(postId),
    );
  }

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  static int _generateLikeCount(int postId, bool isVideo) {
    final baseMultiplier = isVideo ? 1.5 : 1.0;
    final random = (postId * 7) % 100;
    return ((random * baseMultiplier) + (isVideo ? 10 : 5)).toInt();
  }

  static int _generateCommentCount(int postId, bool isVideo) {
    final baseMultiplier = isVideo ? 1.3 : 1.0;
    final random = (postId * 11) % 25;
    return ((random * baseMultiplier) + (isVideo ? 2 : 1)).toInt();
  }

  static List<CommentModel> _generateMockComments(int postId) {
    final commentCount = _generateCommentCount(postId, false);
    final comments = <CommentModel>[];

    final mockComments = [
      {'name': 'Alex Johnson', 'email': 'alex@example.com', 'body': 'Great post! Really enjoyed reading this.'},
      {'name': 'Sarah Chen', 'email': 'sarah@example.com', 'body': 'Thanks for sharing, very informative!'},
      {'name': 'Mike Rodriguez', 'email': 'mike@example.com', 'body': 'Love the content, keep it up! 👍'},
      {'name': 'Emily Davis', 'email': 'emily@example.com', 'body': 'This is exactly what I was looking for.'},
      {'name': 'David Wilson', 'email': 'david@example.com', 'body': 'Amazing quality, well done!'},
      {'name': 'Lisa Thompson', 'email': 'lisa@example.com', 'body': 'Can\'t wait to see more content like this.'},
      {'name': 'Ryan Foster', 'email': 'ryan@example.com', 'body': 'Fantastic work, really appreciate the effort.'},
      {'name': 'Anna Martinez', 'email': 'anna@example.com', 'body': 'This made my day, thank you!'},
      {'name': 'Chris Lee', 'email': 'chris@example.com', 'body': 'Beautifully done, loved every bit of it.'},
      {'name': 'Jessica Taylor', 'email': 'jessica@example.com', 'body': 'Outstanding content, please share more!'},
    ];

    for (int i = 0; i < commentCount && i < mockComments.length; i++) {
      final mockComment = mockComments[(postId + i) % mockComments.length];
      comments.add(CommentModel(
        id: (postId * 100) + i,
        postId: postId,
        name: mockComment['name']!,
        email: mockComment['email']!,
        body: mockComment['body']!,
        createdAt: DateTime.now().subtract(Duration(hours: i * 2)),
      ));
    }

    return comments;
  }

  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      userId: post.userId,
      title: post.title,
      body: post.body,
      userModel: post.user != null ? UserModel.fromEntity(post.user!) : null,
      imageUrl: post.imageUrl,
      videoUrl: post.videoUrl,
      createdAt: post.createdAt,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      isLiked: post.isLiked,
      commentModels: post.comments.map((comment) => CommentModel.fromEntity(comment)).toList(),
    );
  }

  @override
  PostModel copyWith({
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
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      userModel: user != null 
          ? (user is UserModel ? user : UserModel.fromEntity(user))
          : this.userModel,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      commentModels: comments?.map((comment) => 
        comment is CommentModel ? comment : CommentModel.fromEntity(comment)
      ).toList() ?? this.commentModels,
    );
  }
}

class CommentModel extends Comment {
  const CommentModel({
    required int id,
    required int postId,
    required String name,
    required String email,
    required String body,
    required DateTime createdAt,
  }) : super(
          id: id,
          postId: postId,
          name: name,
          email: email,
          body: body,
          createdAt: createdAt,
        );

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      postId: json['postId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'name': name,
      'email': email,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      postId: comment.postId,
      name: comment.name,
      email: comment.email,
      body: comment.body,
      createdAt: comment.createdAt,
    );
  }
}