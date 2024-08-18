import 'package:flutter/material.dart';
import 'package:uni_control_hub/app/synergy/synergy_key_types.dart';

class ChooseHotkey extends StatefulWidget {
  const ChooseHotkey({super.key});

  @override
  State<ChooseHotkey> createState() => _ChooseHotkeyState();
}

class _ChooseHotkeyState extends State<ChooseHotkey> {
  String? selectedKey;
  String? selectedModifier;

  String? get result {
    if (selectedModifier != null && selectedKey == null) {
      return '$selectedModifier+__';
    } else if (selectedKey != null && selectedModifier == null) {
      return selectedKey;
    } else if (selectedKey == null && selectedModifier == null) {
      return null;
    } else {
      return '$selectedModifier+$selectedKey';
    }
  }

  void returnResult() {
    String? finalResult;
    // only use result if Key is not empty
    if (selectedKey != null) {
      finalResult = result;
    }
    Navigator.pop(context, finalResult);
  }

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Hotkey'),
        leading: IconButton(
          onPressed: returnResult,
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text('Result: ${result ?? '__'}'),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Modifier (Optional) '),
              Text('Key (Required)'),
            ],
          ),
          const Divider(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: synergyKeyModifierList.length,
                    itemBuilder: (BuildContext context, int index) {
                      String key = synergyKeyModifierList[index];
                      return Card(
                        color: selectedModifier == key
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          title: Text(key),
                          onTap: () {
                            setState(() {
                              if (key == selectedModifier) {
                                selectedModifier = null;
                              } else {
                                selectedModifier = key;
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: synergyKeyList.length,
                    itemBuilder: (BuildContext context, int index) {
                      String key = synergyKeyList[index];
                      return Card(
                        color: selectedKey == key
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        child: ListTile(
                          title: Text(key),
                          onTap: () {
                            setState(() {
                              if (key == selectedKey) {
                                selectedKey = null;
                              } else {
                                selectedKey = key;
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedKey = null;
                        selectedModifier = null;
                      });
                      returnResult();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: returnResult,
                    child: const Text('Set'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
