import 'package:motel/models/bookRequest.dart';
import 'package:motel/models/recentlFlightSearch.dart';
import 'package:rxdart/rxdart.dart';

import '../models/account.dart';
import '../models/checkFlightResponse.dart';
import '../models/bookedFlight.dart';
import '../models/flightInformation.dart';
import '../models/flylineDeal.dart';
import '../models/locations.dart';
import 'repositories.dart';

class FlyLineBloc {
  final FlyLineRepository _repository = FlyLineRepository();

  final BehaviorSubject<String> _token = BehaviorSubject<String>();

  final BehaviorSubject<List<LocationObject>> _subjectlocationItems =
      BehaviorSubject<List<LocationObject>>();

  final BehaviorSubject<List<FlightInformationObject>> _subjectFlightItems =
      BehaviorSubject<List<FlightInformationObject>>();

  final BehaviorSubject<List<BookedFlight>> _subjectUpcomingFlights =
      BehaviorSubject<List<BookedFlight>>();
  final BehaviorSubject<List<BookedFlight>> _subjectPastFlights =
      BehaviorSubject<List<BookedFlight>>();

  final BehaviorSubject<List<RecentFlightSearch>> _subjectRecentFlightSearch =
      BehaviorSubject<List<RecentFlightSearch>>();

  final BehaviorSubject<List<FlylineDeal>> _subjectRandomDeals =
      BehaviorSubject<List<FlylineDeal>>();

  final BehaviorSubject<Account> _subjectAccountInfo =
      BehaviorSubject<Account>();

  final BehaviorSubject<CheckFlightResponse> _subjectCheckFlight =
      BehaviorSubject<CheckFlightResponse>();

  final BehaviorSubject<Map> _subjectBookFlight = BehaviorSubject<Map>();

  tryLogin(String email, String password) async {
    String response = await _repository.login(email, password);
    _token.sink.add(response);
  }

  Future<List<LocationObject>> locationQuery(String term) async {
    List<LocationObject> response = await _repository.locationQuery(term);
    _subjectlocationItems.sink.add(response);
    return response;
  }

  Future<List<FlightInformationObject>> searchFlight(
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
      limit) async {
    // return null for activate loading indicator on search page
    // before real results will be loaded
    _subjectFlightItems.sink.add(null);

    List<FlightInformationObject> response = await _repository.searchFlights(
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

    _subjectFlightItems.sink.add(response);

    return response;
  }

  Future<CheckFlightResponse> checkFlights(
      bookingId, infants, children, adults) async {
    CheckFlightResponse response =
        await _repository.checkFlights(bookingId, infants, children, adults);

    _subjectCheckFlight.sink.add(response);

    return response;
  }

  Future<Map> book(BookRequest bookRequest) async {
    Map response = await _repository.book(bookRequest);
    _subjectBookFlight.sink.add(response);
    return response;
  }

  Future<List<FlylineDeal>> randomDeals() async {
    List<FlylineDeal> response = await _repository.randomDeals(20);
    _subjectRandomDeals.sink.add(response);

    return response;
  }

  Future<List<BookedFlight>> pastOrUpcomingFlightSummary(
      bool isUpcoming) async {
    List<BookedFlight> response =
        await _repository.pastOrUpcomingFlightSummary(isUpcoming);
    isUpcoming
        ? _subjectUpcomingFlights.add(response)
        : _subjectPastFlights.add(response);
    return response;
  }

  Future<List<RecentFlightSearch>> flightSearchHistory() async {
    List<RecentFlightSearch> response = await _repository.flightSearchHistory();
    _subjectRecentFlightSearch.add(response);
    return response;
  }

  Future<Account> accountInfo() async {
    Account account = await _repository.accountInfo();
    _subjectAccountInfo.sink.add(account);
    return account;
  }

  Future<void> updateAccountInfo(String firstName, String lastName, String dob,
      String gender, String email, String phone, String passport) async {
    _repository.updateAccountInfo(
        firstName, lastName, dob, gender, email, phone, passport);
  }

  dispose() {
    _token.close();
    _subjectlocationItems.close();
    _subjectFlightItems.close();
    _subjectRandomDeals.close();
    _subjectAccountInfo.close();
    _subjectCheckFlight.close();
    _subjectRecentFlightSearch.close();
    _subjectPastFlights.close();
    _subjectUpcomingFlights.close();
    _subjectBookFlight.close();
  }

  BehaviorSubject<String> get loginResponse => _token;

  BehaviorSubject<List<LocationObject>> get locationItems =>
      _subjectlocationItems;

  BehaviorSubject<List<FlightInformationObject>> get flightsItems =>
      _subjectFlightItems;

  BehaviorSubject<List<FlylineDeal>> get randomDealItems => _subjectRandomDeals;

  BehaviorSubject<Account> get accountInfoItem => _subjectAccountInfo;

  BehaviorSubject<CheckFlightResponse> get checkFlightData =>
      _subjectCheckFlight;

  BehaviorSubject<List<RecentFlightSearch>> get recentFlightSearches =>
      _subjectRecentFlightSearch;

  BehaviorSubject<List<BookedFlight>> get pastFlights => _subjectPastFlights;

  BehaviorSubject<List<BookedFlight>> get upcomingFlights =>
      _subjectUpcomingFlights;

  BehaviorSubject<Map> get bookFlight => _subjectBookFlight;
}

final flyLinebloc = FlyLineBloc();
