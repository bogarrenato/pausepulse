import 'package:injectable/injectable.dart';

import '../entities/app_info.dart';
import '../repositories/app_repository.dart';

@injectable
class GetAppsUseCase {
  const GetAppsUseCase(this._appRepository);

  final AppRepository _appRepository;

  Future<List<AppInfo>> execute() async {
    final hasPermissions = await _appRepository.hasPermissions();
    if (!hasPermissions) {
      final granted = await _appRepository.requestPermissions();
      if (!granted) {
        throw Exception('Permissions not granted');
      }
    }

    return _appRepository.getAppsWithNotificationSettings();
  }
}