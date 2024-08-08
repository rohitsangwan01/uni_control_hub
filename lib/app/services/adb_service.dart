import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:uni_control_hub/app/services/file_service.dart';
import 'package:uni_control_hub/app/data/logger.dart';

class AdbService {
  static AdbService get to => GetIt.instance<AdbService>();

  Future<void> init() async {}

  Future<List<String>> getDevices() async {
    await _startAdbServerIfNotRunning();
    final result = await Process.run('adb', ['devices'], runInShell: true);

    if (result.stderr.isNotEmpty) {
      if (result.stderr.contains('daemon not running; starting now at')) {
        throw 'Adb not running';
      }
      throw Exception(result.stderr?.toString() ?? "Something went wrong");
    }

    String stdOut = result.stdout;
    final lines = stdOut.split('\n')
      ..removeAt(0)
      ..removeWhere((element) => element.trim().isEmpty);
    final devices = <String>[];
    for (final line in lines) {
      final parts = line.trim().split('\t');
      if (parts.isEmpty) continue;
      devices.add(parts.first);
    }
    return devices;
  }

  Future<void> pushUniHubServerFile([String? device]) async {
    // adb push UniHubServer.jar /data/local/tmp/
    List<String> args = [];
    if (device != null) {
      args.add('-s');
      args.add(device);
    }

    String filePath = await FileService.to.uniHubAndroidServerPath;
    args.add('push');
    args.add(filePath);
    args.add('/data/local/tmp/');

    final result = await Process.run('adb', args, runInShell: true);

    if (result.stderr.isNotEmpty) {
      throw Exception(result.stderr);
    }
    return result.stdout;
  }

  Future<void> startUniHubServerFile({
    required String host,
    required int port,
    String? device,
    Function(String error)? onError,
    VoidCallback? onStop,
  }) async {
    // adb shell CLASSPATH=/data/local/tmp/UniHubServer.jar app_process / UniHubServer
    List<String> args = [];
    if (device != null) {
      args.add('-s');
      args.add(device);
    }
    args.add('shell');
    args.add('CLASSPATH=/data/local/tmp/UniHubServer.jar');
    args.add('app_process');
    args.add('/');
    args.add('UniHubServer');
    if (device != null) {
      args.add('-deviceId');
      args.add(device);
    }
    args.add('-port');
    args.add('$port');
    args.add('-host');
    args.add(host);

    Process result = await Process.start('adb', args, runInShell: true);

    result.stdout.listen((event) {
      String log = utf8.decode(event);
      logDebug("UniHubAndroidServer Stdout: $log");
      if (log.contains("failed to connect")) {
        onError?.call(
          "Failed to Connect, make sure you are connected on same network",
        );
      } else if (log.contains('Error')) {
        onError?.call(log);
      }
    });

    result.stderr.listen((event) {
      String error = utf8.decode(event);
      logDebug("UniHubAndroidServer Stderr: $error");
      onError?.call(error);
    });

    result.exitCode.then((value) {
      logDebug("UniHubAndroidServer ExitCode: $value");
      onStop?.call();
    });
  }

  Future<void> killServer() async {
    try {
      logInfo("Killing Adb Server (if any)");
      ProcessResult result = await Process.run('adb', ['kill-server']);
      logInfo('AdbKillServer: ${result.exitCode}');
    } catch (e) {
      log(e.toString());
    }
  }

  /// Starts ADB server if not running already
  ///
  /// Might not work on MacOS yet: https://github.com/flutter/flutter/issues/89837
  Future<void> _startAdbServerIfNotRunning() async {
    logInfo("Checking Adb Server");
    try {
      await Process.run('adb', [], runInShell: true);
    } on ProcessException catch (err) {
      throw "Adb Executable not found $err";
    }
    for (int i = 0; i < 5; i++) {
      logInfo('Trying to start adb server');
      final result = await Process.run(
        'adb',
        ['start-server'],
        runInShell: true,
      );
      if (result.stderr.contains('daemon not running; starting now at')) {
        await Future<void>.delayed(const Duration(seconds: 1));
      } else {
        break;
      }
    }
  }
}
