import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/get_apps_usecase.dart';
import '../../../domain/usecases/pause_notifications_usecase.dart';
import '../../../domain/usecases/update_notification_setting_usecase.dart';
import 'apps_event.dart';
import 'apps_state.dart';

@injectable
class AppsBloc extends Bloc<AppsEvent, AppsState> {
  AppsBloc(
    this._getAppsUseCase,
    this._updateNotificationSettingUseCase,
    this._pauseNotificationsUseCase,
  ) : super(const AppsInitial()) {
    on<LoadApps>(_onLoadApps);
    on<ToggleAppNotification>(_onToggleAppNotification);
    on<TurnOffNotifications>(_onTurnOffNotifications);
    on<RefreshApps>(_onRefreshApps);
  }

  final GetAppsUseCase _getAppsUseCase;
  final UpdateNotificationSettingUseCase _updateNotificationSettingUseCase;
  final PauseNotificationsUseCase _pauseNotificationsUseCase;

  Future<void> _onLoadApps(LoadApps event, Emitter<AppsState> emit) async {
    emit(const AppsLoading());
    
    try {
      final apps = await _getAppsUseCase.execute();
      emit(AppsLoaded(apps: apps));
    } catch (e) {
      if (e.toString().contains('Permissions not granted')) {
        emit(const AppsPermissionDenied());
      } else {
        emit(AppsError(e.toString()));
      }
    }
  }

  Future<void> _onToggleAppNotification(
    ToggleAppNotification event,
    Emitter<AppsState> emit,
  ) async {
    if (state is! AppsLoaded) return;

    final currentState = state as AppsLoaded;
    
    try {
      await _updateNotificationSettingUseCase.execute(
        event.packageName,
        event.enabled,
      );

      final updatedApps = currentState.apps.map((app) {
        if (app.packageName == event.packageName) {
          return app.copyWith(isNotificationEnabled: event.enabled);
        }
        return app;
      }).toList();

      emit(currentState.copyWith(apps: updatedApps));
    } catch (e) {
      emit(AppsError(e.toString()));
    }
  }

  Future<void> _onTurnOffNotifications(
    TurnOffNotifications event,
    Emitter<AppsState> emit,
  ) async {
    if (state is! AppsLoaded) return;

    final currentState = state as AppsLoaded;
    
    try {
      // Get apps that are set to have notifications disabled
      final appsToTurnOff = currentState.apps
          .where((app) => !app.isNotificationEnabled)
          .map((app) => app.packageName)
          .toList();

      if (appsToTurnOff.isNotEmpty) {
        await _pauseNotificationsUseCase.execute(appsToTurnOff, event.interval);
      }

      // Keep the current state as the UI should handle the success feedback
      emit(currentState.copyWith());
    } catch (e) {
      emit(AppsError(e.toString()));
    }
  }

  Future<void> _onRefreshApps(RefreshApps event, Emitter<AppsState> emit) async {
    // Similar to LoadApps but preserves current selected apps if any
    try {
      final apps = await _getAppsUseCase.execute();
      
      if (state is AppsLoaded) {
        final currentState = state as AppsLoaded;
        emit(currentState.copyWith(apps: apps));
      } else {
        emit(AppsLoaded(apps: apps));
      }
    } catch (e) {
      if (e.toString().contains('Permissions not granted')) {
        emit(const AppsPermissionDenied());
      } else {
        emit(AppsError(e.toString()));
      }
    }
  }
}