import 'package:mixin_logger/mixin_logger.dart' as logger;

List<String> appLogs = <String>[];
Function(String)? logListener;

void logDebug(dynamic data) {
  logger.d(data);
  _logInterceptor(data, "Debug");
}

void logInfo(dynamic data) {
  logger.i(data);
  _logInterceptor(data, "Info");
}

void logError(dynamic data) {
  logger.e(data);
  _logInterceptor(data, "Error");
}

void _logInterceptor(data, String logType) {
  String log = data.toString().trim();
  if (!log.startsWith('[')) {
    log = '${_formatDateTime(DateTime.now())} $logType: $data';
  }
  appLogs.add(log);
  logListener?.call(log);
}

void clearLogs() {
  appLogs.clear();
}

String _formatDateTime(DateTime dateTime) {
  return '[${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}T${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}]';
}
