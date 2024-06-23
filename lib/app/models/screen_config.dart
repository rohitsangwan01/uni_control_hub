class ScreenConfig {
  String name;
  bool halfDuplexCapsLock;
  bool halfDuplexNumLock;
  bool halfDuplexScrollLock;
  bool xtestIsXineramaUnaware;
  bool preserveFocus;
  int switchCornerSize;

  ScreenConfig(
    this.name, {
    this.halfDuplexCapsLock = false,
    this.halfDuplexNumLock = false,
    this.halfDuplexScrollLock = false,
    this.xtestIsXineramaUnaware = false,
    this.preserveFocus = false,
    this.switchCornerSize = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      name: {
        'halfDuplexCapsLock': halfDuplexCapsLock,
        'halfDuplexNumLock': halfDuplexNumLock,
        'halfDuplexScrollLock': halfDuplexScrollLock,
        'xtestIsXineramaUnaware': xtestIsXineramaUnaware,
        'preserveFocus': preserveFocus,
        'switchCornerSize': switchCornerSize,
      }
    };
  }
}
