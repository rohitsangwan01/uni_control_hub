import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/data/dialog_handler.dart';
import 'package:uni_control_hub/app/data/info_data.dart';
import 'package:uni_control_hub/app/data/logger.dart';
import 'package:uni_control_hub/app/modules/setting/choose_hotkey.dart';
import 'package:uni_control_hub/app/services/synergy_service.dart';

class LockMouseTile extends StatelessWidget {
  const LockMouseTile({super.key});

  void selectHotkey(BuildContext context, SynergyService synergyService) async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChooseHotkey(),
      ),
    );
    logInfo('Result $result');
    synergyService.toggleKeyStroke.value = result;
    DialogHandler.showSuccess(
      "Changes will take effect after you restart the server",
    );
  }

  @override
  Widget build(BuildContext context) {
    final synergyService = SynergyService.to;

    return Watch(
      (_) => SettingsTile(
        title: Row(
          children: [
            const Text('Lock Mouse Hotkey'),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                DialogHandler.showInfoDialog(
                  context: context,
                  title: 'Lock Mouse to Device',
                  text: lockMouseTileInfo,
                );
              },
              child: const Icon(Icons.info_outline, size: 19),
            )
          ],
        ),
        trailing: Text(
          synergyService.toggleKeyStroke.value ?? "Select Hotkey",
        ),
        onPressed: (context) => selectHotkey(context, synergyService),
        leading: const Icon(Icons.ads_click),
      ),
    );
  }
}
