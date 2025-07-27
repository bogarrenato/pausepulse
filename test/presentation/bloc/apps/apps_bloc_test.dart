import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pause_pulse/domain/entities/app_info.dart';
import 'package:pause_pulse/domain/entities/notification_interval.dart';
import 'package:pause_pulse/domain/usecases/get_apps_usecase.dart';
import 'package:pause_pulse/domain/usecases/pause_notifications_usecase.dart';
import 'package:pause_pulse/domain/usecases/update_notification_setting_usecase.dart';
import 'package:pause_pulse/presentation/bloc/apps/apps_bloc.dart';
import 'package:pause_pulse/presentation/bloc/apps/apps_event.dart';
import 'package:pause_pulse/presentation/bloc/apps/apps_state.dart';

class MockGetAppsUseCase extends Mock implements GetAppsUseCase {}
class MockUpdateNotificationSettingUseCase extends Mock implements UpdateNotificationSettingUseCase {}
class MockPauseNotificationsUseCase extends Mock implements PauseNotificationsUseCase {}

class FakeNotificationInterval extends Fake implements NotificationInterval {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeNotificationInterval());
  });
  late AppsBloc appsBloc;
  late MockGetAppsUseCase mockGetAppsUseCase;
  late MockUpdateNotificationSettingUseCase mockUpdateNotificationSettingUseCase;
  late MockPauseNotificationsUseCase mockPauseNotificationsUseCase;

  setUp(() {
    mockGetAppsUseCase = MockGetAppsUseCase();
    mockUpdateNotificationSettingUseCase = MockUpdateNotificationSettingUseCase();
    mockPauseNotificationsUseCase = MockPauseNotificationsUseCase();
    
    appsBloc = AppsBloc(
      mockGetAppsUseCase,
      mockUpdateNotificationSettingUseCase,
      mockPauseNotificationsUseCase,
    );
  });

  group('AppsBloc', () {
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

    test('initial state is AppsInitial', () {
      expect(appsBloc.state, equals(const AppsInitial()));
    });

    group('LoadApps', () {
      blocTest<AppsBloc, AppsState>(
        'emits [AppsLoading, AppsLoaded] when LoadApps is successful',
        build: () {
          when(() => mockGetAppsUseCase.execute())
              .thenAnswer((_) async => mockApps);
          return appsBloc;
        },
        act: (bloc) => bloc.add(const LoadApps()),
        expect: () => [
          const AppsLoading(),
          const AppsLoaded(apps: mockApps),
        ],
        verify: (_) {
          verify(() => mockGetAppsUseCase.execute()).called(1);
        },
      );

      blocTest<AppsBloc, AppsState>(
        'emits [AppsLoading, AppsPermissionDenied] when permissions are not granted',
        build: () {
          when(() => mockGetAppsUseCase.execute())
              .thenThrow(Exception('Permissions not granted'));
          return appsBloc;
        },
        act: (bloc) => bloc.add(const LoadApps()),
        expect: () => [
          const AppsLoading(),
          const AppsPermissionDenied(),
        ],
        verify: (_) {
          verify(() => mockGetAppsUseCase.execute()).called(1);
        },
      );

      blocTest<AppsBloc, AppsState>(
        'emits [AppsLoading, AppsError] when an error occurs',
        build: () {
          when(() => mockGetAppsUseCase.execute())
              .thenThrow(Exception('Generic error'));
          return appsBloc;
        },
        act: (bloc) => bloc.add(const LoadApps()),
        expect: () => [
          const AppsLoading(),
          const AppsError('Exception: Generic error'),
        ],
        verify: (_) {
          verify(() => mockGetAppsUseCase.execute()).called(1);
        },
      );
    });

    group('ToggleAppNotification', () {
      blocTest<AppsBloc, AppsState>(
        'updates app notification setting and emits updated state',
        build: () {
          when(() => mockUpdateNotificationSettingUseCase.execute(any(), any()))
              .thenAnswer((_) async {});
          return appsBloc;
        },
        seed: () => const AppsLoaded(apps: mockApps),
        act: (bloc) => bloc.add(
          const ToggleAppNotification(
            packageName: 'com.example.app1',
            enabled: false,
          ),
        ),
        expect: () => [
          AppsLoaded(
            apps: [
              mockApps[0].copyWith(isNotificationEnabled: false),
              mockApps[1],
            ],
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateNotificationSettingUseCase.execute(
            'com.example.app1',
            false,
          )).called(1);
        },
      );

      blocTest<AppsBloc, AppsState>(
        'emits error when toggle fails',
        build: () {
          when(() => mockUpdateNotificationSettingUseCase.execute(any(), any()))
              .thenThrow(Exception('Update failed'));
          return appsBloc;
        },
        seed: () => const AppsLoaded(apps: mockApps),
        act: (bloc) => bloc.add(
          const ToggleAppNotification(
            packageName: 'com.example.app1',
            enabled: false,
          ),
        ),
        expect: () => [
          const AppsError('Exception: Update failed'),
        ],
        verify: (_) {
          verify(() => mockUpdateNotificationSettingUseCase.execute(
            'com.example.app1',
            false,
          )).called(1);
        },
      );

      blocTest<AppsBloc, AppsState>(
        'does nothing when state is not AppsLoaded',
        build: () => appsBloc,
        seed: () => const AppsLoading(),
        act: (bloc) => bloc.add(
          const ToggleAppNotification(
            packageName: 'com.example.app1',
            enabled: false,
          ),
        ),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockUpdateNotificationSettingUseCase.execute(any(), any()));
        },
      );
    });

    group('TurnOffNotifications', () {
      const interval = NotificationInterval(type: IntervalType.hour1);

      blocTest<AppsBloc, AppsState>(
        'pauses notifications for disabled apps',
        build: () {
          when(() => mockPauseNotificationsUseCase.execute(any(), any()))
              .thenAnswer((_) async {});
          return appsBloc;
        },
        seed: () => const AppsLoaded(apps: mockApps),
        act: (bloc) => bloc.add(const TurnOffNotifications(interval)),
        wait: const Duration(milliseconds: 100),
        verify: (_) {
          verify(() => mockPauseNotificationsUseCase.execute(
            ['com.example.app2'], // Only app2 has notifications disabled
            interval,
          )).called(1);
        },
      );

      blocTest<AppsBloc, AppsState>(
        'does not call pause when no apps are disabled',
        build: () {
          when(() => mockPauseNotificationsUseCase.execute(any(), any()))
              .thenAnswer((_) async {});
          return appsBloc;
        },
        seed: () => const AppsLoaded(
          apps: [
            AppInfo(
              packageName: 'com.example.app1',
              appName: 'App 1',
              iconPath: null,
              isNotificationEnabled: true,
            ),
          ],
        ),
        act: (bloc) => bloc.add(const TurnOffNotifications(interval)),
        wait: const Duration(milliseconds: 100),
        verify: (_) {
          // Should not be called since no apps are disabled
          verifyNever(() => mockPauseNotificationsUseCase.execute(any(), any()));
        },
      );

      blocTest<AppsBloc, AppsState>(
        'emits error when pause fails',
        build: () {
          when(() => mockPauseNotificationsUseCase.execute(any(), any()))
              .thenThrow(Exception('Pause failed'));
          return appsBloc;
        },
        seed: () => const AppsLoaded(apps: mockApps),
        act: (bloc) => bloc.add(const TurnOffNotifications(interval)),
        expect: () => [
          const AppsError('Exception: Pause failed'),
        ],
        verify: (_) {
          verify(() => mockPauseNotificationsUseCase.execute(any(), any())).called(1);
        },
      );
    });

    group('RefreshApps', () {
      blocTest<AppsBloc, AppsState>(
        'refreshes apps and preserves current state when already loaded',
        build: () {
          when(() => mockGetAppsUseCase.execute())
              .thenAnswer((_) async => mockApps);
          return appsBloc;
        },
        seed: () => const AppsLoaded(apps: [], selectedApps: ['test']),
        act: (bloc) => bloc.add(const RefreshApps()),
        expect: () => [
          const AppsLoaded(apps: mockApps, selectedApps: ['test']),
        ],
        verify: (_) {
          verify(() => mockGetAppsUseCase.execute()).called(1);
        },
      );

      blocTest<AppsBloc, AppsState>(
        'creates new loaded state when not currently loaded',
        build: () {
          when(() => mockGetAppsUseCase.execute())
              .thenAnswer((_) async => mockApps);
          return appsBloc;
        },
        seed: () => const AppsInitial(),
        act: (bloc) => bloc.add(const RefreshApps()),
        expect: () => [
          const AppsLoaded(apps: mockApps),
        ],
        verify: (_) {
          verify(() => mockGetAppsUseCase.execute()).called(1);
        },
      );
    });
  });
}