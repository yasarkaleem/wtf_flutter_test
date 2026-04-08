import 'constants.dart';

class Validators {
  Validators._();

  static String? validateScheduleTime(DateTime? scheduledAt) {
    if (scheduledAt == null) return 'Please select a time slot';

    final now = DateTime.now();

    if (scheduledAt.isBefore(now)) {
      return 'Cannot schedule in the past';
    }

    final maxDate = DateTime(now.year, now.month, now.day)
        .add(Duration(days: AppConstants.schedulableDays));
    if (scheduledAt.isAfter(maxDate)) {
      return 'Can only schedule within the next ${AppConstants.schedulableDays} days';
    }

    if (scheduledAt.hour < AppConstants.dayStartHour ||
        scheduledAt.hour >= AppConstants.dayEndHour) {
      return 'Slots available between ${AppConstants.dayStartHour}:00 and ${AppConstants.dayEndHour}:00';
    }

    return null;
  }

  static String? validateRating(int? rating) {
    if (rating == null) return 'Please provide a rating';
    if (rating < 1 || rating > 5) return 'Rating must be between 1 and 5';
    return null;
  }

  static String? validateNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) return 'Notes cannot be empty';
    if (notes.length > 500) return 'Notes must be under 500 characters';
    return null;
  }

  static String? validateMessage(String? message) {
    if (message == null || message.trim().isEmpty) return 'Message cannot be empty';
    if (message.length > 2000) return 'Message too long';
    return null;
  }

  static int calculateSessionDuration(DateTime start, DateTime end) {
    if (end.isBefore(start)) return 0;
    return end.difference(start).inSeconds;
  }
}
