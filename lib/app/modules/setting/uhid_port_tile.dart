import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';

class UhidPortTile extends StatefulWidget {
  const UhidPortTile({super.key});

  @override
  State<UhidPortTile> createState() => _UhidPortTileState();
}

class _UhidPortTileState extends State<UhidPortTile> {
  final StorageService _storageService = StorageService.to;
  TextEditingController portController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  void initState() {
    portController.text = _storageService.uhidPort.toString();
    super.initState();
  }

  void savePort() {
    if (formKey.currentState?.validate() != true) return;
    int? port = int.tryParse(portController.text);
    if (port == null) return;
    _storageService.uhidPort = port;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SettingsTile(
        leading: const Icon(Icons.adb),
        title: const Text('Uhid Port'),
        trailing: SizedBox(
          width: 100,
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: portController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            onChanged: (value) {
              savePort();
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
            ],
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 4) {
                return "Invalid Port";
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'Port',
              counterText: "",
            ),
          ),
        ),
      ),
    );
  }
}
