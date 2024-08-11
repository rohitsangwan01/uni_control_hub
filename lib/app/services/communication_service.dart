import 'package:get_it/get_it.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/client/client.dart';
import 'package:uni_control_hub/app/data/extensions.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';

class CommunicationService {
  static CommunicationService get to => GetIt.instance<CommunicationService>();

  final ListSignal<Client> devices = ListSignal<Client>([]);

  final Signal<bool> isPeripheralAdvertising = Signal(false);

  late final StorageService storageService = StorageService.to;

  Future<void> init() async {}

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
