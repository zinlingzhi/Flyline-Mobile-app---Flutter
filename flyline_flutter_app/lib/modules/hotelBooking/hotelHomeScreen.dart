import 'dart:convert';
import 'dart:ui';

import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:motel/helper/helper.dart';
import 'package:motel/models/filterExplore.dart';
import 'package:simple_autocomplete_formfield/simple_autocomplete_formfield.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../appTheme.dart';
import '../../models/flightInformation.dart';
import '../../models/hotelListData.dart';
import '../../models/locations.dart';
import '../../network/blocs.dart';
import 'calendarPopupView.dart';
import 'filtersScreen.dart';
import 'hotelListView.dart';
import 'roomPopupView.dart';
import 'package:motel/modules/hotelBooking/newScreen_1.dart' as newScreen1;

class HotelHomeScreen extends StatefulWidget {
  final String departure;
  final String arrival;
  final String departureCode;
  final String arrivalCode;
  final DateTime startDate;
  final DateTime endDate;

  HotelHomeScreen(
      {Key key,
      this.arrival,
      this.departure,
      this.arrivalCode,
      this.departureCode,
      this.startDate,
      this.endDate})
      : super(key: key);

  @override
  _HotelHomeScreenState createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen>
    with TickerProviderStateMixin {
  bool _isSearched = false;
  bool _clickedSearch = false;
  AnimationController animationController;
  AnimationController _animationController;
  var hotelList = HotelListData.hotelList;
  ScrollController scrollController = new ScrollController();
  int room = 1;
  int ad = 1;
  int children = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 5));
  bool isMap = false;

  final formatDates = intl.DateFormat("dd MMM");
  final formatTime = intl.DateFormat("hh : mm a");
  final formatAllDay = intl.DateFormat("dd/MM/yyyy");

  var typeOfTripSelected = 0;
  LocationObject selectedDeparture;
  LocationObject selectedArrival;

  LocationObject departure;
  LocationObject arrival;
  var departureDate = DateTime.now();
  var returnDate = DateTime.now().add(Duration(days: 2));
  static var classOfServicesList = [
    "Economy",
    "Premium Economy",
    "Business",
    "First Class"
  ];
  static var classOfServicesValueList = ["M", "W", "C", "F"];

  var selectedClassOfService = classOfServicesList[0];
  var selectedClassOfServiceValue = classOfServicesValueList[0];

  final searchBarHieght = 158.0;
  final filterBarHieght = 52.0;

  int offset = 0;
  int perPage = 5;
  List<FlightInformationObject> originalFlights = List();
  List<FlightInformationObject> listOfFlights = List();
  List<bool> _clickFlight = List();
  bool _loadMore = false;
  bool _isLoading = false;
  bool _displayLoadMore = true;

  Map<String, dynamic> airlineCodes;

  FilterExplore filterExplore;

  GlobalKey stickyKey = GlobalKey();
  double heightBox = -1;

  @override
  void initState() {
    animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    _animationController =
        AnimationController(duration: Duration(milliseconds: 0), vsync: this);
    scrollController.addListener(() {
      if (context != null) {
        if (scrollController.offset <= 0) {
          _animationController.animateTo(0.0);
        } else if (scrollController.offset > 0.0 &&
            scrollController.offset < searchBarHieght) {
          // we need around searchBarHieght scrolling values in 0.0 to 1.0
          _animationController
              .animateTo((scrollController.offset / searchBarHieght));
        } else {
          _animationController.animateTo(1.0);
        }
      }
    });

    this.getCity();
    this.getAirlineCodes();
    super.initState();

    flyLinebloc.flightsItems.stream
        .listen((List<FlightInformationObject> onData) {
      if (onData != null) {
        if (_clickedSearch || _loadMore) {
          print('trigger');
          setState(() {
            this._loadMore = false;
            this._clickedSearch = false;
            this._isSearched = true;
            if (listOfFlights.length != 0) {
              if (listOfFlights[listOfFlights.length - 1] == null) {
                listOfFlights.removeLast();
              }
            }
            this._isLoading = false;
            originalFlights.addAll(onData);
            _displayLoadMore = true;
            if ((offset + perPage) > originalFlights.length) {
              print("offset:" + offset.toString());
              print("length:" + originalFlights.length.toString());
              listOfFlights.addAll(
                  originalFlights.getRange(offset, originalFlights.length));
              _displayLoadMore = false;
            } else {
              listOfFlights
                  .addAll(originalFlights.getRange(offset, offset + perPage));
            }
            _clickFlight = List(listOfFlights.length);
            print(listOfFlights.length);
            offset = offset + perPage;
          });
        }
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) => this.getKey());
  }

  void getKey() {
    var keyContext = stickyKey.currentContext;
    if (keyContext != null) {
      // widget is visible
      final box = keyContext.findRenderObject() as RenderBox;

      setState(() {
        heightBox = box.size.height;
      });
      print("height" + box.size.height.toString());
    }
  }

  void getAirlineCodes() async {
    airlineCodes = json.decode(await DefaultAssetBundle.of(context)
        .loadString("jsonFile/airline_codes.json"));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void getCity() async {
    startDate = widget.startDate ?? DateTime.now();
    endDate = widget.endDate ?? DateTime.now().add(Duration(days: 2));

    if (widget.departure != null) {
      selectedDeparture = departure = LocationObject(widget.departureCode,
          widget.departureCode, "city", widget.departure, "", null);
    }

    if (widget.arrival != null) {
      selectedArrival = arrival = LocationObject(widget.arrivalCode,
          widget.arrivalCode, "city", widget.arrival, "", null);
    }
  }

  Future<bool> getData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  searchForLocation(query, isDeparture) async {
    flyLinebloc.locationItems.add(List<LocationObject>());
    flyLinebloc.locationQuery(query);
    //flyLinebloc.locationItems.stream.listen((data) => onUpdateResult(data, isDeparture));
  }

  @override
  void dispose() {
    animationController.dispose();
    this._isSearched = false;
    this._clickedSearch = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: <Widget>[
                getAppBarUI(),
                isMap
                    ? Expanded(
                        child: Column(
                          children: <Widget>[
                            getSearchBarUI(),
                            getTimeDateUI(),
                            getSearchButton(),
                            Expanded(
                              child: Stack(
                                children: <Widget>[
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Image.asset(
                                          "assets/images/mapImage.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.getTheme()
                                                  .scaffoldBackgroundColor
                                                  .withOpacity(1.0),
                                              AppTheme.getTheme()
                                                  .scaffoldBackgroundColor
                                                  .withOpacity(0.0),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ] +
                                    [
                                      getFlightDetails(),
                                    ],
                              ),
                            )
                          ],
                        ),
                      )
                    : Expanded(
                        child: Column(children: <Widget>[
                          AnimatedOpacity(
                              // If the widget is visible, animate to 0.0 (invisible).
                              // If the widget is hidden, animate to 1.0 (fully visible).
                              opacity: !this._isSearched ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 1000),
                              // The green box must be a child of the AnimatedOpacity widget.
                              child: (this._isSearched
                                  ? Container()
                                  : Container(
                                      color: AppTheme.getTheme()
                                          .scaffoldBackgroundColor,
                                      child: Column(
                                        children: <Widget>[
                                          getSearchBarUI(),
                                          getTimeDateUI(),
                                          getSearchButton(),
                                        ],
                                      )))),
                          getFilterBarUI(),
                          getFlightDetails(),
                        ]),
                      )
              ],
            ),
          ),
        ],
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  List<Widget> loadItems(List<FlightRouteObject> routes, String type,
      FlightInformationObject flight) {
    List<Widget> lists = List();
    lists.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 16.0, top: 20, bottom: 10),
          child: Text(
            Helper.getDateViaDate(routes[0].localDeparture, "dd MMM") +
                " | " +
                type +
                " | " +
                routes[0].cityFrom +
                ' - ' +
                routes[routes.length - 1].cityTo +
                " | " +
                (type == "Departure"
                    ? flight.durationDeparture
                    : flight.durationReturn),
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ));
    for (var i = 0; i < routes.length; i++) {
      FlightRouteObject route = routes[i];
      lists.add(Container(
        padding: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: const Color(0xF6F6F6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 74,
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 10, left: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.getTheme().backgroundColor,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppTheme.getTheme().dividerColor,
                              offset: Offset(4, 4),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(left: 10, top: 14),
                                    margin: EdgeInsets.only(bottom: 3),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      Helper.getDateViaDate(
                                              route.localDeparture, "hh:mm a") +
                                          " - " +
                                          Helper.getDateViaDate(
                                              route.localArrival, "hh:mm a"),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 12.8,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 10, top: 5),
                                    margin: EdgeInsets.only(bottom: 14),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      route.cityFrom +
                                          " (" +
                                          route.flyFrom +
                                          ") - " +
                                          route.cityTo +
                                          " (" +
                                          route.flyTo +
                                          ")  Duration: " +
                                          Helper.duration(route.duration),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                right: 10,
                              ),
                              color: Colors.blueAccent,
                              child: Image.network(
                                "https://storage.googleapis.com/joinflyline/images/airlines/${route.airline}.png",
                                height: 20,
                                width: 20,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            (i != routes.length - 1
                ? Container(
                    padding: EdgeInsets.only(left: 26.0, top: 15, bottom: 0),
                    child: Text(
                        Helper.duration(Duration(
                                milliseconds: routes[i + 1]
                                        .localDeparture
                                        .millisecondsSinceEpoch -
                                    route
                                        .localArrival.millisecondsSinceEpoch)) +
                            ' layover',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 12.5)))
                : Container()),
          ],
        ),
      ));
    }
    return lists;
  }

  Widget getFlightDetailItems(List<FlightRouteObject> departures,
      List<FlightRouteObject> returns, FlightInformationObject flight) {
    List<Widget> lists = List();
    lists.addAll(loadItems(departures, 'Departure', flight));
    lists.addAll(loadItems(returns.reversed.toList(), 'Return', flight));
    return Container(
        margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0, bottom: 0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.getTheme().dividerColor,
            ),
          ),
        ),
        child: Column(
          children: lists,
        ));
  }

  List<Widget> getMapPinUI() {
    List<Widget> list = List<Widget>();

    for (var i = 0; i < hotelList.length; i++) {
      double top;
      double left;
      double right;
      double bottom;
      if (i == 0) {
        top = 150;
        left = 50;
      } else if (i == 1) {
        top = 50;
        right = 50;
      } else if (i == 2) {
        top = 40;
        left = 10;
      } else if (i == 3) {
        bottom = 260;
        right = 140;
      } else if (i == 4) {
        bottom = 160;
        right = 20;
      }
      list.add(
        Positioned(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          child: Container(
            decoration: BoxDecoration(
              color: hotelList[i].isSelected
                  ? AppTheme.getTheme().primaryColor
                  : AppTheme.getTheme().backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppTheme.getTheme().dividerColor,
                  blurRadius: 16,
                  offset: Offset(4, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                onTap: () {
                  if (hotelList[i].isSelected == false) {
                    setState(() {
                      hotelList.forEach((f) {
                        f.isSelected = false;
                      });
                      hotelList[i].isSelected = true;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 8),
                  child: Text(
                    "\$${hotelList[i].perNight}",
                    style: TextStyle(
                        color: hotelList[i].isSelected
                            ? AppTheme.getTheme().backgroundColor
                            : AppTheme.getTheme().primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return list;
  }

  Widget getListUI() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: AppTheme.getTheme().dividerColor,
              offset: Offset(0, -2),
              blurRadius: 8.0),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height - 156 - 50,
            child: FutureBuilder(
              future: getData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                } else {
                  return getFlightDetails();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget getHotelViewList() {
    List<Widget> hotelListViews = List<Widget>();
    for (var i = 0; i < hotelList.length; i++) {
      var count = hotelList.length;
      var animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval((1 / count) * i, 1.0, curve: Curves.fastOutSlowIn),
        ),
      );
      hotelListViews.add(
        HotelListView(
          callback: () {},
          hotelData: hotelList[i],
          animation: animation,
          animationController: animationController,
        ),
      );
    }
    animationController.forward();
    return Column(
      children: hotelListViews,
    );
  }

  Widget getFlightDetails() {
    return Container(
        child: Expanded(
      child: Container(
          child: ListView.builder(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        scrollDirection: Axis.vertical,
        itemCount:
            offset != 0 ? listOfFlights.length + 1 : listOfFlights.length,
        itemBuilder: (context, index) {
          if (index != listOfFlights.length) {
            var flight = listOfFlights[index];

            if (flight == null && _isLoading) {
              return Container(
                  height: 100,
                  child: Center(
                      child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        const Color(0xFF00AFF5)),
                  )));
            }

            // initialize
            int a2b = 0;
            int b2a = 0;

            List<FlightRouteObject> departures = List();
            List<String> departureStopOverCity = List();
            List<FlightRouteObject> returns = List();
            List<String> returnStopOverCity = List();

            // one way
            if (typeOfTripSelected == 1) {
              for (FlightRouteObject route in flight.routes) {
                departures.add(route);
                if (route.cityTo != flight.cityTo) {
                  departureStopOverCity.add(route.cityTo);
                  a2b++;
                } else {
                  break;
                }
              } // round trip
            } else if (typeOfTripSelected == 0) {
              for (FlightRouteObject route in flight.routes) {
                departures.add(route);
                if (route.cityTo != flight.cityTo) {
                  departureStopOverCity.add(route.cityTo);
                  a2b++;
                } else {
                  break;
                }
              }

              for (FlightRouteObject route in flight.routes.reversed) {
                returns.add(route);

                if (route.cityFrom != flight.cityTo) {
                  returnStopOverCity.add(route.cityTo);
                  b2a++;
                } else {
                  break;
                }
              }
            }

            return Container(
              margin: EdgeInsets.only(left: 16, right: 16, top: 10),
              decoration: BoxDecoration(
                color: AppTheme.getTheme().backgroundColor,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: AppTheme.getTheme().dividerColor,
                      offset: Offset(0, 2),
                      blurRadius: 8.0),
                ],
              ),
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    if (_clickFlight[index] == null) {
                      _clickFlight[index] = true;
                    } else {
                      _clickFlight[index] = !_clickFlight[index];
                    }
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                left: 16.0, top: 14, bottom: 14, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  formatDates.format(flight.localDeparture) +
                                      " | Departure",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800),
                                ),
                                ((a2b >= 1 || b2a >= 1)
                                    ? Text(
                                        "Tap to view more info",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: const Color(0xFFAAAAAA),
                                            fontSize: 9),
                                      )
                                    : Container())
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 20, top: 6),
                                child: Container(
                                  width: 1,
                                  height: 120,
                                  color: Colors.grey.withOpacity(.4),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 10, top: 5, bottom: 10),
                                    margin: EdgeInsets.only(bottom: 8),
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Text(
                                      formatTime.format(
                                              departures[0].localDeparture) +
                                          " " +
                                          departures[0].flyFrom +
                                          " (" +
                                          departures[0].cityFrom +
                                          ")",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 13.6,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Wrap(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        padding: EdgeInsets.only(
                                            top: 3,
                                            bottom: 3,
                                            left: 5,
                                            right: 5),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFEDEDED)),
                                        child: Text(
                                          flight.durationDeparture,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: 13.2,
                                              color: Colors.lightBlue,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: 10, right: 5),
                                        child: Image.network(
                                            'https://storage.googleapis.com/joinflyline/images/airlines/${flight.routes[0].airline}.png',
                                            width: 20.0,
                                            height: 20.0),
                                      ),
                                      (a2b >= 1
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                  left: 5, right: 5),
                                              child: Image.network(
                                                  'https://storage.googleapis.com/joinflyline/images/airlines/${flight.routes[0].airline}.png',
                                                  width: 20.0,
                                                  height: 20.0),
                                            )
                                          : Container()),
                                      Container(
                                        margin: EdgeInsets.only(left: 5),
                                        padding: EdgeInsets.only(
                                            top: 3,
                                            bottom: 3,
                                            left: 5,
                                            right: 5),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFEDEDED)),
                                        child: Text(
                                          (a2b > 0
                                              ? (a2b > 1
                                                  ? "$a2b Stopovers"
                                                  : "$a2b Stopover")
                                              : "Direct"),
                                          softWrap: true,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13.2,
                                              color: Colors.lightBlue,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, top: 10),
                                    padding: EdgeInsets.only(
                                        top: 3, bottom: 3, left: 5, right: 5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFEDEDED)),
                                    child: Text(
                                      selectedClassOfService,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 13.2,
                                          color: Colors.lightBlue,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 10, top: 20),
                                    margin: EdgeInsets.only(bottom: 3),
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Text(
                                      formatTime.format(
                                              departures[departures.length - 1]
                                                  .localArrival) +
                                          " " +
                                          departures[departures.length - 1]
                                              .flyTo +
                                          " (" +
                                          departures[departures.length - 1]
                                              .cityTo +
                                          ")",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 13.2,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    (typeOfTripSelected == 1
                        ? Container()
                        : Container(
                            padding:
                                EdgeInsets.only(left: 16, top: 20, bottom: 10),
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text(
                              flight.nightsInDest.toString() +
                                  " nights in " +
                                  flight.cityTo,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13.2,
                                  fontWeight: FontWeight.w600),
                            ),
                          )),
                    (typeOfTripSelected == 1
                        ? Container()
                        : Container(
                            child: Row(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 16.0, top: 14, bottom: 14),
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Text(
                                        formatDates.format(
                                                returns[returns.length - 1]
                                                    .localDeparture) +
                                            " | Return",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              EdgeInsets.only(left: 20, top: 6),
                                          child: Container(
                                            width: 1,
                                            height: 120,
                                            color: Colors.grey.withOpacity(.4),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 10, top: 5, bottom: 10),
                                              margin:
                                                  EdgeInsets.only(bottom: 8),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              child: Text(
                                                formatTime.format(returns[
                                                            returns.length - 1]
                                                        .localDeparture) +
                                                    " " +
                                                    returns[returns.length - 1]
                                                        .flyFrom +
                                                    " (" +
                                                    returns[returns.length - 1]
                                                        .cityFrom +
                                                    ")",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 13.2,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 10),
                                                  padding: EdgeInsets.only(
                                                      top: 3,
                                                      bottom: 3,
                                                      left: 5,
                                                      right: 5),
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFEDEDED)),
                                                  child: Text(
                                                    flight.durationReturn,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 13.2,
                                                        color: Colors.lightBlue,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 10, right: 5),
                                                  child: Image.network(
                                                      'https://storage.googleapis.com/joinflyline/images/airlines/${flight.routes[1].airline}.png',
                                                      width: 20.0,
                                                      height: 20.0),
                                                ),
                                                (b2a >= 1
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            left: 5, right: 5),
                                                        child: Image.network(
                                                            'https://storage.googleapis.com/joinflyline/images/airlines/${flight.routes[1].airline}.png',
                                                            width: 20.0,
                                                            height: 20.0),
                                                      )
                                                    : Container()),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 5),
                                                  padding: EdgeInsets.only(
                                                      top: 3,
                                                      bottom: 3,
                                                      left: 5,
                                                      right: 5),
                                                  decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFEDEDED)),
                                                  child: Text(
                                                    (b2a > 0
                                                        ? (b2a > 1
                                                            ? "$b2a Stopovers"
                                                            : "$b2a Stopover")
                                                        : "Direct"),
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 13.2,
                                                        color: Colors.lightBlue,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 10, top: 10),
                                              padding: EdgeInsets.only(
                                                  top: 3,
                                                  bottom: 3,
                                                  left: 5,
                                                  right: 5),
                                              decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFEDEDED)),
                                              child: Text(
                                                selectedClassOfService,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 13.2,
                                                    color: Colors.lightBlue,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  top: 20,
                                                  bottom: 18),
                                              margin:
                                                  EdgeInsets.only(bottom: 3),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              child: Text(
                                                formatTime.format(returns[0]
                                                        .localArrival) +
                                                    " " +
                                                    returns[0].flyTo +
                                                    " (" +
                                                    returns[0].cityTo +
                                                    ")",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontSize: 13.2,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    // Price and Book
                    AnimatedOpacity(
                        // If the widget is visible, animate to 0.0 (invisible).
                        // If the widget is hidden, animate to 1.0 (fully visible).
                        opacity: index < _clickFlight.length &&
                                _clickFlight[index] != null &&
                                _clickFlight[index]
                            ? 1.0
                            : 0.0,
                        duration: Duration(milliseconds: 500),
                        // The green box must be a child of the AnimatedOpacity widget.
                        child: index < _clickFlight.length &&
                                _clickFlight[index] != null &&
                                _clickFlight[index]
                            ? this.getFlightDetailItems(
                                departures, returns, flight)
                            : Container()),
                    Container(
                        margin: EdgeInsets.all(5.0),
                        padding: EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              //                    <--- top side
                              color: AppTheme.getTheme().dividerColor,
                            ),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Center(
                                    child: Text(
                              "Trip Price: \$" + flight.price.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ))),
                            Expanded(
                                child: Center(
                              child: Container(
                                height: 40,
                                margin: EdgeInsets.only(left: 20.0, right: 20),
                                decoration: BoxDecoration(
                                    color: const Color(0xFF00AFF5),
                                    border: Border.all(
                                        width: 0.5,
                                        color: const Color(0xFF00AFF5))),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FlatButton(
                                      child: Text("Book",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 19.0,
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  newScreen1.HotelHomeScreen(
                                                      routes: flight.routes,
                                                      ad: this.ad,
                                                      ch: this.children,
                                                      typeOfTripSelected: this
                                                          .typeOfTripSelected,
                                                      selectedClassOfService: this
                                                          .selectedClassOfService,
                                                      flight: flight,
                                                      bookingToken:
                                                          flight.bookingToken,
                                                      retailInfo: flight.raw)),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ))
                  ],
                ),
              ),
            );
          } else {
            return getLoadMoreButton();
          }
        },
      )),
    ));
  }

  Widget getLoadMoreButton() {
    if (!_displayLoadMore) {
      return Container();
    }
    return Column(children: <Widget>[
      Container(
        height: 40,
        margin: EdgeInsets.only(left: 16.0, right: 16, top: 30),
        decoration: BoxDecoration(
            color: const Color(0xFF00AFF5),
            border: Border.all(color: const Color(0xFF00AFF5), width: 0.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("Load More",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.0,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                if (!_loadMore &&
                    selectedDeparture != null &&
                    selectedArrival != null) {
                  setState(() {
                    _loadMore = true;
                    _isLoading = true;
                  });

                  if (filterExplore != null) {
                    var items = this.originalFlights.where((i) {
                      var airlineBool = filterExplore.airlines.map((item) =>
                          item["isSelected"] &&
                          i.airlines.contains(item["code"]));

                      return i.price >= filterExplore.priceFrom.round() &&
                          i.price <= filterExplore.priceTo.round() &&
                          airlineBool.contains(true);
                    }).toList();

                    print(items.length);
                    if ((offset + perPage) > items.length) {
                      listOfFlights
                          .addAll(items.getRange(offset, items.length));
                      _displayLoadMore = false;
                    } else {
                      listOfFlights
                          .addAll(items.getRange(offset, offset + perPage));
                      _displayLoadMore = true;
                    }
                  } else {
                    if ((offset + perPage) > originalFlights.length) {
                      listOfFlights.addAll(originalFlights.getRange(
                          offset, originalFlights.length));
                      _displayLoadMore = false;
                    } else {
                      listOfFlights.addAll(
                          originalFlights.getRange(offset, offset + perPage));
                      _displayLoadMore = true;
                    }
                  }
                  setState(() {
                    _clickFlight = List(listOfFlights.length);
                    offset = offset + perPage;
                    _loadMore = false;
                    _isLoading = false;
                  });
                }
              },
            ),
          ],
        ),
      ),
      SizedBox(height: 38)
    ]);
  }

  Widget getSearchButton() {
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16, top: 2, bottom: 12),
      color: const Color(0xFF00AFF5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            child: Text("Search Flights",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold)),
            onPressed: () {
              if (!_clickedSearch &&
                  selectedDeparture != null &&
                  selectedArrival != null) {
                setState(() {
                  offset = 0;
                  originalFlights = List();
                  listOfFlights = List();
                  _clickedSearch = true;
                  _isLoading = true;
                  listOfFlights.add(null);
                  _displayLoadMore = false;
                });

                try {
                  flyLinebloc.searchFlight(
                      selectedDeparture.type + ":" + selectedDeparture.code,
                      selectedArrival.type + ":" + selectedArrival.code,
                      formatAllDay.format(startDate),
                      formatAllDay.format(startDate),
                      typeOfTripSelected == 0 ? "round" : "oneway",
                      formatAllDay.format(endDate),
                      formatAllDay.format(endDate),
                      ad.toString(),
                      "0",
                      "0",
                      selectedClassOfServiceValue,
                      "USD",
                      this.offset.toString(),
                      this.perPage.toString());
                } catch (e) {
                  print(e);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget getUpdateButton() {
    if (!_isSearched) {
      return Container();
    }
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 16, top: 2, bottom: 12),
      color: Colors.lightBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            child: Text("Update Results",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() {
                this._isSearched = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget getTimeDateUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());

//                      showDemoDialog(context: context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 0, right: 0, top: 20, bottom: 20),
                      child: InkWell(
                        onTap: () async {
                          if (typeOfTripSelected == 1) {
                            DateTime picked = await showDatePicker(
                                context: context,
                                initialDate: new DateTime.now(),
                                firstDate: new DateTime(2016),
                                lastDate: new DateTime.now()
                                    .add(Duration(days: 365 * 2)));
                            if (picked != null) {
                              setState(() {
                                startDate = picked;
                                endDate = picked;
                              });
                            }
                          } else {
                            final List<DateTime> picked =
                                await DateRangePicker.showDatePicker(
                                    context: context,
                                    initialFirstDate: new DateTime.now(),
                                    initialLastDate: (new DateTime.now())
                                        .add(new Duration(days: 7)),
                                    firstDate: new DateTime(2000),
                                    lastDate: new DateTime.now()
                                        .add(Duration(days: 365 * 2)));
                            if (picked != null && picked.length == 2) {
                              setState(() {
                                startDate = picked[0];
                                endDate = picked[1];
                              });
                            } else if (picked != null && picked.length == 2) {
                              setState(() {
                                startDate = picked[0];
                              });
                            }
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                typeOfTripSelected == 0
                                    ? "Trip Date(s)"
                                    : "Trip Date",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.grey),
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              typeOfTripSelected == 0
                                  ? "${formatDates.format(startDate)} - ${formatDates.format(endDate)}"
                                  : "${formatDates.format(startDate)}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Container(
              width: 1,
              height: 42,
              color: Colors.grey.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => RoomPopupView(
                          ad: 2,
                          room: 1,
                          ch: 0,
                          barrierDismissible: true,
                          onChnage: (ro, a, c) {
                            setState(() {
                              room = ro;
                              ad = a;
                              children = c;
                            });
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 4, right: 4, top: 4, bottom: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Passengers",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            ad > 1 ? "$ad Adults" : "$ad Adult",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Container(
              width: 1,
              height: 42,
              color: Colors.grey.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => RoomPopupView(
                          ad: 2,
                          room: 1,
                          ch: 0,
                          barrierDismissible: true,
                          onChnage: (ro, a, c) {
                            setState(() {
                              room = ro;
                              ad = a;
                              children = c;
                            });
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 4, right: 4, top: 4, bottom: 4),
                      child: InkWell(
                        onTap: () async {
                          List<Widget> items = List();
                          items.add(Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  //                    <--- top side
                                  color: AppTheme.getTheme().dividerColor,
                                ),
                              ),
                            ),
                            child: Container(),
                          ));
                          classOfServicesList.forEach((item) {
                            items.add(Container(
                                margin: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                    top: 5.0,
                                    bottom: 5.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      //                    <--- top side
                                      color: AppTheme.getTheme().dividerColor,
                                    ),
                                  ),
                                ),
                                child: SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.pop(context, item);
                                    setState(() {
                                      selectedClassOfService = item;
                                      selectedClassOfServiceValue =
                                          classOfServicesValueList[
                                              classOfServicesList
                                                  .indexOf(item)];
                                    });
                                  },
                                  child: Text(item),
                                )));
                          });
                          await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SimpleDialog(
                                  title: const Text('Select Class of Service'),
                                  children: items,
                                );
                              });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Class of Service",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              selectedClassOfService,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getSearchBarUI() {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          margin:
              const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: AppTheme.getTheme().dividerColor,
                  offset: Offset(0, 2),
                  blurRadius: 8.0),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    typeOfTripSelected = 0;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 4,
                  child: Text(
                    "Round-Trip",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: (typeOfTripSelected == 0)
                            ? Colors.black
                            : Colors.grey,
                        fontWeight: (typeOfTripSelected == 0)
                            ? FontWeight.w600
                            : FontWeight.w400),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    typeOfTripSelected = 1;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 4,
                  child: Text(
                    "One-Way",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: (typeOfTripSelected == 1)
                            ? Colors.black
                            : Colors.grey,
                        fontWeight: (typeOfTripSelected == 1)
                            ? FontWeight.w600
                            : FontWeight.w400),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.withOpacity(0.8),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 4,
                child: Stack(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 0),
                      child: Text(
                        "Coming soon",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 8,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 0),
                      child: TextField(
                        textAlign: TextAlign.center,
                        onChanged: (String txt) {},
                        onTap: () {},
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        cursorColor: AppTheme.getTheme().primaryColor,
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                          hintText: "Nomad",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin:
              const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: AppTheme.getTheme().dividerColor,
                  offset: Offset(0, 2),
                  blurRadius: 8.0),
            ],
          ),
          child: Container(
              width: MediaQuery.of(context).size.width / 4,
              padding: EdgeInsets.only(left: 10),
              child: LocationSearchUI("Departure", true,
                  notifyParent: refreshDepartureValue, city: departure)),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: AppTheme.getTheme().dividerColor,
                  offset: Offset(0, 2),
                  blurRadius: 8.0),
            ],
          ),
          child: Container(
              width: MediaQuery.of(context).size.width / 4,
              padding: EdgeInsets.only(left: 10),
              child: LocationSearchUI("Arrival", false,
                  notifyParent: refreshDepartureValue, city: arrival)),
        ),
      ],
    );
  }

  Widget getFilterBarUI() {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.getTheme().backgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: AppTheme.getTheme().dividerColor,
                    offset: Offset(0, -2),
                    blurRadius: 8.0),
              ],
            ),
          ),
        ),
        Container(
            color: AppTheme.getTheme().backgroundColor,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            originalFlights.length.toString() +
                                " Flights Found",
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          splashColor: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.all(
                            Radius.circular(4.0),
                          ),
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());

                            this.handleFilter();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Filter",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w100,
                                    fontSize: 16,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.sort,
                                      color: AppTheme.getTheme().primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  getUpdateButton()
                ],
              ),
            )),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Divider(
            height: 1,
          ),
        )
      ],
    );
  }

  void showDemoDialog({BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CalendarPopupView(
        barrierDismissible: true,
        minimumDate: DateTime.now(),
        //  maximumDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 10),
        initialEndDate: endDate,
        initialStartDate: startDate,
        onApplyClick: (DateTime startData, DateTime endData) {
          setState(() {
            if (startData != null && endData != null) {
              startDate = startData;
              endDate = endData;
            }
          });
        },
        onCancelClick: () {},
      ),
    );
  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: AppTheme.getTheme().dividerColor,
              offset: Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 8, right: 8),
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    setState(() {
                      _isSearched = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top / 2),
              alignment: Alignment.center,
              child: Text(
                "Explore",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  refreshDepartureValue(value, isDeparture) {
    if (this.mounted)
      setState(() {
        if (isDeparture)
          selectedDeparture = value;
        else
          selectedArrival = value;
      });
  }

  handleFilter() {
    if (originalFlights.length != 0) {
      if (filterExplore == null) {
        filterExplore = FilterExplore(this.originalFlights, this.airlineCodes);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FiltersScreen(
                  filterExplore: filterExplore,
                  callback: (FilterExplore f) => filter(f),
                ),
            fullscreenDialog: true),
      );
    }
  }

  void filter(FilterExplore filter) {
    var stop = filter.accomodationListData[0].isSelected
        ? 1
        : filter.accomodationListData[1].isSelected
            ? 2
            : filter.accomodationListData[2].isSelected ? 3 : 0;

    var items = this.originalFlights.where((i) {
      var airlineBool = filter.airlines
          .where((item) =>
              item["isSelected"] &&
              item["title"] != null &&
              i.airlines.contains(item["code"]))
          .toList();

      int a2b = i.routes.where((r) => r.returnFlight == 0).toList().length;
      int b2a = i.routes.where((r) => r.returnFlight == 1).toList().length;

      return (i.price >= filter.priceFrom.round() &&
              i.price <= filter.priceTo.round()) &&
          airlineBool.length != 0 &&
          (stop == 0 || (stop > 0 && (a2b == stop || b2a == stop)));
    }).toList();

    setState(() {
      listOfFlights = List();
      _displayLoadMore = true;
      if (offset > items.length) {
        listOfFlights.addAll(items.getRange(0, items.length));
        _displayLoadMore = false;
      } else {
        print(offset - perPage);
        listOfFlights.addAll(items.getRange(0, offset - perPage));
      }
      filterExplore = filter;
      _clickFlight = List(listOfFlights.length);
    });
  }
}

class LocationSearchUI extends StatefulWidget {
  final Function(LocationObject value, bool type) notifyParent;
  final title;
  final isDeparture;
  LocationObject city;

  LocationSearchUI(this.title, this.isDeparture,
      {Key key, @required this.notifyParent, this.city})
      : super(key: key);

  @override
  _LocationSearchUIState createState() => _LocationSearchUIState(title);
}

class _LocationSearchUIState extends State<LocationSearchUI>
    with TickerProviderStateMixin {
  var title;

  _LocationSearchUIState(var title) {
    this.title = title;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleAutocompleteFormField<LocationObject>(
      itemToString: (location) {
        if (location != null) {
          return location.name +
              " " +
              location.subdivisionName +
              " " +
              location.countryCode;
        }

        return widget.city != null ? widget.city.name : null;
      },
      textAlign: TextAlign.start,
      itemBuilder: (context, location) => Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              location.name +
                  " " +
                  location.subdivisionName +
                  " " +
                  location.countryCode,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
      onSearch: (search) async {
        if (search.length > 0) {
          var response = flyLinebloc.locationQuery(search);
          return response;
        } else
          return null;
      },
      onChanged: (value) => widget.notifyParent(value, widget.isDeparture),
      onSaved: (value) => widget.notifyParent(value, widget.isDeparture),
      validator: (location) =>
          location.name == null ? 'Invalid location.' : null,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      decoration: new InputDecoration(
        border: InputBorder.none,
        hintText: "Select " + widget.title + " City or Airport",
      ),
    );
  }
}

class MapHotelListView extends StatelessWidget {
  final VoidCallback callback;
  final HotelListData hotelData;

  const MapHotelListView({Key key, this.hotelData, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 8, top: 8, bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getTheme().backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppTheme.getTheme().dividerColor,
              offset: Offset(4, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          child: AspectRatio(
            aspectRatio: 2.7,
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 0.90,
                      child: Image.asset(
                        hotelData.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              hotelData.titleTxt,
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              hotelData.subTxt,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.withOpacity(0.8)),
                            ),
                            Expanded(
                              child: SizedBox(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.mapMarkerAlt,
                                            size: 12,
                                            color: AppTheme.getTheme()
                                                .primaryColor,
                                          ),
                                          Text(
                                            " ${hotelData.dist.toStringAsFixed(1)} km to city",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey
                                                    .withOpacity(0.8)),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: SmoothStarRating(
                                          allowHalfRating: true,
                                          starCount: 5,
                                          rating: hotelData.rating,
                                          size: 20,
                                          color:
                                              AppTheme.getTheme().primaryColor,
                                          borderColor:
                                              AppTheme.getTheme().primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        "\$${hotelData.perNight}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22,
                                        ),
                                      ),
                                      Text(
                                        "/per night",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                Colors.grey.withOpacity(0.8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor:
                        AppTheme.getTheme().primaryColor.withOpacity(0.1),
                    onTap: () {
                      callback();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
