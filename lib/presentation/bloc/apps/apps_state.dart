import 'package:equatable/equatable.dart';

import '../../../domain/entities/app_info.dart';

abstract class AppsState extends Equatable {
  const AppsState();

  @override
  List<Object?> get props => [];
}

class AppsInitial extends AppsState {
  const AppsInitial();
}

class AppsLoading extends AppsState {
  const AppsLoading();
}

class AppsLoaded extends AppsState {
  const AppsLoaded({
    required this.apps,
    this.selectedApps = const [],
  });

  final List<AppInfo> apps;
  final List<String> selectedApps;

  AppsLoaded copyWith({
    List<AppInfo>? apps,
    List<String>? selectedApps,
  }) {
    return AppsLoaded(
      apps: apps ?? this.apps,
      selectedApps: selectedApps ?? this.selectedApps,
    );
  }

  @override
  List<Object?> get props => [apps, selectedApps];
}

class AppsError extends AppsState {
  const AppsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AppsPermissionDenied extends AppsState {
  const AppsPermissionDenied();
}