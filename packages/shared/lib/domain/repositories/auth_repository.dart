import 'dart:async';

import '../entities/entities.dart';

/// Abstract interface for authentication operations.
abstract class AuthRepository {
  /// The currently authenticated user, or null if not logged in.
  AppUser? get currentUser;

  /// Whether a user is currently logged in.
  bool get isLoggedIn;

  /// Stream that emits the current user on every auth state change.
  Stream<AppUser?> get authStream;

  /// Log in as the guru (member) user.
  Future<AppUser> loginAsGuru();

  /// Log in as the trainer user.
  Future<AppUser> loginAsTrainer();

  /// Log out the current user.
  Future<void> logout();

  /// Get the other participant in the conversation.
  AppUser? getOtherUser();

  /// Release resources.
  void dispose();
}
