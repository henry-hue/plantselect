class Plant {
  final int id;
  final String name;
  final String imageUrl;

  Plant({required this.id, required this.name, required this.imageUrl});

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}