import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import 'log_service.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  late Box<AppUser> _userBox;
  late Box<Message> _messageBox;
  late Box<ChatRoom> _chatRoomBox;
  late Box<Schedule> _scheduleBox;
  late Box<SessionLog> _sessionLogBox;
  late Box _settingsBox;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(AppUserAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(ChatRoomAdapter());
    Hive.registerAdapter(ScheduleAdapter());
    Hive.registerAdapter(SessionLogAdapter());

    // Open boxes
    _userBox = await Hive.openBox<AppUser>(AppConstants.userBox);
    _messageBox = await Hive.openBox<Message>(AppConstants.messageBox);
    _chatRoomBox = await Hive.openBox<ChatRoom>(AppConstants.chatRoomBox);
    _scheduleBox = await Hive.openBox<Schedule>(AppConstants.scheduleBox);
    _sessionLogBox = await Hive.openBox<SessionLog>(AppConstants.sessionLogBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);

    _initialized = true;
    LogService.instance.log(AppConstants.tagAuth, 'Storage initialized');
  }

  // Users
  Box<AppUser> get userBox => _userBox;
  Future<void> saveUser(AppUser user) => _userBox.put(user.id, user);
  AppUser? getUser(String id) => _userBox.get(id);
  List<AppUser> getAllUsers() => _userBox.values.toList();

  // Messages
  Box<Message> get messageBox => _messageBox;
  Future<void> saveMessage(Message msg) => _messageBox.put(msg.id, msg);
  Message? getMessage(String id) => _messageBox.get(id);
  List<Message> getMessagesForRoom(String chatRoomId) {
    return _messageBox.values
        .where((m) => m.chatRoomId == chatRoomId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Chat Rooms
  Box<ChatRoom> get chatRoomBox => _chatRoomBox;
  Future<void> saveChatRoom(ChatRoom room) => _chatRoomBox.put(room.id, room);
  ChatRoom? getChatRoom(String id) => _chatRoomBox.get(id);
  List<ChatRoom> getAllChatRooms() => _chatRoomBox.values.toList();

  // Schedules
  Box<Schedule> get scheduleBox => _scheduleBox;
  Future<void> saveSchedule(Schedule schedule) =>
      _scheduleBox.put(schedule.id, schedule);
  Schedule? getSchedule(String id) => _scheduleBox.get(id);
  List<Schedule> getAllSchedules() => _scheduleBox.values.toList();
  List<Schedule> getSchedulesForUser(String userId) {
    return _scheduleBox.values
        .where((s) => s.guruId == userId || s.trainerId == userId)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  // Session Logs
  Box<SessionLog> get sessionLogBox => _sessionLogBox;
  Future<void> saveSessionLog(SessionLog log) =>
      _sessionLogBox.put(log.id, log);
  SessionLog? getSessionLog(String id) => _sessionLogBox.get(id);
  List<SessionLog> getAllSessionLogs() => _sessionLogBox.values.toList()
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  // Settings
  Box get settingsBox => _settingsBox;
  Future<void> saveSetting(String key, dynamic value) =>
      _settingsBox.put(key, value);
  dynamic getSetting(String key) => _settingsBox.get(key);

  // Clear all data
  Future<void> clearAll() async {
    await _userBox.clear();
    await _messageBox.clear();
    await _chatRoomBox.clear();
    await _scheduleBox.clear();
    await _sessionLogBox.clear();
    await _settingsBox.clear();
  }
}
