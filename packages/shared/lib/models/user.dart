import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

enum UserRole { guru, trainer }

@HiveType(typeId: 0)
class AppUser extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String avatarUrl;

  @HiveField(4)
  final String role; // 'guru' or 'trainer'

  @HiveField(5)
  final bool isOnline;

  @HiveField(6)
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'role': role,
        'isOnline': isOnline,
        'lastSeen': lastSeen.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String? ?? '',
        role: json['role'] as String,
        isOnline: json['isOnline'] as bool? ?? false,
        lastSeen: DateTime.parse(json['lastSeen'] as String),
      );

  @override
  List<Object?> get props => [id, name, email, avatarUrl, role, isOnline, lastSeen];
}
