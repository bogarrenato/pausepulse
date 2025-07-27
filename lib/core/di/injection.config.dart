// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:pause_pulse/core/di/injection_module.dart' as _i421;
import 'package:pause_pulse/data/repositories/app_repository_impl.dart' as _i21;
import 'package:pause_pulse/data/repositories/notification_repository_impl.dart'
    as _i300;
import 'package:pause_pulse/domain/repositories/app_repository.dart' as _i982;
import 'package:pause_pulse/domain/repositories/notification_repository.dart'
    as _i358;
import 'package:pause_pulse/domain/usecases/get_apps_usecase.dart' as _i410;
import 'package:pause_pulse/domain/usecases/pause_notifications_usecase.dart'
    as _i48;
import 'package:pause_pulse/domain/usecases/update_notification_setting_usecase.dart'
    as _i171;
import 'package:pause_pulse/presentation/bloc/apps/apps_bloc.dart' as _i429;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final injectableModule = _$InjectableModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => injectableModule.sharedPrefs,
      preResolve: true,
    );
    gh.factory<_i982.AppRepository>(
        () => _i21.AppRepositoryImpl(gh<_i460.SharedPreferences>()));
    gh.factory<_i358.NotificationRepository>(
        () => _i300.NotificationRepositoryImpl(gh<_i460.SharedPreferences>()));
    gh.factory<_i171.UpdateNotificationSettingUseCase>(() =>
        _i171.UpdateNotificationSettingUseCase(gh<_i982.AppRepository>()));
    gh.factory<_i410.GetAppsUseCase>(
        () => _i410.GetAppsUseCase(gh<_i982.AppRepository>()));
    gh.factory<_i48.PauseNotificationsUseCase>(() =>
        _i48.PauseNotificationsUseCase(gh<_i358.NotificationRepository>()));
    gh.factory<_i429.AppsBloc>(() => _i429.AppsBloc(
          gh<_i410.GetAppsUseCase>(),
          gh<_i171.UpdateNotificationSettingUseCase>(),
          gh<_i48.PauseNotificationsUseCase>(),
        ));
    return this;
  }
}

class _$InjectableModule extends _i421.InjectableModule {}
