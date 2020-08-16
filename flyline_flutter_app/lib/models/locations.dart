// A Pojo class for LocationObject
class LocationObject {
  String code;
  String countryCode;
  String type;
  String name;
  String subdivisionName;
  Map raw;

  LocationObject(String code, String countryCode, String type, String name,
      String subdivisionName, Map raw) {
    this.code = code;
    this.type = type;
    this.countryCode = countryCode;
    this.name = name;
    this.subdivisionName = subdivisionName;
    this.raw = raw;
  }

  factory LocationObject.fromJson(Map<String, dynamic> json) {
    var subdivision = "";
    var country = "";
    if (json['type'] == "city" && json['subdivision'] != null) {
      subdivision = json['subdivision']['name'];
    }
    if (json['country'] != null) {
      country = json['country']['code'];
    }

    return LocationObject(
        json['code'], country, json['type'], json['name'], subdivision, json);
  }
}
