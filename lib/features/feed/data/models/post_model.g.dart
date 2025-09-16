// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  title: json['title'] as String,
  body: json['body'] as String,
  userModel: json['user'] == null
      ? null
      : UserModel.fromJson(json['user'] as Map<String, dynamic>),
  imageUrl: json['imageUrl'] as String?,
  videoUrl: json['videoUrl'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
  commentModels:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'body': instance.body,
  'imageUrl': instance.imageUrl,
  'videoUrl': instance.videoUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'likeCount': instance.likeCount,
  'commentCount': instance.commentCount,
  'isLiked': instance.isLiked,
  'user': instance.userModel,
  'comments': instance.commentModels,
};
