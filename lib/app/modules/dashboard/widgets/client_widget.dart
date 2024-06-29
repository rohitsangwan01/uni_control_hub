import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/data/extensions.dart';
import 'package:uni_control_hub/app/models/client_alias.dart';
import 'package:uni_control_hub/app/data/client.dart';
import 'package:uni_control_hub/app/modules/dashboard/widgets/client_mouse_widget.dart';
import 'package:uni_control_hub/app/services/synergy_service.dart';

class ClientWidget extends StatelessWidget {
  final Client client;
  const ClientWidget({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Watch((_) => Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  client.type == ClientType.ble
                      ? Icons.bluetooth
                      : client.type == ClientType.usb
                          ? Icons.usb
                          : Icons.adb,
                ),
                title: Text(
                  client.id,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                trailing: Switch.adaptive(
                  value: client.isConnected.value,
                  onChanged: (value) {
                    client.toggleConnection();
                  },
                ),
              ),
              const Divider(),
              Row(
                children: [
                  const SizedBox(width: 16.0),
                  _DirectionWidget(client: client),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClientMouseWidget(client: client),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fit_screen),
                  ),
                ],
              ),
              _ErrorWidget(client.error.value),
            ],
          ),
        ));
  }
}

class _DirectionWidget extends StatelessWidget {
  final Client client;
  const _DirectionWidget({required this.client});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ClientAlias>(
      value: client.clientAlias.value,
      elevation: 0,
      underline: const SizedBox(),
      enableFeedback: false,
      focusColor: Colors.transparent,
      items: SynergyService.to.clientAliases
          .map((e) => DropdownMenuItem<ClientAlias>(
                value: e,
                child: Text(
                  "Direction: ${e.name.capitalizeFirst}",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ))
          .toList(),
      onChanged: client.changeAlias,
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String? error;
  const _ErrorWidget(this.error);

  @override
  Widget build(BuildContext context) {
    return error != null
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
            child: Text(
              error!,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          )
        : const SizedBox.shrink();
  }
}
