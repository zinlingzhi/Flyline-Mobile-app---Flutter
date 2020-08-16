import 'package:motel/models/flightInformation.dart';
import 'package:motel/models/popularFilterList.dart';

class FilterExplore {
  double priceFrom;
  double priceTo;
  double priceMax;
  double priceMin;
  int stopoverTo;
  List<Map<String, dynamic>> airlines;
  Map<String, dynamic> airlineCodes;

  List<PopularFilterListData> accomodationListData;

  FilterExplore(List<FlightInformationObject> originalFlights,
      Map<String, dynamic> airlineCodes) {
    this.airlineCodes = airlineCodes;
    this.priceFrom = originalFlights
        .reduce((current, next) => current.price < next.price ? current : next)
        .price;

    this.priceTo = originalFlights
        .reduce((current, next) => current.price > next.price ? current : next)
        .price;

    this.priceMin = originalFlights
        .reduce((current, next) => current.price < next.price ? current : next)
        .price;
    this.priceMax = originalFlights
        .reduce((current, next) => current.price > next.price ? current : next)
        .price;

    var t = List();
    originalFlights.forEach((f) => t..addAll(f.airlines));

    airlines = List();
    t.toSet().toList().forEach((code) {
      airlines.add({
        "title": airlineCodes[code],
        "code": code,
        "isSelected": true,
      });
    });

    accomodationListData = PopularFilterListData.accomodationList;
  }
}
