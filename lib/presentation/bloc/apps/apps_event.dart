import 'package:equatable/equatable.dart';

import '../../../domain/entities/notification_interval.dart';

abstract class AppsEvent extends Equatable {
  const AppsEvent();

  @override
  List<Object?> get props => [];
}

class LoadApps extends AppsEvent {
  const LoadApps();
}

class ToggleAppNotification extends AppsEvent {
  const ToggleAppNotification({
    required this.packageName,
    required this.enabled,
  });

  final String packageName;
  final bool enabled;

  @override
  List<Object?> get props => [packageName, enabled];
}

class TurnOffNotifications extends AppsEvent {
  const TurnOffNotifications(this.interval);

  final NotificationInterval interval;

  @override
  List<Object?> get props => [interval];
}

class RefreshApps extends AppsEvent {
  const RefreshApps();
}