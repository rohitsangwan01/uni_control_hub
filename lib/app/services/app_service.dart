import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mixin_logger/mixin_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uni_control_hub/app/services/native_communication.dart';
import 'package:uni_control_hub/app/services/file_service.dart';
import 'package:uni_control_hub/app/services/synergy_service.dart';

class AppService {
  static AppService get to => GetIt.instance<AppService>();

  late final nativeChannelService = NativeChannelService.to;
  late final fileService = FileService.to;
  late final synergyService = SynergyService.to;

  String appVersion = 'Unknown';
  final navigatorKey = GlobalKey<NavigatorState>();
  BuildContext? get overlayContext =>
      navigatorKey.currentState?.overlay?.context;

  Future<void> init() async {
    addLicenses();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    initLogger(
      await fileService.logsDirectory,
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
