import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utilities/typedef.dart';
import '../entities/post.dart';
import '../repositories/feed_repository.dart';

class GetPosts {
  final FeedRepository repository;

  GetPosts(this.repository);

  Future<Either<Failure, List<Post>>> call(GetPostsParams params) async {
    return await repository.getPosts(
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetPostsParams extends Equatable {
  final int page;
  final int limit;

  const GetPostsParams({
    required this.page,
    required this.limit,
  });

  @override
  List<Object> get props => [page, limit];
}