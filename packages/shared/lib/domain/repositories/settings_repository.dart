/// Abstract interface for persisting user/app settings.
abstract class SettingsRepository {
  /// Persist a setting identified by [key].
  Future<void> saveSetting(String key, dynamic value);

  /// Retrieve a previously saved setting, or `null` if not found.
  dynamic getSetting(String key);
}
