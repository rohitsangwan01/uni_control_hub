import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_control_hub/app/models/android_connection_type.dart';
import 'package:uni_control_hub/app/models/synergy_client.dart';

class StorageService {
  static StorageService get to => GetIt.instance<StorageService>();

  late final SharedPreferences _storage;

  Future<void> init() async {
    _storage = await SharedPreferences.getInstance();
  }

  int? get synergyProcessId => _storage.getInt('synergyProcessId');
  set synergyProcessId(int? value) => value == null
      ? _storage.remove('synergyProcessId')
      : _storage.setInt('synergyProcessId', value);

  bool get autoStartServer => _storage.getBool('autoStartServer') ?? false;
  set autoStartServer(bool value) => _storage.setBool('autoStartServer', value);

  bool get enableBluetoothConnection =>
      _storage.getBool('enableBluetoothConnection') ?? true;
  set enableBluetoothConnection(bool value) =>
      _storage.setBool('enableBluetoothConnection', value);

  bool get useInternalServer => _storage.getBool('useInternalServer') ?? true;
  set useInternalServer(bool value) =>
      _storage.setBool('useInternalServer', value);

  String? get testStatus => _storage.getString('testStatus');
  set testStatus(String? value) => value == null
      ? _storage.remove('testStatus')
      : _storage.setString('testStatus', value);

  String? getClientAlias(String id) => _storage.getString('client_local_$id');
  void setClientAlias(String id, String alias) =>
      _storage.setString('client_local_$id', alias);

  Size get clientDefaultSize {
    List<String>? size = _storage.getStringList("clientDefaultSize");
    if (size == null) return const Size(8000, 8000);
    return Size(double.parse(size[0]), double.parse(size[1]));
  }

  set clientDefaultSize(Size size) => _storage.setStringList(
      "clientDefaultSize", [size.width.toString(), size.height.toString()]);

  AndroidConnectionType get androidConnection {
    String? value = _storage.getString("androidConnection");
    return AndroidConnectionType.values.firstWhere(
      (element) => element.name == value,
      orElse: () => AndroidConnectionType.aoa,
    );
  }

  set androidConnection(AndroidConnectionType value) =>
      _storage.setString('androidConnection', value.name);

  SynergyClient? get synergyClient {
    final json = _storage.getString('synergyClient');
    if (json != null) {
      return SynergyClient.fromJsonString(json);
    }
    return null;
  }

  set synergyClient(SynergyClient? value) => value == null
      ? _storage.remove('synergyClient')
      : _storage.setString('synergyClient', value.toJsonString());

  void saveJson(String key, Map<String, dynamic> data) =>
      _storage.setString(key, json.encode(data));

  Map<String, dynamic>? readJson(String key) {
    final json = _storage.getString(key);
    if (json != null) {
      return jsonDecode(json);
    }
    return null;
  }
}
