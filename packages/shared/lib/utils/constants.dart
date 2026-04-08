class AppConstants {
  AppConstants._();

  // Mock Users
  static const String guruId = 'guru_dk_001';
  static const String guruName = 'DK';
  static const String guruEmail = 'dk@guru.app';

  static const String trainerId = 'trainer_aarav_001';
  static const String trainerName = 'Aarav';
  static const String trainerEmail = 'aarav@trainer.app';

  // Chat Room
  static const String defaultChatRoomId = 'room_dk_aarav_001';

  // Hive Boxes
  static const String userBox = 'users';
  static const String messageBox = 'messages';
  static const String chatRoomBox = 'chatRooms';
  static const String scheduleBox = 'schedules';
  static const String sessionLogBox = 'sessionLogs';
  static const String settingsBox = 'settings';

  // Timing
  static const int typingDelayMs = 600;
  static const int messageDeliveryDelayMs = 300;
  static const int readReceiptDelayMs = 800;
  static const int animationDurationMs = 200;

  // Schedule
  static const int slotDurationMinutes = 30;
  static const int schedulableDays = 3;
  static const int dayStartHour = 8;
  static const int dayEndHour = 20;

  // Server
  // iOS simulator: use 'localhost'
  // Android emulator: use '10.0.2.2'
  // Physical device: use your Mac's local IP (e.g. 192.168.x.x)
  // Physical device: use Mac's local IP
  // Simulator: 'localhost' also works
  static const String _host = '192.168.1.90';
  static const String serverUrl = 'http://$_host:3000';
  static const String wsServerUrl = 'ws://$_host:3000';
  static const String hmsTokenServerUrl = 'http://$_host:3000';
  static const String hmsRoomId = 'guru_trainer_room';

  // UI
  static const double spacingUnit = 8.0;

  // Log Tags
  static const String tagChat = '[CHAT]';
  static const String tagRtc = '[RTC]';
  static const String tagSchedule = '[SCHEDULE]';
  static const String tagAuth = '[AUTH]';
  static const String tagSession = '[SESSION]';
}
