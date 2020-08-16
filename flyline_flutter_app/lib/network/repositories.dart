import 'dart:async';

import 'package:motel/models/bookRequest.dart';
import 'package:motel/models/checkFlightResponse.dart';
import 'package:motel/models/recentlFlightSearch.dart';

import '../models/account.dart';
import '../models/bookedFlight.dart';
import '../models/flightInformation.dart';
import '../models/flylineDeal.dart';
import '../models/locations.dart';
import 'providers.dart';

class FlyLineRepository {
  FlyLineProvider _flyLineProvider = FlyLineProvider();

  Future<String> login(email, password) {
    return _flyLineProvider.login(email, password);
  }

  Future<List<LocationObject>> locationQuery(term) {
    return _flyLineProvider.locationQuery(term);
  }

  Future<List<FlightInformationObject>> searchFlights(
      flyFrom,
      flyTo,
      dateFrom,
      dateTo,
      type,
      returnFrom,
      returnTo,
      adults,
      infants,
      children,
      selectedCabins,
      curr,
      offset,
      limit) {
    return _flyLineProvider.searchFlight(
        flyFrom,
        flyTo,
        dateFrom,
        dateTo,
        type,
        returnFrom,
        returnTo,
        adults,
        infants,
        children,
        selectedCabins,
        curr,
        offset,
        limit);
  }

  Future<CheckFlightResponse> checkFlights(bookingId, infants, children, adults) {
    return _flyLineProvider.checkFlights(bookingId, infants, children, adults);
  }

  Future<Map> book(BookRequest bookRequest) {
    return _flyLineProvider.book(bookRequest);
  }

  Future<List<FlylineDeal>> randomDeals(int size) {
    return _flyLineProvider.randomDeals(size);
  }

  Future<List<BookedFlight>> pastOrUpcomingFlightSummary(
      bool isUpcoming) async {
    return await _flyLineProvider.pastorUpcomingFlightSummary(isUpcoming);
  }

  Future<List<RecentFlightSearch>> flightSearchHistory() async {
    return await _flyLineProvider.flightSearchHistory();
  }

  Future<Account> accountInfo() {
    return _flyLineProvider.accountInfo();
  }

  Future<void> updateAccountInfo(String firstName, String lastName, String dob,
      String gender, String email, String phone, String passport) {
    return _flyLineProvider.updateAccountInfo(
        firstName, lastName, dob, gender, email, phone, passport);
  }
}
