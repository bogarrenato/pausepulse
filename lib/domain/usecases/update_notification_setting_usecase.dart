import 'package:injectable/injectable.dart';

import '../repositories/app_repository.dart';

@injectable
class UpdateNotificationSettingUseCase {
  const UpdateNotificationSettingUseCase(this._appRepository);

  final AppRepository _appRepository;

  Future<void> execute(String packageName, bool enabled) async {
    await _appRepository.updateNotificationSetting(packageName, enabled);
  }
}