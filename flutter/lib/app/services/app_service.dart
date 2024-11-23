import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mixin_logger/mixin_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/data/capabilities.dart';
import 'package:uni_control_hub/app/models/android_connection_type.dart';
import 'package:uni_control_hub/app/services/native_communication.dart';
import 'package:uni_control_hub/app/services/file_service.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';
import 'package:uni_control_hub/app/services/synergy_service.dart';

class AppService {
  static AppService get to => GetIt.instance<AppService>();

  late final storageService = StorageService.to;
  late final nativeChannelService = NativeChannelService.to;
  late final fileService = FileService.to;
  late final synergyService = SynergyService.to;

  String appVersion = 'Unknown';
  final navigatorKey = GlobalKey<NavigatorState>();
  BuildContext? get overlayContext =>
      navigatorKey.currentState?.overlay?.context;

  Signal<bool> userInternalServer = Signal(true);
  Signal<bool> autoStartServer = Signal(false);
  Signal<bool> invertMouseScroll = Signal(false);
  Signal<bool> enableBluetoothMode = Signal(true);
  Signal<bool> trackUsbConnectedDevices = Signal(true);
  Signal<AndroidConnectionType> androidConnection =
      Signal(AndroidConnectionType.aoa);

  void _loadInitialValues() {
    userInternalServer.value = storageService.useInternalServer;
    autoStartServer.value = storageService.autoStartServer;
    invertMouseScroll.value = storageService.invertMouseScroll;
    enableBluetoothMode.value = Capabilities.supportsBleConnection &&
        storageService.enableBluetoothConnection;
    androidConnection.value = storageService.androidConnection;
    trackUsbConnectedDevices.value = storageService.trackUsbConnectedDevices;

    // Auto sync localStorage values
    effect(() {
      storageService.useInternalServer = userInternalServer.value;
      storageService.autoStartServer = autoStartServer.value;
      storageService.invertMouseScroll = invertMouseScroll.value;
      storageService.enableBluetoothConnection = enableBluetoothMode.value;
      storageService.androidConnection = androidConnection.value;
    });

    // UsbDetection Tracker Hook
    effect(() {
      bool track = trackUsbConnectedDevices.value;
      storageService.trackUsbConnectedDevices = track;
      if (track) {
        nativeChannelService.startUsbDetection();
      } else {
        nativeChannelService.stopUsbDetection();
      }
    });
  }

  Future<void> init() async {
    _loadInitialValues();
    addLicenses();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    initLogger(
      fileService.logsDirectory,
      maxFileCount: 5,
      maxFileLength: 5 * 1024 * 1024,
    );
  }

  Future<void> disposeResources() async {
    nativeChannelService.dispose();
    synergyService.closeServerIfRunning();
  }

  void addLicenses() {
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(
        ["libusb"],
        await rootBundle.loadString('assets/licenses/libusb'),
      );
      yield LicenseEntryWithLineBreaks(
        ["synergy_core"],
        await rootBundle.loadString('assets/licenses/synergy_core'),
      );
    });
  }
}
