import '../../domain/repositories/settings_repository.dart';
import '../../services/storage_service.dart';

/// Thin wrapper around [StorageService] that satisfies the
/// [SettingsRepository] contract.  Delegates settings persistence to the
/// existing singleton's settings box.
class SettingsRepositoryImpl implements SettingsRepository {
  final StorageService _service = StorageService.instance;

  @override
  Future<void> saveSetting(String key, dynamic value) =>
      _service.saveSetting(key, value);

  @override
  dynamic getSetting(String key) => _service.getSetting(key);
}
