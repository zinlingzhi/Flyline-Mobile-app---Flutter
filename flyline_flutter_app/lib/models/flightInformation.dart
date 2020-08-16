// A Pojo class for FlightInformation
import 'package:motel/utils/date_utils.dart';

class FlightInformationObject {
  String flyFrom;
  String flyTo;
  String cityFrom;
  String cityTo;
  int nightsInDest;
  List<FlightRouteObject> routes;
  DateTime localArrival;
  DateTime localDeparture;
  String durationDeparture;
  String durationReturn;
  String bookingToken;
  double price;
  List<dynamic> airlines;
  double distance;
  Map<String, dynamic> raw;

  FlightInformationObject(
      String flyFrom,
      String flyTo,
      String cityFrom,
      String cityTo,
      int nightsInDest,
      DateTime localArrival,
      DateTime localDeparture,
      List<FlightRouteObject> routes,
      String durationDeparture,
      String durationReturn,
      String bookingToken,
      List<dynamic> airlines,
      double price,
      double distance,
      Map<String, dynamic> raw) {
    this.flyFrom = flyFrom;
    this.flyTo = flyTo;
    this.cityFrom = cityFrom;
    this.cityTo = cityTo;
    this.routes = routes;
    this.localArrival = localArrival;
    this.localDeparture = localDeparture;
    this.nightsInDest = nightsInDest;
    this.durationDeparture = durationDeparture;
    this.durationReturn = durationReturn;
    this.bookingToken = bookingToken;
    this.price = price;
    this.airlines = airlines;
    this.distance = distance;
    this.raw = raw;
  }

  factory FlightInformationObject.fromJson(Map<String, dynamic> json) {
    var list = json['route'] as List;

    List<FlightRouteObject> items = List<FlightRouteObject>();

    items = list.map((i) => FlightRouteObject.fromJson(i)).toList();

    var durationDeparture = "";
    var durationReturn = "";

    var parsedDepartureDate = DateTime.parse(json["local_departure"]);
    var parsedArrivalDate = DateTime.parse(json["local_arrival"]);

    if (json["duration"] != null && json["duration"]["departure"] != null)
      durationDeparture = DateUtils.secs2hm(
          Duration(seconds: json["duration"]["departure"]).inSeconds);

    if (json["duration"] != null && json["duration"]["return"] != null)
      durationReturn = DateUtils.secs2hm(
          Duration(seconds: json["duration"]["return"]).inSeconds);

    return FlightInformationObject(
        json['flyFrom'],
        json["flyTo"],
        json['cityFrom'],
        json['cityTo'],
        json["nightsInDest"],
        parsedArrivalDate,
        parsedDepartureDate,
        items,
        durationDeparture,
        durationReturn,
        json['booking_token'],
        json['airlines'],
        double.parse(json['price'].toString()),
        double.parse(json['distance'].toString()),
        json);
  }

  @override
  String toString() {
    return 'FlightInformationObject{flyFrom: $flyFrom, flyTo: $flyTo, cityFrom: $cityFrom, cityTo: $cityTo, nightsInDest: $nightsInDest, routes: $routes, localArrival: $localArrival, localDeparture: $localDeparture, durationDeparture: $durationDeparture, durationReturn: $durationReturn}';
  }
}

// A Pojo class for Flight Route
class FlightRouteObject {
  String cityFrom;
  String cityTo;
  String flyFrom;
  String flyTo;
  int flightNo;
  String airline;
  DateTime localArrival;
  DateTime localDeparture;
  DateTime utcArrival;
  DateTime utcDeparture;
  int returnFlight;

  FlightRouteObject(
      String flyFrom,
      String flyTo,
      String cityFrom,
      String cityTo,
      int flightNo,
      DateTime localArrival,
      DateTime localDeparture,
      DateTime utcArrival,
      DateTime utcDeparture,
      String airline,
      int returnFlight) {
    this.cityFrom = cityFrom;
    this.cityTo = cityTo;
    this.flyFrom = flyFrom;
    this.flyTo = flyTo;
    this.localArrival = localArrival;
    this.localDeparture = localDeparture;
    this.utcArrival = utcArrival;
    this.utcDeparture = utcDeparture;
    this.flightNo = flightNo;
    this.airline = airline;
    this.returnFlight = returnFlight;
  }

  factory FlightRouteObject.fromJson(Map<String, dynamic> json) {
    var parsedDepartureDate = DateTime.parse(json["local_departure"]);
    var parsedArrivalDate = DateTime.parse(json["local_arrival"]);
    var parsedUTCDepartureDate = DateTime.parse(json["utc_departure"]);
    var parsedUTCArrivalDate = DateTime.parse(json["utc_arrival"]);

    return FlightRouteObject(
        json['flyFrom'],
        json["flyTo"],
        json['cityFrom'],
        json['cityTo'],
        json["flight_no"],
        parsedArrivalDate,
        parsedDepartureDate,
        parsedUTCArrivalDate,
        parsedUTCDepartureDate,
        json["airline"],
        json['return']);
  }

  get duration {
    return Duration(
        milliseconds: this.utcArrival.millisecondsSinceEpoch -
            this.utcDeparture.millisecondsSinceEpoch);
  }

  @override
  String toString() {
    return 'FlightRouteObject{cityFrom: $cityFrom, cityTo: $cityTo, flyFrom: $flyFrom, flyTo: $flyTo, flightNo: $flightNo, airline: $airline, localArrival: $localArrival, localDeparture: $localDeparture}';
  }
}
