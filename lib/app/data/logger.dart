import 'dart:developer';

List<String> appLogs = <String>[];
Function(String)? logListener;

void logInfo(data) {
  _logInterceptor(data);
}

void logError(data) {
  _logInterceptor(data);
}

void logWarning(data) {
  _logInterceptor(data);
}

void _logInterceptor(data) {
  log(data.toString());
  appLogs.add(data.toString());
  logListener?.call(data.toString());
}

void clearLogs() {
  appLogs.clear();
}
