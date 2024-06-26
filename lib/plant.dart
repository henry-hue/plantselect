class Plant {
  final List<dynamic> values;

  Plant({required this.values});

  factory Plant.fromJson(List<dynamic> json) {
    return Plant(
      values: json
    );
  }
}