import 'dart:convert';

import 'package:flutter/services.dart';

const int _shiftModifier = 0x02;

/// Combined report for Keyboard, Mouse and Multimedia keys
List<int> combinedReport = [
  // Keyboard
  0x05, 0x01, // USAGE_PAGE (Generic Desktop)
  0x09, 0x06, // USAGE (Keyboard)
  0xa1, 0x01, // COLLECTION (Application)
  0x85, 0x01, //   REPORT_ID (1) - Assigning Report ID 1 to Keyboard
  0x05, 0x07, //   USAGE_PAGE (Keyboard)
  0x19, 0xe0, //   USAGE_MINIMUM (Keyboard LeftControl)
  0x29, 0xe7, //   USAGE_MAXIMUM (Keyboard Right GUI)
  0x15, 0x00, //   LOGICAL_MINIMUM (0)
  0x25, 0x01, //   LOGICAL_MAXIMUM (1)
  0x75, 0x01, //   REPORT_SIZE (1)
  0x95, 0x08, //   REPORT_COUNT (8)
  0x81, 0x02, //   INPUT (Data,Var,Abs)
  0x95, 0x01, //   REPORT_COUNT (1)
  0x75, 0x08, //   REPORT_SIZE (8)
  0x81, 0x03, //   INPUT (Cnst,Var,Abs)
  0x95, 0x05, //   REPORT_COUNT (5)
  0x75, 0x01, //   REPORT_SIZE (1)
  0x05, 0x08, //   USAGE_PAGE (LEDs)
  0x19, 0x01, //   USAGE_MINIMUM (Num Lock)
  0x29, 0x05, //   USAGE_MAXIMUM (Kana)
  0x91, 0x02, //   OUTPUT (Data,Var,Abs)
  0x95, 0x01, //   REPORT_COUNT (1)
  0x75, 0x03, //   REPORT_SIZE (3)
  0x91, 0x03, //   OUTPUT (Cnst,Var,Abs)
  0x95, 0x06, //   REPORT_COUNT (6)
  0x75, 0x08, //   REPORT_SIZE (8)
  0x15, 0x00, //   LOGICAL_MINIMUM (0)
  0x25, 0x65, //   LOGICAL_MAXIMUM (101)
  0x05, 0x07, //   USAGE_PAGE (Keyboard)
  0x19, 0x00, //   USAGE_MINIMUM (Reserved (no event indicated))
  0x29, 0x65, //   USAGE_MAXIMUM (Keyboard Application)
  0x81, 0x00, //   INPUT (Data,Ary,Abs)
  0xc0, // END_COLLECTION

  // Mouse
  0x05, 0x01, // USAGE_PAGE (Generic Desktop)
  0x09, 0x02, // USAGE (Mouse)
  0xA1, 0x01, // COLLECTION (Application)
  0x85, 0x02, //   REPORT_ID (2)
  0x09, 0x01, //   USAGE (Pointer)
  0xA1, 0x00, //   COLLECTION (Physical)
  0x05, 0x09, //     USAGE_PAGE (Button)
  0x19, 0x01, //     USAGE_MINIMUM (Button 1)
  0x29, 0x03, //     USAGE_MAXIMUM (Button 3)
  0x15, 0x00, //     LOGICAL_MINIMUM (0)
  0x25, 0x01, //     LOGICAL_MAXIMUM (1)
  0x95, 0x03, //     REPORT_COUNT (3)
  0x75, 0x01, //     REPORT_SIZE (1)
  0x81, 0x02, //     INPUT (Data,Var,Abs)
  0x95, 0x01, //     REPORT_COUNT (1)
  0x75, 0x05, //     REPORT_SIZE (5)
  0x81, 0x01, //     INPUT (Ary,Abs)
  0x05, 0x01, //     USAGE_PAGE (Generic Desktop)
  0x09, 0x30, //     USAGE (X)
  0x09, 0x31, //     USAGE (Y)
  0x09, 0x38, //     USAGE (Wheel)
  0x15, 0x81, //     LOGICAL_MINIMUM (-127)
  0x25, 0x7F, //     LOGICAL_MAXIMUM (127)
  0x75, 0x08, //     REPORT_SIZE (8)
  0x95, 0x03, //     REPORT_COUNT (3)
  0x81, 0x06, //     INPUT (Data,Var,Rel)
  0xC0, //   END_COLLECTION
  0xC0, // END_COLLECTION

  // Multimedia keys (Consumer Page)
  0x05, 0x0C, // USAGE_PAGE (Consumer Devices)
  0x09, 0x01, // USAGE (Consumer Control)
  0xA1, 0x01, // COLLECTION (Application)
  0x85, 0x03, // REPORT_ID (3)
  0x15, 0x00, // LOGICAL_MINIMUM (0)
  0x26, 0xFF, 0x03, // LOGICAL_MAXIMUM (1023)
  0x19, 0x00, // USAGE_MINIMUM (Unassigned)
  0x2A, 0xFF, 0x03, // USAGE_MAXIMUM (1023)
  0x75, 0x10, // REPORT_SIZE (16)
  0x95, 0x01, // REPORT_COUNT (1)
  0x81, 0x00, // INPUT (Data,Ary,Abs)
  0xC0 // END_COLLECTION
];

int? keyCodeToByte(final int keyCode) {
  switch (keyCode) {
    case 61267: // right
      return 79;
    case 61265: // left
      return 80;
    case 61268: // down
      return 81;
    case 61266: // up
      return 82;
    case 61192: // backsapce
      return 0x2a;
    case 61197: // enter
      return 0x28;
  }
  try {
    return textToByte(utf8.decode([keyCode]));
  } catch (e) {
    return null;
  }
}

int? mediaKeyToByte(int keyCode) {
  return switch (keyCode) {
    57519 => 0xE9, // Volume+
    57518 => 0xEA, // Volume-
    57523 => 0xCD, // Play/Pause
    _ => null,
  };
}

int maskToByte(int mask) {
  return switch (mask) {
    1 => _shiftModifier, // Left Shift
    2 => 0x20, // Left Control
    4 => 0x04, // Left Alt
    16 => 0x08, // Left GUI
    _ => 0,
  };
}

int? textToByte(String aChar) {
  switch (aChar) {
    case "A":
    case "a":
      return 0x04;
    case "B":
    case "b":
      return 0x05;
    case "C":
    case "c":
      return 0x06;
    case "D":
    case "d":
      return 0x07;
    case "E":
    case "e":
      return 0x08;
    case "F":
    case "f":
      return 0x09;
    case "G":
    case "g":
      return 0x0a;
    case "H":
    case "h":
      return 0x0b;
    case "I":
    case "i":
      return 0x0c;
    case "J":
    case "j":
      return 0x0d;
    case "K":
    case "k":
      return 0x0e;
    case "L":
    case "l":
      return 0x0f;
    case "M":
    case "m":
      return 0x10;
    case "N":
    case "n":
      return 0x11;
    case "O":
    case "o":
      return 0x12;
    case "P":
    case "p":
      return 0x13;
    case "Q":
    case "q":
      return 0x14;
    case "R":
    case "r":
      return 0x15;
    case "S":
    case "s":
      return 0x16;
    case "T":
    case "t":
      return 0x17;
    case "U":
    case "u":
      return 0x18;
    case "V":
    case "v":
      return 0x19;
    case "W":
    case "w":
      return 0x1a;
    case "X":
    case "x":
      return 0x1b;
    case "Y":
    case "y":
      return 0x1c;
    case "Z":
    case "z":
      return 0x1d;
    case "!":
    case "1":
      return 0x1e;
    case "@":
    case "2":
      return 0x1f;
    case "#":
    case "3":
      return 0x20;
    case "\$":
    case "4":
      return 0x21;
    case "%":
    case "5":
      return 0x22;
    case "^":
    case "6":
      return 0x23;
    case "&":
    case "7":
      return 0x24;
    case "*":
    case "8":
      return 0x25;
    case "(":
    case "9":
      return 0x26;
    case ")":
    case "0":
      return 0x27;
    case "\n": // LF
      return 0x28;
    case "\b": // BS
      return 0x2a;
    case "\t": // TAB
      return 0x2b;
    case " ":
      return 0x2c;
    case "_":
    case "-":
      return 0x2d;
    case "+":
    case "=":
      return 0x2e;
    case "{":
    case "[":
      return 0x2f;
    case "}":
    case "]":
      return 0x30;
    case "|":
    case "\\":
      return 0x31;
    case ":":
    case ";":
      return 0x33;
    case "\"":
    case "'":
      return 0x34;
    case "~":
    case "`":
      return 0x35;
    case "<":
    case ",":
      return 0x36;
    case ">":
    case ".":
      return 0x37;
    case "?":
    case "/":
      return 0x38;
    default:
      return 0;
  }
}

int textToMask(final String aChar) {
  switch (aChar) {
    case "A":
    case "B":
    case "C":
    case "D":
    case "E":
    case "F":
    case "G":
    case "H":
    case "I":
    case "J":
    case "K":
    case "L":
    case "M":
    case "N":
    case "O":
    case "P":
    case "Q":
    case "R":
    case "S":
    case "T":
    case "U":
    case "V":
    case "W":
    case "X":
    case "Y":
    case "Z":
    case "!":
    case "@":
    case "#":
    case "\$":
    case "%":
    case "^":
    case "&":
    case "*":
    case "(":
    case ")":
    case "_":
    case "+":
    case "{":
    case "}":
    case "|":
    case ":":
    case "\"":
    case "~":
    case "<":
    case ">":
    case "?":
      return _shiftModifier;
    default:
      return 0;
  }
}

/// Check if user pressed `Cntrl + V` to simulate paste command
bool isPasteCommand(int mask, int? keyCode) {
  if (keyCode == null) return false;
  return (mask == 16 || mask == 2) && keyCode == 25;
}

Future<String?> getClipBoardData() async {
  ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
  return data?.text;
}
