import 'package:signals_flutter/signals_flutter.dart';
import 'package:synergy_client_dart/synergy_client_dart.dart';
import 'package:uni_control_hub/app/data/client_screen.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/models/client_alias.dart';
import 'package:uni_control_hub/app/models/screen_link.dart';
import 'package:uni_control_hub/app/models/synergy_client.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';
import 'package:uni_control_hub/app/services/synergy_service.dart';
import 'package:uni_control_hub/app/synergy/synergy_server.dart';

typedef InputReportHandler = Future<void> Function(
  String deviceId,
  List<int> inputReport,
);

enum ClientType { ble, usb, uhid }

class Client {
  String id;
  Function(bool)? onConnectionUpdate;
  late final ScreenInterface screen;
  late final StorageService storageService = StorageService.to;

  final ClientType type;

  Signal<bool> isConnected = Signal(false, autoDispose: true);

  Signal<String?> error = Signal<String?>(null, autoDispose: true);

  Signal<ClientAlias> clientAlias = Signal(
    SynergyService.to.clientAliases.first,
    autoDispose: true,
  );

  bool _lastConnectedValue = false;

  SynergyClientDart? synergyClient;
  Direction get direction => clientAlias.value.direction.value;

  Client({
    required this.id,
    required this.type,
    required InputReportHandler inputReportHandler,
    this.onConnectionUpdate,
  }) {
    screen = ClientScreen(this, inputReportHandler);

    // Try to load alias from cache
    String? clientAliasCache = storageService.getClientAlias(id);
    clientAlias.value = SynergyService.to.clientAliases.firstWhere(
      (element) => element.name == clientAliasCache,
      orElse: () => SynergyService.to.clientAliases.first,
    );
  }

  void setConnected(bool connected) {
    if (_lastConnectedValue == connected) return;
    _lastConnectedValue = connected;
    logInfo("Client $id is connected: $connected");
    isConnected.value = connected;
    onConnectionUpdate?.call(isConnected.value);
  }

  void changeAlias(ClientAlias? alias) {
    if (alias == null) return;
    bool isSameDirection = alias.name == clientAlias.value.name;
    if (isSameDirection) {
      logInfo("Client $id is already in the same direction");
      return;
    }
    if (!isConnected.value) return;
    clientAlias.value = alias;
    storageService.setClientAlias(id, alias.name);
    // Disconnect and reconnect to server, to change direction
    disconnectSynergyServer(notifyConnectionState: false);
    connectSynergySever();
  }

  void toggleConnection() {
    isConnected.value = !isConnected.value;
    setConnected(isConnected.value);
    if (isConnected.value) {
      connectSynergySever();
    } else {
      disconnectSynergyServer();
    }
  }

  void connectSynergySever() async {
    error.value = null;
    try {
      SynergyClient? synergyCl = await _getAddress();
      logInfo("Synergy Client: $synergyCl");
      if (synergyCl == null) return;
      synergyClient = SynergyClientDart();
      await synergyClient?.connect(
        screen: screen,
        synergyServer: SocketServer(
          synergyCl.serverAddress,
          synergyCl.serverPort,
        ),
        clientName: synergyCl.clientName,
      );
    } catch (e) {
      logError(e);
      error.value = "Error connecting to Synergy Server";
    }
  }

  Future<SynergyClient?> _getAddress() async {
    // check if synergy serer is ready
    if (StorageService.to.useInternalServer) {
      if (!SynergyService.to.isServerRunning.value) {
        logInfo("Synergy Server is not running");
        error.value = "Server is not running, please start the server.";
        setConnected(false);
        return null;
      }
    }

    // Connect to external server
    else {
      SynergyClient? synergyClient = StorageService.to.synergyClient;
      if (synergyClient == null) {
        error.value = "Please add a Synergy Server";
        setConnected(false);
        return null;
      }
      return synergyClient;
    }

    return SynergyClient(
      clientName: clientAlias.value.name,
      serverAddress: await SynergyServer.address ?? "0.0.0.0",
      serverPort: SynergyServer.defaultPort,
    );
  }

  void disconnectSynergyServer({
    bool notifyConnectionState = true,
  }) {
    synergyClient?.disconnect();
    synergyClient = null;
    if (notifyConnectionState) setConnected(false);
  }
}
