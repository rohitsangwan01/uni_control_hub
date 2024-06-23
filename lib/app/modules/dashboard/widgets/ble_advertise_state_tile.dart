import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/services/communication_service.dart';
import 'package:uni_control_hub/app/data/info_data.dart';
import 'package:uni_control_hub/app/data/dialog_handler.dart';
import 'package:uni_control_hub/app/services/client_service.dart';

class BleAdvertiseStateTile extends StatelessWidget {
  const BleAdvertiseStateTile({super.key});

  @override
  Widget build(BuildContext context) {
    final CommunicationService communicationService = CommunicationService.to;
    final ClientService clientService = ClientService.to;
    return Watch(
      (_) => Card(
        child: ListTile(
          title: Row(
            children: [
              const Text("Connect via Bluetooth"),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  DialogHandler.showInfoDialog(
                    context: context,
                    title: "Clients",
                    text: connectButtonInfoText,
                  );
                },
                child: const Icon(
                  Icons.info_outline,
                  size: 18,
                ),
              )
            ],
          ),
          subtitle: Text(
            "Use bluetooth for emulating Mouse/Keyboard, Mainly for IOS devices",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          trailing: Switch.adaptive(
            value: communicationService.isPeripheralAdvertising.value,
            onChanged: (_) => clientService.togglePeripheralAdvertising(),
          ),
        ),
      ),
    );
  }
}
