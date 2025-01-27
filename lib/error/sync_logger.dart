class SyncLogger {
  static final List<Map<String, String>> logs = [];

  static void addLog(String message, {String status = 'info'}) {
    logs.add({
      'timestamp': DateTime.now().toIso8601String(),
      'status': status,
      'message': message,
    });
  }

  static List<Map<String, String>> getLogs() {
    return logs;
  }

  static void clearLogs() {
    logs.clear();
  }
}
