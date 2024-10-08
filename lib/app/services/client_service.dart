import 'package:get_it/get_it.dart';
import 'package:uni_control_hub/app/communication/ble/ble_peripheral_communication.dart';
import 'package:uni_control_hub/app/communication/uhid/uhid_communication.dart';
import 'package:uni_control_hub/app/communication/usb/usb_device_communication.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/models/android_connection_type.dart';
import 'package:uni_control_hub/app/models/usb_device.dart';
import 'package:uni_control_hub/app/services/app_service.dart';
import 'package:uni_control_hub/app/services/native_communication.dart';

class ClientService {
  static ClientService get to => GetIt.instance<ClientService>();

  late final _nativeChannelService = NativeChannelService.to;
  late final _appService = AppService.to;

  late UsbDeviceCommunication _usbDeviceService;
  late UhidCommunication _uhidService;
  late BlePeripheralCommunication _blePeripheralService;

  Future<void> init() async {
    _blePeripheralService = BlePeripheralCommunication();
    _usbDeviceService = UsbDeviceCommunication();
    _uhidService = UhidCommunication();

    // Setup clients
    _blePeripheralService.setup();
    _usbDeviceService.setup();

    _nativeChannelService.usbDeviceHandler =
        (List<UsbDevice> usbDevices, bool? connected) {
      logDebug("UsbDevice: $usbDevices Connected: $connected");
      refreshClients();
    };
  }

  void refreshClients() {
    if (_appService.androidConnection.value == AndroidConnectionType.aoa) {
      _usbDeviceService.loadDevices();
    } else {
      _uhidService.loadDevices();
    }
  }

  Future<void> togglePeripheralAdvertising() =>
      _blePeripheralService.toggleAdvertising();
}
