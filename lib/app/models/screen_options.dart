class ScreenOptions {
  bool relativeMouseMoves;
  bool? win32KeepForeground;
  bool? clipboardSharing;
  int? switchCornerSize;
  String? toggleKeyStroke;

  ScreenOptions({
    this.relativeMouseMoves = false,
    this.toggleKeyStroke,
    this.win32KeepForeground,
    this.clipboardSharing,
    this.switchCornerSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'relativeMouseMoves': relativeMouseMoves,
      if (win32KeepForeground != null)
        'win32KeepForeground': win32KeepForeground,
      if (clipboardSharing != null) 'clipboardSharing': clipboardSharing,
      if (switchCornerSize != null) 'switchCornerSize': switchCornerSize,
      if (toggleKeyStroke != null)
        'keystroke($toggleKeyStroke)': '; lockCursorToScreen(toggle)'
    };
  }
}
