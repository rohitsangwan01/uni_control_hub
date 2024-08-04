import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/data/app_data.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/models/client_alias.dart';
import 'package:uni_control_hub/app/models/screen_config.dart';
import 'package:uni_control_hub/app/models/screen_link.dart';
import 'package:uni_control_hub/app/models/screen_options.dart';
import 'package:uni_control_hub/app/data/native_communication.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';
import 'package:uni_control_hub/app/synergy/synergy_config.dart';
import 'package:uni_control_hub/app/services/file_service.dart';
import 'package:uni_control_hub/app/synergy/synergy_server.dart';
import 'package:uni_control_hub/app/data/dialog_handler.dart';

class SynergyService {
  static SynergyService get to => GetIt.instance<SynergyService>();

  late final storageService = StorageService.to;

  String serverName = AppData.appName;
  Signal<bool> userInternalServer = Signal(true);
  Signal<bool> autoStartServer = Signal(false);
  Signal<bool> isServerRunning = Signal(false);
  Signal<bool> invertMouseScroll = Signal(false);

  List<ClientAlias> clientAliases = <ClientAlias>[
    ClientAlias.left(),
    ClientAlias.right(),
    ClientAlias.up(),
    ClientAlias.down(),
  ];

  Future<void> init() async {
    closeServerIfRunning();
    userInternalServer.value = storageService.useInternalServer;
    autoStartServer.value = storageService.autoStartServer;
    invertMouseScroll.value = storageService.invertMouseScroll;
  }

  Future<void> toggleServer(BuildContext context) async {
    if (isServerRunning.value) {
      await stopServer();
    } else {
      await startServer(context);
    }
  }

  void closeServerIfRunning() {
    int? perviousPid = storageService.synergyProcessId;
    if (perviousPid != null) {
      logInfo("Killing previous process $perviousPid");
      logInfo("$perviousPid Kill status: ${Process.killPid(perviousPid)}");
    }
  }

  Future<void> startServer(BuildContext context) async {
    if (!await validatePermission(context)) {
      return;
    }

    closeServerIfRunning();
    logInfo("Trying to Start");

    String? serverPath = await FileService.to.synergyServerPath;
    if (serverPath == null) throw Exception("Synergy Server not found");

    // First Ask permission on MacOS to execute this file
    if (Platform.isMacOS || Platform.isLinux) {
      await Process.run("chmod", ["+x", serverPath], runInShell: true);
      logInfo("Asked for permission");
    }

    String configPath = await FileService.to.configPath(_config);
    logInfo('Synergy Config: $configPath');
    int? pid = await SynergyServer.startServer(
      serverPath: serverPath,
      configPath: configPath,
      screenName: serverName,
      doNotRestartOnFailure: true,
      onLogs: logInfo,
      onErrors: _parseError,
      onStop: stopServer,
    );

    if (pid != null) {
      isServerRunning.value = true;
    }

    logInfo("Server started with pid: $pid");
    storageService.synergyProcessId = pid;
  }

  void _parseError(error) {
    logError(error);
    if (error.toString().contains("Address already in use")) {
      DialogHandler.showError(
        "Cannot start server, Address already in use. Please stop if any other server is running on port ${SynergyServer.defaultPort}",
      );
    }
  }

  Future<void> stopServer() async {
    SynergyServer.stopServer();
    storageService.synergyProcessId = null;
    isServerRunning.value = false;
    logInfo("Server stopped");
  }

  Future<bool> validatePermission(BuildContext context) async {
    if (Platform.isMacOS) {
      bool haveAccessibilityPermission =
          await NativeCommunication.haveMacAccessibilityPermission();
      if (!haveAccessibilityPermission) {
        haveAccessibilityPermission =
            await NativeCommunication.requestMacAccessibilityPermission();
      }
      logInfo("HaveAccessibilityPermission: $haveAccessibilityPermission");
      if (!haveAccessibilityPermission) {
        logError("Accessibility Permission not granted");
        if (context.mounted) {
          DialogHandler.showError(
            "Accessibility Permission not granted",
          );
        }
        return false;
      }
    }
    return true;
  }

  SynergyConfig get _config {
    return SynergyConfig(
      screens: [
        ScreenConfig(serverName),
        ...clientAliases.map((e) => ScreenConfig(e.name)).toList(),
      ],
      links: [
        ScreenLink(
          serverName,
          clientAliases
              .map((e) => Connection(e.direction.value, e.name))
              .toList(),
        ),
        ...clientAliases.map((e) => ScreenLink(
              e.name,
              [Connection(e.direction.value.opposite(), serverName)],
            )),
      ],
      options: ScreenOptions(
        clipboardSharing: false,
      ),
    );
  }
}
