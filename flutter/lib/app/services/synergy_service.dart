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
import 'package:uni_control_hub/app/services/native_communication.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';
import 'package:uni_control_hub/app/synergy/synergy_config.dart';
import 'package:uni_control_hub/app/services/file_service.dart';
import 'package:uni_control_hub/app/synergy/synergy_server.dart';
import 'package:uni_control_hub/app/data/dialog_handler.dart';

class SynergyService {
  static SynergyService get to => GetIt.instance<SynergyService>();

  late final storageService = StorageService.to;
  late final nativeChannelService = NativeChannelService.to;
  late final fileService = FileService.to;

  String serverName = AppData.appName;
  Signal<bool> isSynergyServerRunning = Signal(false);
  Signal<String?> toggleKeyStroke = Signal(null);
  Signal<bool> cursorLocked = Signal(false);

  List<ClientAlias> clientAliases = <ClientAlias>[
    ClientAlias.left(),
    ClientAlias.right(),
    ClientAlias.up(),
    ClientAlias.down(),
  ];

  Future<void> init() async {
    closeServerIfRunning();
    toggleKeyStroke.value = storageService.toggleKeyStroke;

    effect(() {
      String? keyStroke = toggleKeyStroke.value;
      storageService.toggleKeyStroke = keyStroke;
    });
  }

  Future<void> toggleServer(BuildContext context) async {
    if (isSynergyServerRunning.value) {
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

    String? serverPath = await fileService.synergyServerPath;
    if (serverPath == null) throw Exception("Synergy Server not found");

    // First Ask permission on MacOS to execute this file
    if (Platform.isMacOS || Platform.isLinux) {
      await Process.run("chmod", ["+x", serverPath], runInShell: true);
      logInfo("Asked for permission");
    }

    String configPath = await fileService.configPath(_config);
    logInfo('Synergy Config: $configPath');
    int? pid = await SynergyServer.startServer(
      serverPath: serverPath,
      configPath: configPath,
      screenName: serverName,
      doNotRestartOnFailure: true,
      onLogs: onLogs,
      onErrors: _parseError,
      onStop: stopServer,
    );

    if (pid != null) {
      isSynergyServerRunning.value = true;
    }

    logInfo("Server started with pid: $pid");
    storageService.synergyProcessId = pid;
  }

  void onLogs(String logs) {
    logInfo(logs);
    String logsLower = logs.toLowerCase();
    if (logsLower.contains('cursor unlocked from current screen')) {
      DialogHandler.showSnackbar('Cursor unlocked from current screen');
      cursorLocked.value = false;
    } else if (logsLower.contains('cursor locked to current screen')) {
      DialogHandler.showSnackbar('Cursor locked to current screen');
      cursorLocked.value = true;
    }
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
    isSynergyServerRunning.value = false;
    cursorLocked.value = false;
    logInfo("Server stopped");
  }

  Future<bool> validatePermission(BuildContext context) async {
    if (Platform.isMacOS) {
      bool haveAccessibilityPermission =
          await nativeChannelService.haveMacAccessibilityPermission();
      if (!haveAccessibilityPermission) {
        haveAccessibilityPermission =
            await nativeChannelService.requestMacAccessibilityPermission();
      }
      logInfo("HaveAccessibilityPermission: $haveAccessibilityPermission");
      if (!haveAccessibilityPermission) {
        logError("Accessibility Permission not granted");
        if (context.mounted) {
          DialogHandler.showError(
            "Please grant Accessibility Permission, if already enabled, remove that and enable again",
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
        ...clientAliases.map((e) => ScreenConfig(e.name)),
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
        relativeMouseMoves: toggleKeyStroke.value != null,
        toggleKeyStroke: toggleKeyStroke.value,
      ),
    );
  }
}
