import 'dart:developer';
import 'dart:io';

import 'dart:typed_data';

import 'package:ble_peripheral/ble_peripheral.dart';
import 'package:uni_control_hub/app/communication/ble/ble_peripheral_utils.dart';
import 'package:uni_control_hub/app/services/communication_service.dart';
import 'package:uni_control_hub/app/data/capabilities.dart';
import 'package:uni_control_hub/app/client/client.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/data/dialog_handler.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';

class BlePeripheralCommunication {
  final CommunicationService _communicationService = CommunicationService.to;

  late final _blePeripheralUtils = BlePeripheralUtils();

  bool _servicesAdded = false;
  bool _isInitialized = false;

  void setup() async {
    _communicationService.isPeripheralModeEnabled.value =
        Capabilities.supportsBleConnection &&
            StorageService.to.enableBluetoothConnection;

    if (_communicationService.isPeripheralModeEnabled.value) {
      _setupListeners();
    }
  }

  Future<void> toggleAdvertising() async {
    if (_communicationService.isPeripheralAdvertising.value) {
      await stopAdvertising();
    } else {
      await startAdvertising();
    }
  }

  Future<void> startAdvertising() async {
    await _lazyInitAndAddServices();

    List<String> advertisingServices = [];
    if (Platform.isIOS || Platform.isMacOS) {
      advertisingServices.add(_blePeripheralUtils.serviceBleHidShort);
    } else {
      advertisingServices.add(_blePeripheralUtils.serviceBleHid);
    }

    await BlePeripheral.startAdvertising(
      services: advertisingServices,
      localName: _blePeripheralUtils.deviceName,
    );
  }

  Future<void> stopAdvertising() async {
    await BlePeripheral.stopAdvertising();
  }

  Future<void> _lazyInitAndAddServices() async {
    if (!_isInitialized) {
      await BlePeripheral.initialize();
      _isInitialized = true;
    }

    if (!_servicesAdded) {
      // Can't add DeviceInfo service on Windows, because its restricted by Windows
      if (!Platform.isWindows) {
        await BlePeripheral.addService(_blePeripheralUtils.deviceInfoService);
      }
      // Add HID and battery service
      await BlePeripheral.addService(_blePeripheralUtils.hidService);
      await BlePeripheral.addService(_blePeripheralUtils.batteryService);
      _servicesAdded = true;
    }
  }

  void _handleCharacteristicSubscriptionChange(
    String deviceId,
    String characteristicId,
    bool isSubscribed,
  ) {
    if (characteristicId.toUpperCase() ==
        BlePeripheralUtils.characteristicReport) {
      if (isSubscribed) {
        if (_addNewClient(deviceId)) {
          logInfo("Subscribed to HID: $deviceId");
        }
      } else if (_communicationService.existsDevice(deviceId)) {
        if (_communicationService.removeClient(deviceId)) {
          logInfo("Unsubscribed to HID: $deviceId");
        }
      }
    }
  }

  bool _addNewClient(String deviceId) {
    if (_communicationService.existsDevice(deviceId)) return false;
    return _communicationService.addClient(
      client: Client(
        id: deviceId,
        type: ClientType.ble,
        inputReportHandler: _addInputReport,
      ),
    );
  }

  Future<void> _addInputReport(String deviceId, List<int> inputReport) async {
    if (inputReport.isEmpty) return;
    await BlePeripheral.updateCharacteristic(
      deviceId: deviceId,
      characteristicId: BlePeripheralUtils.characteristicReport,
      value: Uint8List.fromList(inputReport),
    );
  }

  void _setupListeners() async {
    BlePeripheral.isAdvertising().then((value) {
      log("isAdvertising: $value");
      if (value != null) {
        _communicationService.isPeripheralAdvertising.value = value;
      }
    });

    BlePeripheral.setAdvertisingStatusUpdateCallback((advertising, error) {
      _communicationService.isPeripheralAdvertising.value = advertising;
      log("Advertising: $advertising");
      if (error != null) {
        log("AdvertisingError: $error");
        DialogHandler.showError("Advertising Error: $error");
      }
    });

    BlePeripheral.setCharacteristicSubscriptionChangeCallback(
      _handleCharacteristicSubscriptionChange,
    );

    BlePeripheral.setReadRequestCallback(
      _blePeripheralUtils.onReadRequest,
    );
  }
}
