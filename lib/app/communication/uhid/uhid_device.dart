import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:uni_control_hub/app/client/report_handler.dart';
import 'package:uni_control_hub/app/data/logger.dart';

class UhidDevice {
  String? deviceId;
  Socket? socket;
  Function(String? deviceId)? onDeviceClosed;
  StreamSubscription? _clientServiceSubscription;

  UhidDevice({
    required this.socket,
    this.onDeviceClosed,
  });

  Future<String> init() async {
    Completer<String> deviceIdCompleter = Completer();
    _clientServiceSubscription = socket?.listen((data) {
      String response = utf8.decode(data);
      logInfo('Data from client: $response');
      if (response.startsWith('device_id:')) {
        if (!deviceIdCompleter.isCompleted) {
          deviceId = response.replaceFirst('device_id:', '');
          deviceIdCompleter.complete(deviceId);
        }
      }
    }, onDone: () {
      logError('Client disconnected');
      onDeviceClosed?.call(deviceId);
      dispose();
    });
    return deviceIdCompleter.future;
  }

  void dispose() {
    _clientServiceSubscription?.cancel();
    socket?.close();
    socket = null;
  }

  void registerHid() {
    final message = _UhidServerMessage(
      command: _UhidServerMessage.open,
      data: combinedReport,
    );
    socket?.add(message.bytes);
  }

  void closeDevice() {
    final message = _UhidServerMessage(
      command: _UhidServerMessage.close,
    );
    socket?.add(message.bytes);
  }

  Future<void> sendHidReport(String deviceId, List<int> inputReport) async {
    final message = _UhidServerMessage(
      command: _UhidServerMessage.write,
      data: inputReport,
    );
    socket?.add(message.bytes);
  }
}

class _UhidServerMessage {
  static const int open = 1;
  static const int write = 2;
  static const int close = 3;

  late List<int> bytes;

  _UhidServerMessage({
    required int command,
    int deviceId = 1,
    List<int> data = const [0],
  }) {
    bytes = [command, deviceId, ...data];
  }
}
