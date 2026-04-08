import 'dart:async';

class LogEntry {
  final String tag;
  final String message;
  final DateTime timestamp;
  final String? error;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.tag,
    required this.message,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    final time = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
    final errorStr = error != null ? ' | ERROR: $error' : '';
    return '$time $tag $message$errorStr';
  }
}

class LogService {
  LogService._();
  static final LogService instance = LogService._();

  final List<LogEntry> _logs = [];
  final _logController = StreamController<LogEntry>.broadcast();

  Stream<LogEntry> get logStream => _logController.stream;
  List<LogEntry> get logs => List.unmodifiable(_logs);

  void log(String tag, String message) {
    final entry = LogEntry(
      tag: tag,
      message: message,
      timestamp: DateTime.now(),
    );
    _logs.add(entry);
    _logController.add(entry);
    // ignore: avoid_print
    print(entry);
  }

  void error(String tag, String message, [dynamic error, StackTrace? stack]) {
    final entry = LogEntry(
      tag: tag,
      message: message,
      timestamp: DateTime.now(),
      error: error?.toString(),
      stackTrace: stack,
    );
    _logs.add(entry);
    _logController.add(entry);
    // ignore: avoid_print
    print(entry);
  }

  void clear() {
    _logs.clear();
  }

  List<LogEntry> getByTag(String tag) {
    return _logs.where((e) => e.tag == tag).toList();
  }

  void dispose() {
    _logController.close();
  }
}
