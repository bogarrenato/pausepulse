import 'package:injectable/injectable.dart';

import '../entities/notification_interval.dart';
import '../repositories/notification_repository.dart';

@injectable
class PauseNotificationsUseCase {
  const PauseNotificationsUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  Future<void> execute(
    List<String> packageNames,
    NotificationInterval interval,
  ) async {
    await _notificationRepository.pauseNotifications(packageNames, interval);
  }
}