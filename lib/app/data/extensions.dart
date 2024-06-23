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
