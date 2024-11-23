import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:ble_peripheral/ble_peripheral.dart';
import 'package:uni_control_hub/app/client/report_handler.dart';

class BlePeripheralUtils {
  /// Device
  final deviceName = "UniHub";
  final _manufacturer = "uni-hub";
  final _serialNumber = "12345678";
  final List<int> _responseHidInformation = [0x11, 0x01, 0x00, 0x03];

  /// Services
  final serviceBleHid = "00001812-0000-1000-8000-00805F9B34FB";
  final serviceDeviceInfo = "0000180A-0000-1000-8000-00805F9B34FB";
  final serviceBattery = "0000180F-0000-1000-8000-00805F9B34FB";
  final serviceBleHidShort = "1812";

  /// Characteristics
  static const characteristicManufacturerName =
      "00002A29-0000-1000-8000-00805F9B34FB";
  static const characteristicModelNumber =
      "00002A24-0000-1000-8000-00805F9B34FB";
  static const characteristicSerialNumber =
      "00002A25-0000-1000-8000-00805F9B34FB";
  static const characteristicBatteryLevel =
      "00002A19-0000-1000-8000-00805F9B34FB";
  static const characteristicHidInformation =
      "00002A4A-0000-1000-8000-00805F9B34FB";
  static const characteristicReportMap = "00002A4B-0000-1000-8000-00805F9B34FB";
  static const characteristicHidControlPoint =
      "00002A4C-0000-1000-8000-00805F9B34FB";
  static const characteristicReport = "00002A4D-0000-1000-8000-00805F9B34FB";
  static const characteristicProtocolMode =
      "00002A4E-0000-1000-8000-00805F9B34FB";
  static const descriptorReportReference =
      "00002908-0000-1000-8000-00805F9B34FB";

  ReadRequestResult? onReadRequest(
    String deviceId,
    String characteristicId,
    int offset,
    Uint8List? value,
  ) {
    log("characteristic ReadRequires: $characteristicId -> $offset");
    ReadRequestResult? result = switch (characteristicId.toUpperCase()) {
      characteristicHidInformation => _toReadRequest(_responseHidInformation),
      characteristicHidControlPoint => _toReadRequest([0x00]),
      characteristicReport => _toReadRequest([]),
      characteristicSerialNumber => _toReadRequest(utf8.encode(_serialNumber)),
      characteristicModelNumber => _toReadRequest(utf8.encode(deviceName)),
      characteristicBatteryLevel => _toReadRequest([0x64]),
      characteristicReportMap =>
        _toReadRequest(combinedReport, offset, deviceId),
      characteristicManufacturerName =>
        _toReadRequest(utf8.encode(_manufacturer)),
      _ => null,
    };
    if (result == null) {
      log("ReadRequestNotHandled: $characteristicId");
    }
    return result;
  }

  /// Services to be added
  late final BleService hidService = BleService(
    uuid: serviceBleHid,
    primary: true,
    characteristics: [
      BleCharacteristic(
        uuid: characteristicHidInformation,
        properties: [
          CharacteristicProperties.read.index,
          CharacteristicProperties.write.index,
          CharacteristicProperties.notify.index,
        ],
        value: null,
        permissions: [
          AttributePermissions.readEncryptionRequired.index,
          AttributePermissions.writeEncryptionRequired.index,
        ],
      ),
      BleCharacteristic(
        uuid: characteristicReportMap,
        properties: [CharacteristicProperties.read.index],
        value: null,
        permissions: [AttributePermissions.readEncryptionRequired.index],
      ),
      BleCharacteristic(
        uuid: characteristicProtocolMode,
        properties: [
          CharacteristicProperties.read.index,
          CharacteristicProperties.write.index,
        ],
        value: null,
        permissions: [
          AttributePermissions.readEncryptionRequired.index,
          AttributePermissions.writeEncryptionRequired.index,
        ],
      ),
      BleCharacteristic(
        uuid: characteristicHidControlPoint,
        properties: [CharacteristicProperties.write.index],
        value: null,
        permissions: [AttributePermissions.writeEncryptionRequired.index],
      ),
      BleCharacteristic(
        uuid: characteristicReport,
        properties: [
          CharacteristicProperties.read.index,
          CharacteristicProperties.write.index,
          CharacteristicProperties.notify.index,
        ],
        value: null,
        permissions: [
          AttributePermissions.readEncryptionRequired.index,
          AttributePermissions.writeEncryptionRequired.index,
        ],
        descriptors: [
          BleDescriptor(
            uuid: descriptorReportReference,
            permissions: [
              AttributePermissions.readEncryptionRequired.index,
              AttributePermissions.writeEncryptionRequired.index,
            ],
            value: Uint8List.fromList([0, 1]),
          ),
        ],
      ),
    ],
  );

  late final BleService deviceInfoService = BleService(
    uuid: serviceDeviceInfo,
    primary: true,
    characteristics: [
      BleCharacteristic(
        uuid: characteristicManufacturerName,
        properties: [CharacteristicProperties.read.index],
        value: null,
        permissions: [AttributePermissions.readEncryptionRequired.index],
      ),
      BleCharacteristic(
        uuid: characteristicModelNumber,
        properties: [CharacteristicProperties.read.index],
        value: null,
        permissions: [AttributePermissions.readEncryptionRequired.index],
      ),
      BleCharacteristic(
        uuid: characteristicSerialNumber,
        properties: [CharacteristicProperties.read.index],
        value: null,
        permissions: [AttributePermissions.readEncryptionRequired.index],
      ),
    ],
  );

  late final BleService batteryService = BleService(
    uuid: serviceBattery,
    primary: true,
    characteristics: [
      BleCharacteristic(
        uuid: characteristicBatteryLevel,
        properties: [
          CharacteristicProperties.read.index,
          CharacteristicProperties.notify.index,
        ],
        value: null,
        permissions: [AttributePermissions.readEncryptionRequired.index],
      ),
    ],
  );

  ReadRequestResult? _toReadRequest(
    List<int> data, [
    int? offset,
    String? deviceId,
  ]) {
    // Handle offset
    if (offset != null) {
      if (offset != 0) {
        int remaining = data.length - offset;
        if (remaining > 0) {
          data = data.sublist(offset, data.length);
        } else {
          data = [];
        }
      }
      // log("ReadRequestOffset: $deviceId $offset -> ${data.length} : $data");
    }

    // Return data with offset 0
    return ReadRequestResult(
      value: Uint8List.fromList(data),
      offset: offset ?? 0,
    );
  }
}
