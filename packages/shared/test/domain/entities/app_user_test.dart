import 'package:flutter_test/flutter_test.dart';
import 'package:shared/domain/entities/app_user.dart';

void main() {
  final now = DateTime(2026, 4, 9, 12, 0, 0);

  AppUser createUser({
    String id = 'user-1',
    String name = 'John Doe',
    String email = 'john@example.com',
    String avatarUrl = '',
    String role = 'guru',
    bool isOnline = false,
    DateTime? lastSeen,
  }) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      role: role,
      isOnline: isOnline,
      lastSeen: lastSeen ?? now,
    );
  }

  group('AppUser', () {
    group('creation with default values', () {
      test('avatarUrl defaults to empty string', () {
        final user = createUser();
        expect(user.avatarUrl, '');
      });

      test('isOnline defaults to false', () {
        final user = createUser();
        expect(user.isOnline, false);
      });

      test('stores all required fields correctly', () {
        final user = createUser(
          id: 'u-42',
          name: 'Jane Doe',
          email: 'jane@example.com',
          role: 'trainer',
        );

        expect(user.id, 'u-42');
        expect(user.name, 'Jane Doe');
        expect(user.email, 'jane@example.com');
        expect(user.role, 'trainer');
        expect(user.lastSeen, now);
      });
    });

    group('userRole getter', () {
      test('returns UserRole.guru when role is "guru"', () {
        final user = createUser(role: 'guru');
        expect(user.userRole, UserRole.guru);
      });

      test('returns UserRole.trainer when role is "trainer"', () {
        final user = createUser(role: 'trainer');
        expect(user.userRole, UserRole.trainer);
      });

      test('defaults to UserRole.guru for unknown role strings', () {
        final user = createUser(role: 'admin');
        expect(user.userRole, UserRole.guru);
      });
    });

    group('copyWith', () {
      test('creates a new instance with updated fields', () {
        final user = createUser(name: 'Original');
        final updated = user.copyWith(name: 'Updated');

        expect(updated.name, 'Updated');
        expect(updated, isNot(same(user)));
      });

      test('preserves unchanged fields', () {
        final user = createUser(
          id: 'u-1',
          name: 'John',
          email: 'john@example.com',
          avatarUrl: 'https://example.com/avatar.png',
          role: 'guru',
          isOnline: true,
        );

        final updated = user.copyWith(name: 'Jane');

        expect(updated.id, 'u-1');
        expect(updated.email, 'john@example.com');
        expect(updated.avatarUrl, 'https://example.com/avatar.png');
        expect(updated.role, 'guru');
        expect(updated.isOnline, true);
        expect(updated.lastSeen, now);
      });

      test('can update all fields at once', () {
        final user = createUser();
        final newTime = DateTime(2026, 5, 1);
        final updated = user.copyWith(
          id: 'new-id',
          name: 'New Name',
          email: 'new@example.com',
          avatarUrl: 'new-url',
          role: 'trainer',
          isOnline: true,
          lastSeen: newTime,
        );

        expect(updated.id, 'new-id');
        expect(updated.name, 'New Name');
        expect(updated.email, 'new@example.com');
        expect(updated.avatarUrl, 'new-url');
        expect(updated.role, 'trainer');
        expect(updated.isOnline, true);
        expect(updated.lastSeen, newTime);
      });
    });

    group('Equatable', () {
      test('two users with the same properties are equal', () {
        final user1 = createUser();
        final user2 = createUser();
        expect(user1, equals(user2));
      });

      test('two users with different ids are not equal', () {
        final user1 = createUser(id: 'user-1');
        final user2 = createUser(id: 'user-2');
        expect(user1, isNot(equals(user2)));
      });

      test('two users with different names are not equal', () {
        final user1 = createUser(name: 'Alice');
        final user2 = createUser(name: 'Bob');
        expect(user1, isNot(equals(user2)));
      });

      test('two users with different isOnline are not equal', () {
        final user1 = createUser(isOnline: false);
        final user2 = createUser(isOnline: true);
        expect(user1, isNot(equals(user2)));
      });

      test('copyWith with no changes returns equal object', () {
        final user = createUser();
        final copy = user.copyWith();
        expect(user, equals(copy));
      });

      test('props contains all fields', () {
        final user = createUser();
        expect(user.props.length, 7);
      });
    });
  });
}
