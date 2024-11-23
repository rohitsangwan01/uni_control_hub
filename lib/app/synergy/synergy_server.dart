import 'dart:developer';
import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

class SynergyServer {
  static Process? process;
  static const int defaultPort = 25800;
  static final NetworkInfo _networkInfo = NetworkInfo();

  static Future<String?> get address => _networkInfo.getWifiIP();

  // https://github.com/symless/synergy-core/wiki/Command-Line#options-for-synergy-core---server
  // use screen-name instead the hostname to identify this screen in the configuration.
  static Future<int?> startServer({
    required String serverPath,
    required String configPath,
    String? screenName,
    String? hostname,
    int? port,
    DebugLevel? debugLevel,
    bool foreground = true,
    Function(String)? onLogs,
    Function(String)? onErrors,
    Function()? onStop,
    bool doNotRestartOnFailure = false,
  }) async {
    List<String> arguments = [];
    // Add config
    arguments.addAll(['-c', configPath]);

    // Add address
    hostname ??= await address;
    if (hostname != null) {
      String address = "$hostname:${port ?? defaultPort}";
      onLogs?.call('Address: $address');
      arguments.addAll(['-a', address]);
    }

    // add server screen
    if (screenName != null) {
      arguments.addAll(['-n', screenName]);
    }

    // run in the foreground.
    if (foreground) {
      arguments.add('-f');
    }

    // Set debug level
    if (debugLevel != null) {
      arguments.addAll(['--debug', debugLevel.name]);
    }

    if (doNotRestartOnFailure) {
      arguments.add('--no-restart');
    }

    process = await Process.start(serverPath, arguments);

    log('Process id: ${process?.pid}');

    process?.stdout.listen((event) {
      onLogs?.call(String.fromCharCodes(event));
    });

    process?.stderr.listen((event) {
      onErrors?.call(String.fromCharCodes(event).toString());
    });

    process?.exitCode.then((value) {
      onErrors?.call('exitCode: $value');
      onStop?.call();
      stopServer();
    });

    return process?.pid;
  }

  static void stopServer({int? processId}) {
    if (processId != null) Process.killPid(processId);
    process?.kill();
    process = null;
  }

  static int? get processId => process?.pid;

  static bool get isRunning => process != null;
}

// ignore: constant_identifier_names
enum DebugLevel { FATAL, ERROR, WARNING, NOTE, INFO, DEBUG, DEBUG1, DEBUG2 }
