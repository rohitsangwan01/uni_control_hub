import 'dart:async';
import 'dart:io';

import 'package:uni_control_hub/app/services/communication_service.dart';
import 'package:uni_control_hub/app/communication/uhid/uhid_device.dart';
import 'package:uni_control_hub/app/client/client.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/data/dialog_handler.dart';
import 'package:uni_control_hub/app/services/adb_service.dart';
import 'package:uni_control_hub/app/synergy/synergy_server.dart';

class UhidCommunication {
  final CommunicationService _communicationService = CommunicationService.to;
  final AdbService _adbService = AdbService.to;

  static const int port = 4552;
  ServerSocket? server;
  StreamSubscription? _clientSubscription;

  void loadDevices() async {
    try {
      List<String> devices = await _adbService.getDevices();
      logInfo("Adb devices: $devices");
      String? address = await SynergyServer.address;
      if (address == null) throw "Make sure you are connected to Wifi or Lan";
      await _startUhidSocket(address);
      // Push server to all devices
      for (String device in devices) {
        await _adbService.pushUniHubServerFile(device);
        logInfo("Server pushed to $device");
        // await _adbService.setPortForwarding(port, device);
        // logInfo('Adb port forwarded: $port');
        await _adbService.startUniHubServerFile(
          device: device,
          host: address,
          port: port,
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

  Future<void> _startUhidSocket(String address) async {
    if (server != null) {
      logInfo('Server already started');
      return;
    }

    server = await ServerSocket.bind(address, port);
    logInfo("Server started at ${server?.address.host}:$port");

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
