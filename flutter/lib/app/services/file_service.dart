import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:uni_control_hub/app/synergy/synergy_config.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  static FileService get to => GetIt.instance<FileService>();

  late String _cachePath;
  final List<String> _copiedFiles = [];
  late final _executablePath = File(Platform.resolvedExecutable).parent.path;

  Future<FileService> init() async {
    _cachePath = (await getApplicationCacheDirectory()).path;
    return this;
  }

  Future<String?> get synergyServerPath async => switch (Abi.current()) {
        Abi.macosArm64 => _getMacSynergy("synergy_arm64"),
        Abi.macosX64 => _getMacSynergy("synergy_x64"),
        Abi.windowsX64 => "synergy_x64.dll",
        Abi.linuxX64 => await _getLinuxSynergy("synergy_x64"),
        _ => null,
      };

  String? get libUsbBinaryPath => switch (defaultTargetPlatform) {
        TargetPlatform.macOS => "libusb.dylib",
        TargetPlatform.windows => "libusb.dll",
        TargetPlatform.linux => "$_executablePath/lib/libusb.so",
        _ => null,
      };

  String get dbDirectory => _getDirectory('db');

  String get logsDirectory => _getDirectory('logs');

  String get assetsDirectory => _getDirectory('assets');

  String uniHubAndroidServerFile = 'UniHubServer_0.1.jar';

  Future<String> get uniHubAndroidServerPath {
    return _copyAndGetFile(
      to: join(_cachePath, uniHubAndroidServerFile),
      fromAsset: 'assets/$uniHubAndroidServerFile',
    );
  }

  Future<String> configPath(SynergyConfig config) async {
    var file = File(join(_cachePath, 'synergy.conf'));
    var content = config.getConfigText();
    File configFile = await file.writeAsString(content);
    return configFile.path;
  }

  String _getMacSynergy(String file) {
    var urlSeg = List.from(File(Platform.resolvedExecutable).uri.pathSegments);
    urlSeg = urlSeg.sublist(0, urlSeg.length - 2);
    return "/${urlSeg.join('/')}/Resources/$file";
  }

  Future<String> _getLinuxSynergy(String fileName) {
    return _copyAndGetFile(
      to: join(_cachePath, fileName),
      fromFile: "$_executablePath/lib/$fileName",
    );
  }

  /// Create a directory in cache folder
  String _getDirectory(String name) {
    String path = join(_cachePath, name);
    Directory directory = Directory(path);
    if (directory.existsSync()) return path;
    directory.createSync(recursive: true);
    return path;
  }

  /// Copy file to given path, and cache the result to reuse
  Future<String> _copyAndGetFile({
    required String to,
    String? fromFile,
    String? fromAsset,
  }) async {
    if (_copiedFiles.contains(to)) return to;
    TypedData byteData;
    if (fromFile != null) {
      byteData = await File(fromFile).readAsBytes();
    } else if (fromAsset != null) {
      byteData = await rootBundle.load(fromAsset);
    } else {
      throw "Failed to copy file";
    }
    await File(to).writeAsBytes(byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    ));
    _copiedFiles.add(to);
    return to;
  }
}
