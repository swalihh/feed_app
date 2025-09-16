import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/interceptor/app_dio.dart';
import 'core/services/cache_services.dart';
import 'core/network/network_info.dart';

// Features - Feed
import 'features/feed/data/datasources/feed_remote_data_source.dart';
import 'features/feed/data/datasources/feed_remote_data_source_impl.dart';
import 'features/feed/data/datasources/feed_local_data_source.dart';
import 'features/feed/data/datasources/feed_local_data_source_impl.dart';
import 'features/feed/data/repositories/feed_repository_impl.dart';
import 'features/feed/domain/repositories/feed_repository.dart';
import 'features/feed/domain/usecases/get_posts.dart';
import 'features/feed/domain/usecases/get_comments.dart';
import 'features/feed/domain/usecases/like_post.dart';
import 'features/feed/domain/usecases/unlike_post.dart';
import 'features/feed/domain/usecases/add_comment.dart';
import 'features/feed/presentation/bloc/feed_bloc.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // External dependencies
  locator.registerLazySingleton(() => http.Client());
  locator.registerLazySingleton(() => Connectivity());
  
  // Core
  locator.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(locator()),
  );
  locator.registerLazySingleton<CacheService>(() => CacheService());
  locator.registerLazySingleton<Dio>(() => Api().dio);

  // Data sources
  locator.registerLazySingleton<FeedRemoteDataSource>(
    () => FeedRemoteDataSourceImpl(client: locator()),
  );
  
  locator.registerLazySingleton<FeedLocalDataSource>(
    () => FeedLocalDataSourceImpl(),
  );

  // Repository
  locator.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(
      remoteDataSource: locator(),
      localDataSource: locator(),
      connectivity: locator(),
    ),
  );

  // Use cases
  locator.registerLazySingleton(() => GetPosts(locator()));
  locator.registerLazySingleton(() => GetComments(locator()));
  locator.registerLazySingleton(() => LikePost(locator()));
  locator.registerLazySingleton(() => UnlikePost(locator()));
  locator.registerLazySingleton(() => AddComment(locator()));

  // BLoCs
  locator.registerFactory(
    () => FeedBloc(
      getPosts: locator(),
      getComments: locator(),
      likePost: locator(),
      unlikePost: locator(),
      addComment: locator(),
    ),
  );
}
