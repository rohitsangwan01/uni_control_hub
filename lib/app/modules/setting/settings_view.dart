import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/modules/setting/android_connection_mode_tile.dart';
import 'package:uni_control_hub/app/modules/setting/uhid_port_tile.dart';
import 'package:uni_control_hub/app/services/communication_service.dart';
import 'package:uni_control_hub/app/data/capabilities.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';
import 'package:uni_control_hub/app/services/synergy_service.dart';

class SettingsView extends StatelessWidget {
  SettingsView({super.key});

  final StorageService _storageService = StorageService.to;
  final SynergyService _synergyService = SynergyService.to;
  final CommunicationService _communicationService = CommunicationService.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Server'),
            tiles: [
              CustomSettingsTile(
                child: Watch((_) => SettingsTile.switchTile(
                      title: const Text('Use default server'),
                      initialValue: _synergyService.userInternalServer.value,
                      onToggle: (value) {
                        _storageService.useInternalServer = value;
                        _synergyService.userInternalServer.value = value;
                        if (_synergyService.isServerRunning.value) {
                          _synergyService.stopServer();
                        }
                      },
                      leading: const Icon(Icons.computer),
                    )),
              ),
              CustomSettingsTile(
                child: Watch((_) => SettingsTile.switchTile(
                      enabled: _synergyService.userInternalServer.value,
                      title: const Text('Auto start server on launch'),
                      initialValue: _synergyService.autoStartServer.value,
                      onToggle: (value) {
                        _synergyService.autoStartServer.value = value;
                        _storageService.autoStartServer = value;
                      },
                      leading: const Icon(Icons.mouse),
                    )),
              ),
              if (Capabilities.supportsBleConnection)
                CustomSettingsTile(
                  child: Watch((_) => SettingsTile.switchTile(
                        title: const Text('Enable Bluetooth connection'),
                        initialValue:
                            _communicationService.isPeripheralModeEnabled.value,
                        onToggle: (value) {
                          _communicationService.isPeripheralModeEnabled.value =
                              value;
                          _storageService.enableBluetoothConnection = value;
                        },
                        leading: const Icon(Icons.bluetooth),
                      )),
                ),
            ],
          ),
          SettingsSection(
            title: const Text('Client'),
            tiles: [
              const CustomSettingsTile(
                child: AndroidConnectionModeTile(),
              ),
              const CustomSettingsTile(
                child: UhidPortTile(),
              ),
              CustomSettingsTile(
                child: Watch(
                  (_) => SettingsTile.switchTile(
                    title: const Text('Invert Mouse Scroll'),
                    initialValue: _synergyService.invertMouseScroll.value,
                    onToggle: (value) {
                      _synergyService.invertMouseScroll.value = value;
                      _storageService.invertMouseScroll = value;
                    },
                    leading: const Icon(Icons.swap_vert),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
