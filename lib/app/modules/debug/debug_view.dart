import 'package:flutter/material.dart';

import 'package:uni_control_hub/app/data/logger.dart';

class DebugView extends StatefulWidget {
  const DebugView({super.key});

  @override
  State<DebugView> createState() => _DebugViewState();
}

class _DebugViewState extends State<DebugView> {
  List<String> logs = appLogs;

  @override
  void initState() {
    logListener = (String log) {
      setState(() {
        logs.add(log);
      });
    };
    super.initState();
  }

  @override
  void dispose() {
    logListener = null;
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              clearLogs();
              setState(() {
                logs = [];
              });
            },
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Card(
            child: logs.isEmpty
                ? const Center(child: Text("No Logs"))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Text(logs[index]);
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}