class ScreenAlias {
  String name;
  List<String> screens;
  ScreenAlias(this.name, this.screens);

  Map<String, dynamic> toJson() {
    return {
      name: screens,
    };
  }
}
