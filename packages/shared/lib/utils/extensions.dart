import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(this);
  }

  String get chatTimestamp {
    final now = DateTime.now();
    final isToday = year == now.year && month == now.month && day == now.day;
    final isYesterday = year == now.year &&
        month == now.month &&
        day == now.day - 1;

    if (isToday) return DateFormat('HH:mm').format(this);
    if (isYesterday) return 'Yesterday';
    return DateFormat('MMM d').format(this);
  }

  String get fullTimestamp => DateFormat('HH:mm').format(this);

  String get dateLabel {
    final now = DateTime.now();
    final isToday = year == now.year && month == now.month && day == now.day;
    final isTomorrow = year == now.year &&
        month == now.month &&
        day == now.day + 1;

    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    return DateFormat('EEE, MMM d').format(this);
  }

  String get scheduleLabel => DateFormat('MMM d, yyyy - HH:mm').format(this);
}

extension StringExt on String {
  String get initials {
    final parts = trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return length >= 2
        ? substring(0, 2).toUpperCase()
        : toUpperCase();
  }
}

extension ContextExt on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(child: Text(message)),
            if (isError)
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white, size: 16),
                onPressed: () {
                  // Copy error to clipboard
                },
              ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : null,
        duration: Duration(seconds: isError ? 5 : 3),
      ),
    );
  }
}

extension DurationExt on Duration {
  String get formatted {
    final h = inHours;
    final m = inMinutes.remainder(60);
    final s = inSeconds.remainder(60);

    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
