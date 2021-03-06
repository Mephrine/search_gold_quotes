import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:search_gold_quotes/app/domain/entities/version_info.dart';
import 'package:search_gold_quotes/app/domain/usecases/get_version_info.dart';
import 'package:search_gold_quotes/app/presentation/pages/intro/bloc/bloc.dart';
import 'package:search_gold_quotes/core/error/failures.dart';
import 'package:search_gold_quotes/core/usecases/no_params.dart';
import 'package:search_gold_quotes/core/error/error_messages.dart';
import 'package:search_gold_quotes/core/values/strings.dart';

class MockGetVersionInfo extends Mock implements GetVersionInfo {}

void main() {
  SplashBloc splashBloc;
  MockGetVersionInfo mockGetVersionInfo;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockGetVersionInfo = MockGetVersionInfo();
    splashBloc = SplashBloc(versionInfo: mockGetVersionInfo);
  });

  test('isInitialize', () {
    expect(splashBloc.initialState, Empty());
  });

  tearDown(() {
    mockGetVersionInfo = null;
    splashBloc = null;
  });

  group('GetVersionInfoForUpdate', () {
    // Input값 체크 및 호출 성공, 실패 케이스, usecase성공, usecase 실패, 성공한 경우의 상태 변화, 실패한 경우의 상태 변화
    final versionInfoModel =
        VersionInfo(latestVersion: '1.0.0', appVersionSeq: 1);
    test('should get data from the get version info usecase', () async {
      // arrange
      when(mockGetVersionInfo(any))
          .thenAnswer((_) async => Right(versionInfoModel));

      // act
      splashBloc.add(GetVersionInfoForUpdate());
      await untilCalled(mockGetVersionInfo(any));

      // assert
      verify(mockGetVersionInfo(NoParams()));
    });

    test('should get error when getting data fail', () async {
      // arrange
      when(mockGetVersionInfo(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      // act
      splashBloc.add(GetVersionInfoForUpdate());
      await untilCalled(mockGetVersionInfo(any));

      // assert
      verify(mockGetVersionInfo(NoParams()));
    });

    test('should emit [Loading, Error] when getting data fail', () async {
      // arrange
      when(mockGetVersionInfo(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      // act
      splashBloc.add(GetVersionInfoForUpdate());

      // assert
      final expected = [Loading(), Error(message: SERVER_FAILURE_MESSAGE)];

      expectLater(splashBloc, emitsInOrder(expected));
    });

    test('should emit [Loading, Loaded] when getting data success', () async {
      // arrange
      when(mockGetVersionInfo(any))
          .thenAnswer((_) async => Right(versionInfoModel));

      // act
      splashBloc.add(GetVersionInfoForUpdate());

      // assert
      final expected = [
        Loading(),
        Loaded(
            needsForceUpdate: false,
            updateMessage: Strings.appUpdateAlertMessage)
      ];

      expectLater(splashBloc, emitsInOrder(expected));
    });
  });

  group('버전 비교', () {
    test('currentVersion이 높은 경우 true를 반환해야한다.', () async {
      final currentVersion = '1.0.1';
      final latestVersion = '1.0';

      final result =
          splashBloc.currentVersionIsLatest(currentVersion, latestVersion);

      expect(result, true);
    });

    test('currentVersion이 높은 경우 true를 반환해야한다.', () async {
      final currentVersion = '1.0.1';
      final latestVersion = '1.0';

      final result =
          splashBloc.currentVersionIsLatest(currentVersion, latestVersion);

      expect(result, true);
    });

    test('latestVersion이 높은 경우 false를 반환해야한다.', () async {
      final currentVersion = '1.0.0';
      final latestVersion = '1.0.1';

      final result =
          splashBloc.currentVersionIsLatest(currentVersion, latestVersion);

      expect(result, false);
    });

    test('currentVersion의 자릿수가 더 큰 경우 true를 반환해야한다.', () async {
      final currentVersion = '1.0.0.0';
      final latestVersion = '1.0.0';

      final result =
          splashBloc.currentVersionIsLatest(currentVersion, latestVersion);

      expect(result, true);
    });

    test('latestVersion의 자릿수가 더 큰지만 동일한 값인 경우 true를 반환해야한다.', () async {
      final currentVersion = '1.0.0';
      final latestVersion = '1.0.0.0';

      final result =
          splashBloc.currentVersionIsLatest(currentVersion, latestVersion);

      expect(result, true);
    });

    test('latestVersion의 자릿수가 더 큰 경우 false를 반환해야한다.', () async {
      final currentVersion = '1.0.0';
      final latestVersion = '1.0.0.1';

      final result =
          splashBloc.currentVersionIsLatest(currentVersion, latestVersion);

      expect(result, false);
    });

    test('값이 동일한 경우 true를 반환해야한다.', () async {
      final currentVersion = '1.0.0';
      final latestVersion = '1.0.0';

      final result =
          splashBloc.currentVersionIsLatest(currentVersion, latestVersion);

      expect(result, true);
    });
  });
}
