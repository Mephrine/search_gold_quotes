import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:search_gold_quotes/app/domain/entities/video_items.dart';
import 'package:search_gold_quotes/app/domain/repositories/video_repository.dart';
import 'package:search_gold_quotes/core/error/failures.dart';
import 'package:search_gold_quotes/core/usecases/no_params.dart';
import 'package:search_gold_quotes/core/usecases/usecase.dart';

class GetVideoList extends UseCase<VideoList, NoParams> {
  final VideoRepository repository;

  GetVideoList({@required this.repository});

  @override
  Future<Either<Failure, VideoList>> call(NoParams params) async {
    return await repository.getVideoList();
  }
}
