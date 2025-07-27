import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pause_pulse/domain/entities/app_info.dart';
import 'package:pause_pulse/domain/repositories/app_repository.dart';
import 'package:pause_pulse/domain/usecases/get_apps_usecase.dart';

class MockAppRepository extends Mock implements AppRepository {}

void main() {
  late GetAppsUseCase useCase;
  late MockAppRepository mockAppRepository;

  setUp(() {
    mockAppRepository = MockAppRepository();
    useCase = GetAppsUseCase(mockAppRepository);
  });

  group('GetAppsUseCase', () {
    const mockApps = [
      AppInfo(
        packageName: 'com.example.app1',
        appName: 'App 1',
        iconPath: null,
        isNotificationEnabled: true,
      ),
      AppInfo(
        packageName: 'com.example.app2',
        appName: 'App 2',
        iconPath: null,
        isNotificationEnabled: false,
      ),
    ];

    test('should return apps when permissions are granted', () async {
      // Arrange
      when(() => mockAppRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockAppRepository.getAppsWithNotificationSettings())
          .thenAnswer((_) async => mockApps);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, equals(mockApps));
      verify(() => mockAppRepository.hasPermissions()).called(1);
      verify(() => mockAppRepository.getAppsWithNotificationSettings()).called(1);
      verifyNever(() => mockAppRepository.requestPermissions());
    });

    test('should request permissions and return apps when permissions are initially denied but then granted', () async {
      // Arrange
      when(() => mockAppRepository.hasPermissions())
          .thenAnswer((_) async => false);
      when(() => mockAppRepository.requestPermissions())
          .thenAnswer((_) async => true);
      when(() => mockAppRepository.getAppsWithNotificationSettings())
          .thenAnswer((_) async => mockApps);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, equals(mockApps));
      verify(() => mockAppRepository.hasPermissions()).called(1);
      verify(() => mockAppRepository.requestPermissions()).called(1);
      verify(() => mockAppRepository.getAppsWithNotificationSettings()).called(1);
    });

    test('should throw exception when permissions are denied', () async {
      // Arrange
      when(() => mockAppRepository.hasPermissions())
          .thenAnswer((_) async => false);
      when(() => mockAppRepository.requestPermissions())
          .thenAnswer((_) async => false);

      // Act & Assert
      await expectLater(
        useCase.execute(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Permissions not granted'),
        )),
      );
      verify(() => mockAppRepository.hasPermissions()).called(1);
      verify(() => mockAppRepository.requestPermissions()).called(1);
      verifyNever(() => mockAppRepository.getAppsWithNotificationSettings());
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockAppRepository.hasPermissions())
          .thenAnswer((_) async => true);
      when(() => mockAppRepository.getAppsWithNotificationSettings())
          .thenThrow(Exception('Repository error'));

      // Act & Assert
      await expectLater(
        useCase.execute(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Repository error'),
        )),
      );
      verify(() => mockAppRepository.hasPermissions()).called(1);
      verify(() => mockAppRepository.getAppsWithNotificationSettings()).called(1);
    });
  });
}