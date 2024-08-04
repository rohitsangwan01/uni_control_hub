import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_control_hub/app/client/client.dart';
import 'package:uni_control_hub/app/data/extensions.dart';
import 'package:uni_control_hub/app/services/storage_service.dart';

class ClientMouseWidget extends StatefulWidget {
  final Client client;
  const ClientMouseWidget({super.key, required this.client});

  @override
  State<ClientMouseWidget> createState() => _ClientMouseWidgetState();
}

class _ClientMouseWidgetState extends State<ClientMouseWidget> {
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  late Size _clientShape = widget.client.screen.getShape().toSize();
  Size get _appShape => MediaQuery.sizeOf(context);
  double get _scaleX => min(500, _appShape.width) / _clientShape.width;
  double get _scaleY => min(600, _appShape.height) / _clientShape.height;
  double get _scale => (_scaleX < _scaleY ? _scaleX : _scaleY) - 0.005;
  Size get _scaledClientShape => Size(
        _clientShape.width * _scale,
        _clientShape.height * _scale,
      );
  (int x, int y) mouseMovement = (0, 0);

  @override
  void initState() {
    _widthController.text = _clientShape.width.toString();
    _heightController.text = _clientShape.height.toString();
    widget.client.screen.onMouseMove = (x, y) {
      setState(() {
        mouseMovement = (x, y);
      });
    };
    super.initState();
  }

  void _updateClientSize() {
    if (!_formKey.currentState!.validate()) return;
    final width = double.tryParse(_widthController.text);
    final height = double.tryParse(_heightController.text);
    Size size = Size(
      width ?? _clientShape.width,
      height ?? _clientShape.height,
    );
    StorageService.to.clientDefaultSize = size;
    _clientShape = size;
    widget.client.reConnectClient();
    // Restart server
    setState(() {});
  }

  @override
  void dispose() {
    widget.client.screen.onMouseMove = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scaledMouseX = mouseMovement.$1.toDouble() * _scale;
    double scaledMouseY = mouseMovement.$2.toDouble() * _scale;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.id),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text("Client's screen size from server's POV"),
                const SizedBox(height: 6),
                Column(
                  children: [
                    SizedBox(
                      width: _scaledClientShape.width,
                      height: _scaledClientShape.height,
                      child: Stack(
                        children: [
                          Container(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            width: _scaledClientShape.width,
                            height: _scaledClientShape.height,
                          ),
                          Positioned(
                            left: scaledMouseX,
                            top: scaledMouseY,
                            child: Icon(
                              Icons.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Client Absolute Movements: x: ${mouseMovement.$1}, y: ${mouseMovement.$2}",
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _widthController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Width is required";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Width",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]'))
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Height is required";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: "Height",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  child: ElevatedButton(
                    onPressed: _updateClientSize,
                    child: const Text("Update Client Size"),
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Mouse moves with relative position on client, whereas server produces absolute mouse movements, "
                        "Hence we expect client to be of specific size, so that we can move mouse in that size freely",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
