import 'package:flutter/services.dart';
import 'package:synergy_client_dart/synergy_client_dart.dart';

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension StringExtension on String {
  String get capitalizeFirst {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension ShapeExtension on RectObj {
  Size toSize() => Size(width, height);
}
