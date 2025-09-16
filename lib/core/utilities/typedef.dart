import 'package:dartz/dartz.dart';



import '../error/failures.dart';

typedef ResultFuture<T> = Future<Either<Failure,T>>;