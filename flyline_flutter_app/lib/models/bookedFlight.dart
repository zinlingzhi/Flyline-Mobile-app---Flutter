import 'package:motel/utils/date_utils.dart';

class BookedFlight {
  final List<dynamic> airlines;
  final String localArrival;
  final String localDeparture;
  final String returnArrival;
  final String returnDeparture;
  final DateTime localArrivalFull;
  final DateTime localDepartureFull;
  final DateTime returnArrivalFull;
  final DateTime returnDepartureFull;
  final String cityFrom;
  final String cityTo;
  final String flyFrom;
  final String flyTo;
  final int price;
  final bool isRoundtrip;

  BookedFlight({
    this.airlines,
    this.localArrival,
    this.localDeparture,
    this.returnArrival,
    this.returnDeparture,
    this.localArrivalFull,
    this.localDepartureFull,
    this.returnArrivalFull,
    this.returnDepartureFull,
    this.cityFrom,
    this.cityTo,
    this.flyFrom,
    this.flyTo,
    this.isRoundtrip,
    this.price,
  });
  String getAirlines(Map<String, dynamic> airlineCodes) {
    List<String> lines = List<String>();
    this.airlines.forEach((v) {
      lines.add(airlineCodes[v]);
    });
    return lines.join(', ');
  }

  factory BookedFlight.fromJson(Map<String, dynamic> json) {
    print(json['data']);
    var parsedDepartureDate = DateUtils.monthDayFormat(
        DateTime.parse(json['data']["local_departure"]));
    var parsedArrivalDate =
        DateUtils.monthDayFormat(DateTime.parse(json['data']["local_arrival"]));

    var parsedReturnDepartureDate = json['data']["return_departure"] != null
        ? DateUtils.monthDayFormat(
            DateTime.parse(json['data']["return_departure"]))
        : null;
    var parsedReturnArrivalDate = json['data']["return_arrival"] != null
        ? DateUtils.monthDayFormat(
            DateTime.parse(json['data']["return_arrival"]))
        : null;

    return BookedFlight(
      airlines: json['data']['airlines'],
      cityFrom: json['data']['cityFrom'],
      cityTo: json['data']['cityTo'],
      flyFrom: json['data']['flyFrom'],
      flyTo: json['data']['flyTo'],
      isRoundtrip: json['data']['roundtrip'],
      price: json['data']['price'],
      localArrival: parsedArrivalDate,
      localDeparture: parsedDepartureDate,
      returnArrival: parsedReturnArrivalDate,
      returnDeparture: parsedReturnDepartureDate,
      localArrivalFull: DateTime.parse(json['data']["local_arrival"]),
      localDepartureFull: DateTime.parse(json['data']["local_departure"]),
      returnArrivalFull: json['data']["return_arrival"] != null
          ? DateTime.parse(json['data']["return_arrival"])
          : null,
      returnDepartureFull: json['data']["return_departure"] != null
          ? DateTime.parse(json['data']["return_departure"])
          : null,
    );
  }
}
