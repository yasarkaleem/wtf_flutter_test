import 'dart:async';
import '../models/models.dart';
import '../utils/constants.dart';
import 'log_service.dart';
import 'storage_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  AppUser? _currentUser;
  final _authController = StreamController<AppUser?>.broadcast();

  AppUser? get currentUser => _currentUser;
  Stream<AppUser?> get authStream => _authController.stream;
  bool get isLoggedIn => _currentUser != null;

  /// Seeds mock users (DK and Aarav) into storage.
  Future<void> seedMockUsers() async {
    final storage = StorageService.instance;

    final guru = AppUser(
      id: AppConstants.guruId,
      name: AppConstants.guruName,
      email: AppConstants.guruEmail,
      role: 'guru',
      isOnline: true,
      lastSeen: DateTime.now(),
    );

    final trainer = AppUser(
      id: AppConstants.trainerId,
      name: AppConstants.trainerName,
      email: AppConstants.trainerEmail,
      role: 'trainer',
      isOnline: true,
      lastSeen: DateTime.now(),
    );

    await storage.saveUser(guru);
    await storage.saveUser(trainer);
    LogService.instance.log(AppConstants.tagAuth, 'Mock users seeded');
  }

  /// Login as guru (member DK).
  Future<AppUser> loginAsGuru() async {
    await seedMockUsers();
    _currentUser = StorageService.instance.getUser(AppConstants.guruId);
    _authController.add(_currentUser);
    LogService.instance.log(
      AppConstants.tagAuth,
      'Logged in as Guru: ${_currentUser!.name}',
    );
    return _currentUser!;
  }

  /// Login as trainer (Aarav).
  Future<AppUser> loginAsTrainer() async {
    await seedMockUsers();
    _currentUser = StorageService.instance.getUser(AppConstants.trainerId);
    _authController.add(_currentUser);
    LogService.instance.log(
      AppConstants.tagAuth,
      'Logged in as Trainer: ${_currentUser!.name}',
    );
    return _currentUser!;
  }

  /// Logout the current user.
  Future<void> logout() async {
    LogService.instance.log(
      AppConstants.tagAuth,
      'Logged out: ${_currentUser?.name}',
    );
    _currentUser = null;
    _authController.add(null);
  }

  /// Get the other user in the conversation.
  AppUser? getOtherUser() {
    if (_currentUser == null) return null;
    final otherId = _currentUser!.role == 'guru'
        ? AppConstants.trainerId
        : AppConstants.guruId;
    return StorageService.instance.getUser(otherId);
  }

  void dispose() {
    _authController.close();
  }
}
