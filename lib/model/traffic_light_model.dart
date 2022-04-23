class Traffic_lights {
  final int json_id;
  final int count;
  final List<int> traffic_light_ids;

  Traffic_lights({
    required this.json_id,
    required this.count,
    required this.traffic_light_ids
  });

  factory Traffic_lights.fromJson(Map<String, dynamic> parsedJson) {
    var traffic_light_ids_fromJson  = parsedJson['ids'];
    //print(streetsFromJson.runtimeType);
    // List<String> streetsList = new List<String>.from(streetsFromJson);
    List<int> traffic_light_id_list = traffic_light_ids_fromJson.cast<int>();

    return Traffic_lights(
      json_id: parsedJson['json_id'],
      count: parsedJson['count'],
      traffic_light_ids: traffic_light_id_list,
    );
  }

}