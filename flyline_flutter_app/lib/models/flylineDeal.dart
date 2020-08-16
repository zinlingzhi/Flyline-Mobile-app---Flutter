import 'package:intl/intl.dart';

class FlylineDeal {
  String cityFromName;
  String cityToName;
  String flyFrom;
  String flyTo;
  DateTime departureDate;
  DateTime returnDate;
  List<dynamic> airlines;
  String price;

  FlylineDeal(
      String cityFromName,
      String cityToName,
      String flyFrom,
      String flyTo,
      String departureDate,
      String returnDate,
      List<dynamic> airlines,
      String price) {
    this.cityFromName = cityFromName;
    this.cityToName = cityToName;
    this.flyFrom = flyFrom;
    this.flyTo = flyTo;
    this.departureDate = DateTime.parse(departureDate);
    this.returnDate = DateTime.parse(returnDate);
    this.airlines = airlines;
    this.price = price;
  }

  factory FlylineDeal.fromJson(Map<String, dynamic> json) {
    return FlylineDeal(
        json['city_from_name'],
        json['city_to_name'],
        json['fly_from'],
        json['fly_to'],
        json['departure_date'],
        json['return_date'],
        json['airlines'],
        json['price']);
  }

  String get cost => this.price;
  String getAirlines(Map<String, dynamic> airlineCodes) {
    List<String> lines = List<String>();
    this.airlines.forEach((v) {
      lines.add(airlineCodes[v]);
    });

    return lines.join(', ');
  }

  String get dealString {
    var formatter = new DateFormat('MM/dd');
    String departureTime = formatter.format(this.departureDate);
    String returnTime = formatter.format(this.returnDate);
    return this.cityFromName +
        " -> " +
        this.cityToName +
        ", RT | " +
        departureTime +
        " - " +
        returnTime;
//    return this.cityFromName +
//        "(" +
//        this.flyFrom +
//        ") -> " +
//        this.cityToName +
//        "(" +
//        this.flyTo +
//        ") | " +
//        departureTime +
//        " - " +
//        returnTime;
  }
}
