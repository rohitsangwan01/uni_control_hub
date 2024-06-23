import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

/// Common Service for the app
class AppService {
  static AppService get to => GetIt.instance<AppService>();

  final navigatorKey = GlobalKey<NavigatorState>();
  BuildContext? get overlayContext =>
      navigatorKey.currentState?.overlay?.context;

  Future<void> init() async {
    addLicenses();
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
