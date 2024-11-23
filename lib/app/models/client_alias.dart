import 'dart:convert';

import 'package:signals_flutter/signals_flutter.dart';
import 'package:uni_control_hub/app/models/screen_link.dart';

class ClientAlias {
  String name;
  Signal<Direction> direction = Signal(Direction.left, autoDispose: true);

  ClientAlias({required this.name, Direction direction = Direction.left}) {
    this.direction.value = direction;
  }

  factory ClientAlias.left() {
    return ClientAlias(name: "Left", direction: Direction.left);
  }

  factory ClientAlias.right() {
    return ClientAlias(name: "Right", direction: Direction.right);
  }

  factory ClientAlias.up() {
    return ClientAlias(name: "Top", direction: Direction.up);
  }

  factory ClientAlias.down() {
    return ClientAlias(name: "Bottom", direction: Direction.down);
  }

  factory ClientAlias.fromJson(Map<String, dynamic> json) {
    return ClientAlias(
      name: json['name'],
      direction: Direction.values[json['direction']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'direction': direction.value.index,
    };
  }

  String toJsonString() => json.encode(toJson());

  factory ClientAlias.fromJsonString(String jsonString) {
    return ClientAlias.fromJson(json.decode(jsonString));
  }
}
