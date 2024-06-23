import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_control_hub/app/models/synergy_client.dart';

import 'package:uni_control_hub/app/services/storage_service.dart';

class SynergyServerClientTile extends StatefulWidget {
  const SynergyServerClientTile({super.key});

  @override
  State<SynergyServerClientTile> createState() =>
      _SynergyServerClientTileState();
}

class _SynergyServerClientTileState extends State<SynergyServerClientTile> {
  bool serverTileExpanded = false;
  final serverAddressController = TextEditingController();
  final serverPotController = TextEditingController();
  final clientNameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  SynergyClient? synergyClient = StorageService.to.synergyClient;

  @override
  void initState() {
    super.initState();
    if (synergyClient != null) {
      serverAddressController.text = synergyClient!.serverAddress;
      serverPotController.text = synergyClient!.serverPort.toString();
      clientNameController.text = synergyClient!.clientName;
    } else {
      clientNameController.text = "UniControlHub";
      serverPotController.text = "24800";
    }
  }

  void onSaveTap() {
    if (_formKey.currentState!.validate()) {
      final synergyClient = SynergyClient(
        clientName: clientNameController.text,
        serverAddress: serverAddressController.text,
        serverPort: int.parse(serverPotController.text),
      );
      StorageService.to.synergyClient = synergyClient;
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Form(
          key: _formKey,
          child: ExpansionTile(
            title: const Text("Synergy Server"),
            subtitle: Text(
              "Connect to a Synergy Server",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            onExpansionChanged: (value) {
              setState(() {
                serverTileExpanded = value;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19.0),
                child: _KTextFiled(
                  hintText: "Client Name",
                  clientAliasController: clientNameController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _KTextFiled(
                        hintText: "Server Address",
                        clientAliasController: serverAddressController,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _KTextFiled(
                        hintText: "Port",
                        digitOnly: true,
                        clientAliasController: serverPotController,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSaveTap,
                    child: const Text("Save"),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _KTextFiled extends StatelessWidget {
  final TextEditingController clientAliasController;
  final String hintText;
  final bool digitOnly;
  const _KTextFiled({
    this.digitOnly = false,
    required this.hintText,
    required this.clientAliasController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      child: TextFormField(
        controller: clientAliasController,
        keyboardType: digitOnly ? TextInputType.number : null,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter value';
          }
          return null;
        },
        inputFormatters: digitOnly
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          label: Text(hintText),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}
