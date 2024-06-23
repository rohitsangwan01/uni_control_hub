import 'dart:io';

class Capabilities {
  static bool supportsBleConnection = Platform.isMacOS || Platform.isWindows;
}
