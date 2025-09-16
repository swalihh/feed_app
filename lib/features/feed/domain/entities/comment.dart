import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, postId, name, email, body, createdAt];
}