import '../../domain/entities/app_user.dart' as domain;
import '../../models/user.dart' as model;

/// Maps between the domain [domain.AppUser] entity and the
/// Hive-annotated [model.AppUser] data model.
class UserMapper {
  UserMapper._();

  /// Converts a Hive [model.AppUser] to a domain [domain.AppUser].
  static domain.AppUser toEntity(model.AppUser m) {
    return domain.AppUser(
      id: m.id,
      name: m.name,
      email: m.email,
      avatarUrl: m.avatarUrl,
      role: m.role,
      isOnline: m.isOnline,
      lastSeen: m.lastSeen,
    );
  }

  /// Converts a domain [domain.AppUser] to a Hive [model.AppUser].
  static model.AppUser toModel(domain.AppUser entity) {
    return model.AppUser(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      isOnline: entity.isOnline,
      lastSeen: entity.lastSeen,
    );
  }
}
