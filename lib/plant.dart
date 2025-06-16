class Plant {
  int plantId;
  String botanicName;
  String commonName;
  String naNative;
  String sun;
  String? plantType;
  String water;
  String flowering;
  String maintenance;

  Plant({
    required this.plantId,
    required this.botanicName,
    required this.commonName,
    required this.naNative,
    required this.plantType,
    required this.sun,
    required this.water,
    required this.flowering,
    required this.maintenance,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantId: json['plant_id'],
      botanicName: json['botanic_name'],
      commonName: json['common_name'],
      naNative: json['na_native'].toString(),
      sun: json['sun'].toString(),
      water: json['wet'].toString(),
      plantType: json['type'],
      flowering: json['blooms'].toString(),
      maintenance: json['maintenance_schedule'],
    );
  }
}
