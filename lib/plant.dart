class Plant {
  int plantId;
  String botanicName;
  String commonName;
  //String sun;
  int native;
  // String soil;
  // String water;
  // String type;
  // String flowering;
  // String maintenance;

  Plant({
    required this.plantId,
    required this.botanicName,
    required this.commonName,
    required this.native,
    //required this.sun,
    // required this.soil,
    // required this.water,
    // required this.type,
    // required this.flowering,
    // required this.maintenance,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantId: json['plant_id'],
      botanicName: json['botanic_name'],
      commonName: json['common_name'],
      native: json['na_native'],
      //sun: json['sun'],
      // soil: json['soil'],
      // water: json['wet'],
      // type: json['plant_type'],
      // flowering: json['flower_season'],
      // maintenance: json['commercial_maintenance'],
    );
  }
}
