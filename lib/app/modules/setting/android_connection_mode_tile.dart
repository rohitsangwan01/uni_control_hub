import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/data/dialog_handler.dart';
import 'package:uni_control_hub/app/data/info_data.dart';
import 'package:uni_control_hub/app/models/android_connection_type.dart';
import 'package:uni_control_hub/app/services/app_service.dart';

class AndroidConnectionModeTile extends StatelessWidget {
  const AndroidConnectionModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final AppService appService = AppService.to;
    return Watch(
      (_) => SettingsTile(
        title: Row(
          children: [
            const Text('Android Connection Mode'),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                DialogHandler.showInfoDialog(
                  context: context,
                  title: 'Android Connection Mode',
                  text: androidConnectionModeInfo,
                );
              },
              child: const Icon(Icons.info_outline, size: 19),
            )
          ],
        ),
        leading: const Icon(Icons.android),
        trailing: DropdownButton<AndroidConnectionType>(
          value: appService.androidConnection.value,
          elevation: 0,
          underline: const SizedBox(),
          enableFeedback: false,
          focusColor: Colors.transparent,
          items: AndroidConnectionType.values
              .map((e) => DropdownMenuItem<AndroidConnectionType>(
                    value: e,
                    child: Text(
                      e.name.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ))
              .toList(),
          onChanged: (AndroidConnectionType? connection) {
            if (connection == null) return;
            appService.androidConnection.value = connection;
          },
        ),
      ),
    );
  }
}
