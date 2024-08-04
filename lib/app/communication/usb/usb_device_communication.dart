import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:uni_control_hub/app/services/file_service.dart';
import 'package:uni_control_hub/app/services/adb_service.dart';
import 'package:uni_control_hub/app/services/communication_service.dart';
import 'package:uni_control_hub/app/client/report_handler.dart';
import 'package:uni_control_hub/app/communication/usb/usb_hid_device.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/client/client.dart';
import 'package:uni_control_hub/app/models/usb_device.dart';
import 'package:uni_control_hub/generated/generated_bindings.dart';

class UsbDeviceCommunication {
  final CommunicationService _communicationService = CommunicationService.to;

  LibUsbDesktop? usbDesktop;
  NativeLibrary? libUsb;
  List<UsbHidDevice> _activeDevices = [];

  void setup() {
    try {
      String? libUsbFile = FileService.to.libUsbBinaryPath;
      if (libUsbFile == null) {
        logError('LibUsb not found for this platform');
        return;
      }
      libUsb = NativeLibrary(DynamicLibrary.open(libUsbFile));
      usbDesktop = LibUsbDesktop(libUsb!)..init();
      logInfo('LibUsb Initialized for this platform');
    } catch (e) {
      logError(e);
    }
  }

  void loadDevices() async {
    List<UsbHidDevice> aoaDevices = await _getAOADevicesList();

    List<UsbHidDevice> newDevices = [];
    List<UsbHidDevice> removedDevices = [];

    for (UsbHidDevice device in aoaDevices) {
      if (!_activeDevices.contains(device.deviceId)) {
        newDevices.add(device);
      }
    }

    for (UsbHidDevice device in _activeDevices) {
      if (!aoaDevices.any((element) => element.deviceId == device.deviceId)) {
        removedDevices.add(device);
      }
    }

    if (aoaDevices.isEmpty && _activeDevices.isNotEmpty) {
      removedDevices.addAll(_activeDevices);
    }

    for (UsbHidDevice device in newDevices) {
      _addDevice(device);
    }

    for (UsbHidDevice device in removedDevices) {
      _communicationService.removeClient(device.deviceId);
    }

    _activeDevices = aoaDevices;
  }

  Future<List<UsbHidDevice>> _getAOADevicesList() async {
    try {
      await _closeAdbServerIfRequires();
      var devices = usbDesktop?.getDeviceList() ?? [];
      List<UsbHidDevice> usbHidDevices = [];
      for (UsbDevice device in devices) {
        // if its already in old devices, skip
        int? index =
            _activeDevices.indexWhere((e) => e.usbDevice.uid == device.uid);
        if (index != -1) {
          usbHidDevices.add(_activeDevices[index]);
          continue;
        }

        UsbHidDevice? usbHidDevice = UsbHidDevice(libUsb!, device);
        try {
          usbHidDevice.openDevice(loadDescription: true);
          // Skip if manufacturer is null
          if (usbHidDevice.manufacturer == null) {
            usbHidDevice.close();
            continue;
          }
          usbHidDevice.registerHid(combinedReport.length);
          usbHidDevice.close();
          usbHidDevices.add(usbHidDevice);
        } catch (e) {
          // log("Ignoring ${usbHidDevice.deviceId} is not valid AOA device, $e");
        }
      }
      return usbHidDevices;
    } catch (e) {
      logError(e);
      return [];
    }
  }

  void _addDevice(UsbHidDevice usbHidDevice) {
    if (_communicationService.existsDevice(usbHidDevice.deviceId)) return;
    Client client = Client(
      id: usbHidDevice.deviceId,
      type: ClientType.usb,
      inputReportHandler: (deviceId, inputReport) async {
        _sendHidReport(usbHidDevice, inputReport);
      },
      onConnectionUpdate: (bool isConnected) async {
        if (isConnected) {
          _onClientConnected(usbHidDevice);
        } else {
          _onClientDisconnected(usbHidDevice);
        }
      },
    );
    usbHidDevice.client = client;
    _communicationService.addClient(client: client);
  }

  void _sendHidReport(UsbHidDevice usbHidDevice, inputReport) {
    try {
      usbHidDevice.sendHidEvent(inputReport);
    } catch (e) {
      _handleError(e, usbHidDevice);
    }
  }

  Future<void> _onClientConnected(UsbHidDevice usbHidDevice) async {
    try {
      usbHidDevice.openDevice();
      usbHidDevice.registerHid(combinedReport.length);
      await usbHidDevice.sendHidDescriptor(
        combinedReport,
        combinedReport.length,
      );
    } catch (e) {
      _handleError(e, usbHidDevice);
    }
  }

  void _onClientDisconnected(UsbHidDevice usbHidDevice) {
    try {
      usbHidDevice.unregisterHID();
      usbHidDevice.close();
    } catch (e) {
      _handleError(e, usbHidDevice);
    }
  }

  void _handleError(e, UsbHidDevice usbHidDevice) {
    var invalidError = [
      "LIBUSB_ERROR_NO_DEVICE",
      "FAILED_TO_OPEN_DEVICE",
      "LIBUSB_ERROR_NOT_FOUND"
    ];
    if (invalidError.contains(e.toString())) {
      if (!_activeDevices.contains(usbHidDevice.deviceId)) return;
      log("Device not found, or failed to open");
      _communicationService.removeClient(usbHidDevice.deviceId);
      _activeDevices.remove(usbHidDevice.deviceId);
    } else {
      log(e.toString());
      usbHidDevice.client?.error.value = e.toString();
    }
  }

  // We have to kill AdbServer on Windows to make USB work
  Future<void> _closeAdbServerIfRequires() async {
    if (!Platform.isWindows) return;
    await AdbService.to.killServer();
  }
}
