class ScreenLink {
  String name;
  List<Connection> connections;
  ScreenLink(this.name, this.connections);

  Map<String, Map<String, dynamic>> toJson() {
    Map<String, dynamic> connectionsJson = {};
    for (var connection in connections) {
      connectionsJson[connection.direction.name] = connection.screen;
    }
    return {name: connectionsJson};
  }
}

enum Direction {
  left,
  right,
  up,
  down;

  Direction opposite() {
    switch (this) {
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
    }
  }
}

class Connection {
  Direction direction;
  String screen;
  Connection(this.direction, this.screen);
}
