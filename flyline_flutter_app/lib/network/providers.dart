import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:motel/models/bookRequest.dart';
import 'package:motel/models/checkFlightResponse.dart';
import 'package:motel/models/recentlFlightSearch.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';
import '../models/bookedFlight.dart';
import '../models/flightInformation.dart';
import '../models/flylineDeal.dart';
import '../models/locations.dart';

class FlyLineProvider {
  final baseUrl = "https://joinflyline.com";

  Future<String> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? "";

    if (token.isNotEmpty) {
      return token;
    } else {
      var email = prefs.getString('email') ?? "";
      var password = prefs.getString('password') ?? "";

      if (email.isNotEmpty && password.isNotEmpty) {
        return await login(email, password);
      } else
        return "logout";
    }
  }

  Future<String> login(email, password) async {
    var url = "$baseUrl/api/auth/login/";
    var result = "";

    Response response;
    Dio dio = Dio();

    String credentials = email + ":" + password;
    print('logging in with ' + credentials);
    String encoded = base64Encode(utf8.encode(credentials));
    var auth = "Basic $encoded";

    dio.options.headers["Authorization"] = auth;

    try {
      response = await dio.post(url, data: json.encode({}));
    } on DioError catch (e) {
      result = e.toString();
      print(result);
      print(e.response.data);
    } on Error catch (e) {
      print(e);
    }

    if (response != null && response.statusCode == 200) {
      result = response.toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', response.data["token"]);

      prefs.setString('user_email', email);
      prefs.setString('user_password', password);
      this.accountInfo();
    } else {
      result = "";
    }
    return result;
  }

  Future<List<LocationObject>> locationQuery(term) async {
    Response response;
    Dio dio = Dio();

    List<LocationObject> locations = List<LocationObject>();

    term = term.toString().replaceAll(" ", "+");
    var url = "$baseUrl/api/locations/query/?term=$term&locale=en-US&location_types[]=city&location_types[]=airport";
    try {
      response = await dio.get(url);
    } catch (e) {
      log(e.toString());
    }

    if (response.statusCode == 200) {
      for (dynamic i in response.data["locations"]) {

        if (i['type'] != 'subdivision') {
          locations.add(LocationObject.fromJson(i));
        }
      }
    }
    return locations;
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
    var token = await getAuthToken();

    Response response;
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "Token $token";

    List<FlightInformationObject> flights = List<FlightInformationObject>();
//    var url =
//        "$baseUrl/api/search/?fly_from=$flyFrom&fly_to=$flyTo&date_from=$dateFrom&date_to=$dateTo&type=$type&return_from=$returnFrom&return_to=$returnTo&adults=$adults&infants=$infants&children=$children&selected_cabins=$selectedCabins&curr=USD&limit=$limit&offset=$offset";
    var url =
        "$baseUrl/api/search/?fly_from=$flyFrom&fly_to=$flyTo&date_from=$dateFrom&date_to=$dateTo&type=$type&return_from=$returnFrom&return_to=$returnTo&adults=$adults&infants=$infants&children=$children&selected_cabins=$selectedCabins&curr=USD&subdivision=NY";

//    url = 'https://joinflyline.com/api/search/?fly_from=city:NYC&fly_to=city:LAX&date_from=31%2F01%2F2020&date_to=31%2F01%2F2020&type=round&return_from=31%2F01%2F2020&return_to=31%2F01%2F2020&adults=1&infants=0&children=0&selected_cabins=M&curr=USD';
    print("Search url: " + url);
    try {
      response = await dio.get(url);
    } catch (e) {
      log(e.toString());
    }

    if (response.statusCode == 200) {
      for (dynamic i in response.data["data"]) {
        flights.add(FlightInformationObject.fromJson(i));
      }
    }
    return flights;
  }

  Future<CheckFlightResponse> checkFlights(
      bookingId, infants, children, adults) async {
    var token = await getAuthToken();

    Response response;
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "Token $token";

    CheckFlightResponse flightResponse;
    var url = "$baseUrl/api/booking/check_flights/";
    print("checkFlights: " + url);
    var queryParameters = {
      "v": "2",
      "currency": "USD",
      "booking_token": bookingId,
      "bnum": 0,
      "infants": infants,
      "children": children,
      "adults": adults,
    };
    try {
      response = await dio.get(url, queryParameters: queryParameters);
    } catch (e) {
      log(e.toString());
    }

    if (response.statusCode == 200) {
      flightResponse = CheckFlightResponse.fromJson(response.data);
    }
    return flightResponse;
  }

  Future<Map> book(BookRequest bookRequest) async {
    var token = await getAuthToken();

    Response response;
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "Token $token";
    var url = "$baseUrl/api/book/";
    var result = "";

    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(bookRequest.jsonSerialize);
    prettyprint.split('\n').forEach((element) => print(element));
    print(json.encode(bookRequest.jsonSerialize));
    try {
      response = await dio.post(url, data: json.encode(bookRequest.jsonSerialize));
      print(response.toString());
      print(response.statusCode.toString());
    } on DioError catch (e) {
      result = e.response.statusCode.toString();
      print(result);
      return { "status": e.response.statusCode };
    } on Error catch (e) {
      print(e);
    }

    return { "status": response.statusCode };
  }

  Future<List<FlylineDeal>> randomDeals(int size) async {
    print('randomDeals');
    var token = await getAuthToken();

    Response response;
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "Token $token";

    List<FlylineDeal> deals = List<FlylineDeal>();
    var url = "$baseUrl/api/deals/?size=" + size.toString();

    print(url);
    try {
      response = await dio.get(url);
      print(response);
    } on DioError catch (e) {
      print(e.response.toString());
      log(e.response.toString());
    } catch (e) {
      print(e.toString());
      log(e.toString());
    }

    if (response.statusCode == 200) {
      for (dynamic i in response.data["results"]) {
        deals.add(FlylineDeal.fromJson(i));
      }
      print(deals.length);
    }
    return deals;
  }

  Future<Account> accountInfo() async {
    var token = await getAuthToken();

    Response response;
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "Token $token";

    var url = "$baseUrl/api/users/me";
    try {
      response = await dio.get(url);
    } catch (e) {
      log(e.toString());
    }

    if (response.statusCode == 200) {
      Account account = Account.fromJson(response.data);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('first_name', account.firstName);
      prefs.setString('last_name', account.lastName);
      prefs.setString('email', account.email);
      prefs.setString('market.code', account.market.code);
      prefs.setString('market.country.code', account.market.country.code);
      prefs.setString('market.name', account.market.name);
      prefs.setString(
          'market.subdivision.name', account.market.subdivision.name);
      prefs.setString('market.type', account.market.type);
      prefs.setString('gender', account.gender);
      prefs.setString('phone_number', account.phoneNumber);
      prefs.setString('dob', account.dob);
      prefs.setString('tsa_precheck_number', account.tsaPrecheckNumber);
      prefs.setString('passport_number', account.passportNumber);

      return account;
    }

    return null;
  }

  Future<List<BookedFlight>> pastorUpcomingFlightSummary(
      bool isUpcoming) async {
    List<BookedFlight> flights = List<BookedFlight>();
    var pastFlightsURL = '$baseUrl/api/bookings/?kind=past';
    var upcomingFlightsURL = '$baseUrl/api/bookings/?kind=upcoming';

    var token = await getAuthToken();

    Response response;
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "Token $token";
    try {
      response =
          await dio.get(isUpcoming ? upcomingFlightsURL : pastFlightsURL);
    } catch (e) {
      log(e.toString());
    }
    if (response.statusCode == 200) {
      for (Map<String, dynamic> i in response.data) {
        flights.add(BookedFlight.fromJson(i));
      }
    }
    return flights;
  }

  Future<List<RecentFlightSearch>> flightSearchHistory() async {
    var searchHistoryURL = '$baseUrl/api/search-history/';

    List<RecentFlightSearch> flights = List<RecentFlightSearch>();
    var token = await getAuthToken();

    Response response;
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "Token $token";
    try {
      response = await dio.get(searchHistoryURL);
    } catch (e) {
      log(e.toString());
    }
    if (response.statusCode == 200) {
      for (dynamic i in response.data) {
        flights.add(RecentFlightSearch.fromJson(i));
      }
    }
    return flights;
  }

  Future<void> updateAccountInfo(String firstName, String lastName, String dob,
      String gender, String email, String phone, String passport) async {
    var token = await getAuthToken();

    Response response;
    Dio dio = Dio();
    dio.options.headers["Authorization"] = "Token $token";

    var url = "$baseUrl/api/users/me/";

    try {
      var data = {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone_number": phone,
        "passport_number": passport
      };

      if (gender.length > 0) {
        gender = (gender.toLowerCase() == 'male' ? 0 : 1).toString();
        data.addAll({
          "gender": gender
        });
      }

      if (dob.length > 0) {
        data.addAll({
          "dob": dob
        });
      }
      response = await dio.patch(url, data: data);
      print(response.toString());
    } on DioError catch (e) {
      print(e.response.toString());
      log(e.response.toString());
    }

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('first_name', firstName);
      prefs.setString('last_name', lastName);
      prefs.setString('email', email);
      prefs.setString('gender', gender);
      prefs.setString('phone_number', phone);
      prefs.setString('dob', dob);
      prefs.setString('passport_number', passport);
    }
  }
}
