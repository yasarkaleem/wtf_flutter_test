import 'dart:async';

import '../../domain/entities/entities.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../../services/auth_service.dart';
import '../mappers/user_mapper.dart';

/// Thin wrapper around [AuthService] that satisfies the [AuthRepository]
/// contract.  Delegates every call to the existing singleton and uses
/// [UserMapper] to convert between model and domain types.
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service = AuthService.instance;

  @override
  domain.AppUser? get currentUser {
    final model = _service.currentUser;
    return model == null ? null : UserMapper.toEntity(model);
  }

  @override
  bool get isLoggedIn => _service.isLoggedIn;

  @override
  Stream<domain.AppUser?> get authStream =>
      _service.authStream.map((m) => m == null ? null : UserMapper.toEntity(m));

  @override
  Future<domain.AppUser> loginAsGuru() async {
    final model = await _service.loginAsGuru();
    return UserMapper.toEntity(model);
  }

  @override
  Future<domain.AppUser> loginAsTrainer() async {
    final model = await _service.loginAsTrainer();
    return UserMapper.toEntity(model);
  }

  @override
  Future<void> logout() => _service.logout();

  @override
  domain.AppUser? getOtherUser() {
    final model = _service.getOtherUser();
    return model == null ? null : UserMapper.toEntity(model);
  }

  @override
  void dispose() => _service.dispose();
}
