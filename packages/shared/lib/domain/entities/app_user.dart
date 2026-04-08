import 'package:equatable/equatable.dart';

enum UserRole { guru, trainer }

class AppUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String role; // 'guru' or 'trainer'
  final bool isOnline;
  final DateTime lastSeen;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    required this.role,
    this.isOnline = false,
    required this.lastSeen,
  });

  UserRole get userRole =>
      role == 'trainer' ? UserRole.trainer : UserRole.guru;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, email, avatarUrl, role, isOnline, lastSeen];
}
