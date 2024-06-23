import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/data/client.dart';
import 'package:uni_control_hub/app/data/extensions.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/models/android_connection_type.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';

class CommunicationService {
  static CommunicationService get to => GetIt.instance<CommunicationService>();

  final ListSignal<Client> devices = ListSignal<Client>([]);
  final Signal<bool> isPeripheralModeEnabled = Signal(true);
  final Signal<bool> isPeripheralAdvertising = Signal(false);
  final androidConnection = Signal(AndroidConnectionType.aoa);

  Future<void> init() async {
    androidConnection.value = StorageService.to.androidConnection;
  }

  bool existsDevice(String deviceId) =>
      devices.any((element) => element.id == deviceId);

  bool addClient({required Client client}) {
    if (existsDevice(client.id)) return false;
    client.connectSynergySever();
    devices.add(client);
    logInfo("Added Client ${client.id}");
    return true;
  }

  bool removeClient(String deviceId) {
    Client? client = devices.firstWhereOrNull(
      (element) => element.id == deviceId,
    );
    if (client == null) return false;
    client.disconnectSynergyServer();
    devices.remove(client);
    return true;
  }
}
