// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pause_pulse/domain/repositories/app_repository.dart';
import 'package:pause_pulse/domain/repositories/notification_repository.dart';
import 'package:pause_pulse/domain/usecases/get_apps_usecase.dart';
import 'package:pause_pulse/domain/usecases/pause_notifications_usecase.dart';
import 'package:pause_pulse/domain/usecases/update_notification_setting_usecase.dart';
import 'package:pause_pulse/presentation/bloc/apps/apps_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pause_pulse/presentation/app/app.dart';

class MockAppRepository extends Mock implements AppRepository {}
class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  setUpAll(() async {
    // Initialize mock dependencies for testing
    GetIt.I.reset();
    
    final mockSharedPrefs = MockSharedPreferences();
    when(() => mockSharedPrefs.getString(any())).thenReturn(null);
    when(() => mockSharedPrefs.setString(any(), any())).thenAnswer((_) async => true);
    
    GetIt.I.registerSingleton<SharedPreferences>(mockSharedPrefs);
    GetIt.I.registerFactory<AppRepository>(() => MockAppRepository());
    GetIt.I.registerFactory<NotificationRepository>(() => MockNotificationRepository());
    GetIt.I.registerFactory(() => GetAppsUseCase(GetIt.I<AppRepository>()));
    GetIt.I.registerFactory(() => UpdateNotificationSettingUseCase(GetIt.I<AppRepository>()));
    GetIt.I.registerFactory(() => PauseNotificationsUseCase(GetIt.I<NotificationRepository>()));
    GetIt.I.registerFactory(() => AppsBloc(
      GetIt.I<GetAppsUseCase>(),
      GetIt.I<UpdateNotificationSettingUseCase>(),
      GetIt.I<PauseNotificationsUseCase>(),
    ));
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that our app starts and displays the title
    expect(find.text('Pause Pulse'), findsOneWidget);
  });
}

class MockSharedPreferences extends Mock implements SharedPreferences {}
