import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/data/info_data.dart';
import 'package:uni_control_hub/app/data/dialog_handler.dart';
import 'package:uni_control_hub/app/services/synergy_service.dart';

class ServerStateTile extends StatelessWidget {
  const ServerStateTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((_) => Card(
          child: ListTile(
            title: Row(
              children: [
                const Text("Start Server"),
                const SizedBox(width: 5),
                InkWell(
                  onTap: () {
                    DialogHandler.showInfoDialog(
                      context: context,
                      title: "Clients",
                      text: serverInfoText,
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
              "Start server to capture mouse and keyboard events",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            trailing: Switch.adaptive(
              value: SynergyService.to.isServerRunning.value,
              onChanged: (_) {
                SynergyService.to.toggleServer(context);
              },
            ),
          ),
        ));
  }
}
