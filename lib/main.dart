import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/services/communication_service.dart';
import 'package:uni_control_hub/app/modules/dashboard/dashboard_view.dart';
import 'package:uni_control_hub/app/services/adb_service.dart';
import 'package:uni_control_hub/app/services/app_service.dart';
import 'package:uni_control_hub/app/services/client_service.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';
import 'package:uni_control_hub/app/services/synergy_service.dart';
import 'package:window_manager/window_manager.dart';

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable Signal logs
  SignalsObserver.instance = null;

  // Set default window size
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(500, 800),
    minimumSize: Size(300, 600),
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize services
  var getIt = GetIt.instance;
  await getIt.registerSingleton(AppService()).init();
  await getIt.registerSingleton(StorageService()).init();
  await getIt.registerSingleton(SynergyService()).init();
  await getIt.registerSingleton(AdbService()).init();
  await getIt.registerSingleton(CommunicationService()).init();
  await getIt.registerSingleton(ClientService()).init();
}

void main() async {
  await _initialize();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: AppService.to.navigatorKey,
      title: "UniControlHub",
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const DashboardView(),
    ),
  );
}
