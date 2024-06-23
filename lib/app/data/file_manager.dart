import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uni_control_hub/app/data/app_data.dart';
import 'package:uni_control_hub/app/synergy/synergy_config.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static Future<String> uniHubAndroidServerPath() async {
    String fileName = AppData.uniHubServerPath.split('/').last;
    File file = File('${await _cachePath}/$fileName');
    if (await file.exists()) return file.path;
    final byteData = await rootBundle.load(AppData.uniHubServerPath);
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
    return file.path;
  }

  static Future<String> configPath(SynergyConfig config) async {
    var file = File('${await _cachePath}/synergy.conf');
    var content = config.getConfigText();
    File configFile = await file.writeAsString(content);
    return configFile.path;
  }

  static Future<String?> get synergyServerPath async {
    return switch (Abi.current()) {
      Abi.macosArm64 => _getMacSynergy("synergy_arm64"),
      Abi.macosX64 => _getMacSynergy("synergy_x64"),
      Abi.windowsX64 => "synergy_x64.dll",
      Abi.linuxX64 => await _getLinuxSynergy("synergy_x64"),
      _ => null,
    };
  }

  static String? get libUsbBinaryPath {
    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS => "libusb.dylib",
      TargetPlatform.windows => "libusb.dll",
      TargetPlatform.linux =>
        "${File(Platform.resolvedExecutable).parent.path}/lib/libusb.so",
      _ => null,
    };
  }

  static Future<String> get _cachePath async =>
      (await getApplicationCacheDirectory()).path;

  static Future<String> _getLinuxSynergy(String file) => _getOrSaveToCache(
      "${File(Platform.resolvedExecutable).parent.path}/lib/$file");

  static String _getMacSynergy(String file) {
    var urlSeg = List.from(File(Platform.resolvedExecutable).uri.pathSegments);
    urlSeg = urlSeg.sublist(0, urlSeg.length - 2);
    return "/${urlSeg.join('/')}/Resources/$file";
  }

  static Future<String> _getOrSaveToCache(String from) async {
    String fileName = from.split('/').last;
    File file = File('${await _cachePath}/$fileName');
    if (await file.exists()) return file.path;
    final byteData = await File(from).readAsBytes();
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
    return file.path;
  }
}
