import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uni_control_hub/app/data/app_data.dart';
import 'package:uni_control_hub/app/services/file_service.dart';
import 'package:uni_control_hub/app/models/android_connection_type.dart';
import 'package:uni_control_hub/app/models/synergy_client.dart';

class StorageService {
  static StorageService get to => GetIt.instance<StorageService>();

  late final GetStorage _storage;

  Future<void> init() async {
    _storage = GetStorage(AppData.appName, await FileService.to.dbDirectory);
    await _storage.initStorage;
  }

  int? get synergyProcessId => _readDb('synergyProcessId');
  set synergyProcessId(int? value) => value == null
      ? _removeDb('synergyProcessId')
      : _writeDb('synergyProcessId', value);

  bool get autoStartServer => _readDb('autoStartServer') ?? false;
  set autoStartServer(bool value) => _writeDb('autoStartServer', value);

  bool get enableBluetoothConnection =>
      _readDb('enableBluetoothConnection') ?? true;
  set enableBluetoothConnection(bool value) =>
      _writeDb('enableBluetoothConnection', value);

  bool get invertMouseScroll => _readDb('invertMouseScroll') ?? false;
  set invertMouseScroll(bool value) => _writeDb('invertMouseScroll', value);

  bool get useInternalServer => _readDb('useInternalServer') ?? true;
  set useInternalServer(bool value) => _writeDb('useInternalServer', value);

  String? get testStatus => _readDb('testStatus');
  set testStatus(String? value) =>
      value == null ? _removeDb('testStatus') : _writeDb('testStatus', value);

  int get uhidPort => _readDb('uhidPort') ?? 9945;
  set uhidPort(int value) => _writeDb('uhidPort', value);

  bool get trackUsbConnectedDevices => _readDb("autoDetectUsb") ?? true;
  set trackUsbConnectedDevices(bool value) => _writeDb("autoDetectUsb", value);

  String? getClientAlias(String id) => _readDb('client_local_$id');
  void setClientAlias(String id, String alias) =>
      _writeDb('client_local_$id', alias);

  Size get clientDefaultSize {
    List<double> size = List<double>.from(_readDb("clientDefaultSize") ?? []);
    if (size.isEmpty) return const Size(8000, 8000);
    return Size(size[0], size[1]);
  }

  set clientDefaultSize(Size size) =>
      _writeDb("clientDefaultSize", [size.width, size.height]);

  AndroidConnectionType get androidConnection {
    String? value = _readDb("androidConnection");
    return AndroidConnectionType.values.firstWhere(
      (element) => element.name == value,
      orElse: () => AndroidConnectionType.aoa,
    );
  }

  set androidConnection(AndroidConnectionType value) =>
      _writeDb('androidConnection', value.name);

  SynergyClient? get synergyClient {
    final json = _readDb('synergyClient');
    if (json == null) return null;
    return SynergyClient.fromJson(json);
  }

  set synergyClient(SynergyClient? value) => value == null
      ? _removeDb('synergyClient')
      : _writeDb('synergyClient', value.toJson());

  T? _readDb<T>(String key) => _storage.read(key);
  Future<void> _writeDb<T>(String key, T value) => _storage.write(key, value);
  Future<void> _removeDb(String key) => _storage.remove(key);
}
