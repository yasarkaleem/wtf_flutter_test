import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared/utils/extensions.dart';

void main() {
  group('DateTimeExt.timeAgo', () {
    test('returns "Just now" for time less than 60 seconds ago', () {
      final recent = DateTime.now().subtract(const Duration(seconds: 30));
      expect(recent.timeAgo, 'Just now');
    });

    test('returns "Xm ago" for time less than 60 minutes ago', () {
      final fiveMinAgo = DateTime.now().subtract(const Duration(minutes: 5));
      expect(fiveMinAgo.timeAgo, '5m ago');
    });

    test('returns "Xh ago" for time less than 24 hours ago', () {
      final threeHoursAgo =
          DateTime.now().subtract(const Duration(hours: 3));
      expect(threeHoursAgo.timeAgo, '3h ago');
    });

    test('returns "Xd ago" for time less than 7 days ago', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      expect(twoDaysAgo.timeAgo, '2d ago');
    });

    test('returns formatted date for time 7+ days ago', () {
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      final expected = DateFormat('MMM d').format(tenDaysAgo);
      expect(tenDaysAgo.timeAgo, expected);
    });
  });

  group('DateTimeExt.chatTimestamp', () {
    test('returns "HH:mm" for today', () {
      final now = DateTime.now();
      final todayTime = DateTime(now.year, now.month, now.day, 14, 30);
      expect(todayTime.chatTimestamp, DateFormat('HH:mm').format(todayTime));
    });

    test('returns "Yesterday" for yesterday', () {
      final now = DateTime.now();
      final yesterday =
          DateTime(now.year, now.month, now.day - 1, 14, 30);
      expect(yesterday.chatTimestamp, 'Yesterday');
    });

    test('returns "MMM d" for older dates', () {
      final now = DateTime.now();
      final older = DateTime(now.year, now.month, now.day - 5, 14, 30);
      final expected = DateFormat('MMM d').format(older);
      expect(older.chatTimestamp, expected);
    });
  });

  group('DateTimeExt.fullTimestamp', () {
    test('formats as HH:mm', () {
      final dt = DateTime(2025, 6, 15, 9, 5);
      expect(dt.fullTimestamp, '09:05');
    });

    test('formats afternoon time correctly', () {
      final dt = DateTime(2025, 6, 15, 14, 30);
      expect(dt.fullTimestamp, '14:30');
    });
  });

  group('DateTimeExt.dateLabel', () {
    test('returns "Today" for today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 12, 0);
      expect(today.dateLabel, 'Today');
    });

    test('returns "Tomorrow" for tomorrow', () {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 12, 0);
      expect(tomorrow.dateLabel, 'Tomorrow');
    });

    test('returns "EEE, MMM d" for other dates', () {
      final now = DateTime.now();
      final otherDay = DateTime(now.year, now.month, now.day + 5, 12, 0);
      final expected = DateFormat('EEE, MMM d').format(otherDay);
      expect(otherDay.dateLabel, expected);
    });
  });

  group('StringExt.initials', () {
    test('returns first letters of two-word name', () {
      expect('John Doe'.initials, 'JD');
    });

    test('handles single word with two+ characters', () {
      expect('Alice'.initials, 'AL');
    });

    test('handles single character string', () {
      expect('A'.initials, 'A');
    });

    test('uppercases initials', () {
      expect('john doe'.initials, 'JD');
    });

    test('handles three-word name (takes first two)', () {
      expect('Mary Jane Watson'.initials, 'MJ');
    });

    test('trims leading/trailing whitespace', () {
      expect('  John Doe  '.initials, 'JD');
    });
  });

  group('DurationExt.formatted', () {
    test('returns "MM:SS" for less than 1 hour', () {
      const duration = Duration(minutes: 5, seconds: 30);
      expect(duration.formatted, '05:30');
    });

    test('returns "HH:MM:SS" for 1 hour or more', () {
      const duration = Duration(hours: 1, minutes: 23, seconds: 45);
      expect(duration.formatted, '01:23:45');
    });

    test('formats zero duration correctly', () {
      const duration = Duration.zero;
      expect(duration.formatted, '00:00');
    });

    test('pads single-digit values', () {
      const duration = Duration(minutes: 1, seconds: 5);
      expect(duration.formatted, '01:05');
    });

    test('formats exactly 1 hour', () {
      const duration = Duration(hours: 1);
      expect(duration.formatted, '01:00:00');
    });

    test('handles large durations', () {
      const duration = Duration(hours: 12, minutes: 34, seconds: 56);
      expect(duration.formatted, '12:34:56');
    });
  });
}
