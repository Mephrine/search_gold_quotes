import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:search_gold_quotes/app/domain/entities/version_info.dart';
import 'package:search_gold_quotes/app/domain/repositories/version_repository.dart';
import 'package:search_gold_quotes/app/domain/usecases/get_version_info.dart';
import 'package:search_gold_quotes/core/usecases/no_params.dart';


class MockVersionRepository extends Mock implements VersionRepository {}

void main() {
  GetVersionInfo usecase;
  MockVersionRepository mockVersionRepository;

  setUp(() {
    mockVersionRepository = MockVersionRepository();
    usecase = GetVersionInfo(repository: mockVersionRepository);
  });

  group('GetVersionInfo', () {
    final testVersionInfo = VersionInfo(latestVersion: "1.0.0", appVersionSeq: 1);
    test('should get latest version when splash page called api', () async {

      // arrange
      when(mockVersionRepository.getVersionInfo())
          .thenAnswer((_) async => Right(testVersionInfo));
      // act
      final result = await usecase.call(NoParams());

      // assert
      expect(result, Right(testVersionInfo));
      verify(usecase.repository.getVersionInfo());
      verifyNoMoreInteractions(usecase.repository);
    });
  });


}