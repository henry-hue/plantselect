class Plant {
  int plantId;
  String botanicName;
  String commonName;
  int native;

  Plant({
    required this.plantId,
    required this.botanicName,
    required this.commonName,
    required this.native,
  });


  factory Plant.fromJson(Map<String,dynamic> json) {
    return Plant(
      plantId: json['plant_id'],
      botanicName: json['botanic_name'],
      commonName: json['common_name'],
      native: json['na_native'],
    );
  }
}
