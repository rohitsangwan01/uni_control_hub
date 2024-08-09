import 'dart:async';
import 'dart:io';

import 'package:uni_control_hub/app/services/communication_service.dart';
import 'package:uni_control_hub/app/communication/uhid/uhid_device.dart';
import 'package:uni_control_hub/app/client/client.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/data/dialog_handler.dart';
import 'package:uni_control_hub/app/services/adb_service.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';

class UhidCommunication {
  late final CommunicationService _communicationService =
      CommunicationService.to;
  late final AdbService _adbService = AdbService.to;
  late final StorageService _storageService = StorageService.to;

  int get _port => _storageService.uhidPort;
  final String _localAddress = '127.0.0.1';

  ServerSocket? server;
  StreamSubscription? _clientSubscription;

  void loadDevices() async {
    try {
      List<String> devices = await _adbService.getDevices();
      logInfo("Adb devices: $devices");
      await _startUhidSocket();
      // Push server to all devices
      for (String device in devices) {
        await _adbService.pushUniHubServerFile(device);
        logInfo("Server pushed to $device");
        await _adbService.setPortForwarding(_port, device);
        logInfo('Adb port forwarded: $_port');
        await _adbService.startUniHubServerFile(
          device: device,
          host: _localAddress,
          port: _port,
          onStop: () => logInfo('$device Server stopped'),
          onError: (error) => DialogHandler.showError(error),
        );
        logInfo("Server setup done, waiting for response from $device");
      }
    } catch (e) {
      logError("UHID Error: $e");
      DialogHandler.showError(e.toString());
    }
  }

  Future<void> _startUhidSocket() async {
    if (server != null && server?.port == _port) {
      logInfo('Server already started');
      return;
    }
    server?.close();
    server = null;

    server = await ServerSocket.bind(_localAddress, _port);
    logInfo("Server started at ${server?.address.host}:$_port");

    _clientSubscription = server?.listen(
      _onNewClient,
      onError: (e) => logError('Server error: $e'),
      onDone: () => logInfo('Server done'),
      cancelOnError: true,
    );

    logInfo('UHID Server started on port ${server?.port}');
  }

  void disposeUhid() {
    server?.close();
    _clientSubscription?.cancel();
    server = null;
    logInfo('Server stopped');
  }

  void _onNewClient(Socket socket) async {
    logInfo(
      'Connection from ${socket.remoteAddress.address}:${socket.remotePort}',
    );
    // Add client if not already exists
    UhidDevice uhidDevice = UhidDevice(
      socket: socket,
      onDeviceClosed: _onClientRemove,
    );
    String deviceId = await uhidDevice.init();

    if (_communicationService.existsDevice(deviceId)) {
      logError('Client already exists');
      uhidDevice.dispose();
      return;
    }

    logInfo('Client connected: $deviceId');
    _addClient(deviceId, uhidDevice);
  }

  void _onClientRemove(String? deviceId) async {
    if (deviceId == null) return;
    _communicationService.removeClient(deviceId);
  }

  void _addClient(String deviceId, UhidDevice uhidDevice) {
    _communicationService.addClient(
      client: Client(
        id: deviceId,
        type: ClientType.uhid,
        inputReportHandler: uhidDevice.sendHidReport,
        onConnectionUpdate: (bool isConnected) async {
          if (isConnected) {
            uhidDevice.registerHid();
          } else {
            uhidDevice.closeDevice();
          }
        },
      ),
    );
  }
}
