
import 'package:flutter/material.dart';
import 'package:motel/modules/hotelBooking/hotelHomeScreen.dart';

import '../../appTheme.dart';
import '../../models/bookedFlight.dart';
import 'bookFlightButton.dart';

class FlightsListView extends StatelessWidget {
  final VoidCallback callback;
  final List<BookedFlight> flightData;
  final AnimationController animationController;
  final Animation animation;
  final Map<String, dynamic> airlineCodes;

  FlightsListView({
    Key key,
    @required this.flightData,
    @required this.animationController,
    @required this.animation,
    @required this.airlineCodes,
    this.callback,
  }) : super(key: key);

  int getCount() => flightData.length;

  Animation calculateAnimation(int scale) =>
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: animationController,
          curve: Interval((1 / getCount()) * scale, 1.0,
              curve: Curves.fastOutSlowIn)));

  void onFlightTapped() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: getCount(),
        padding: EdgeInsets.only(top: 8, bottom: 16),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          animationController.forward();
          return Column(
            children: <Widget>[
              buildListTiles(flightData[index]),
              if (index == getCount() - 1)
                BookFlightButton(
                )
            ],
          );
        },
      ),
    );
  }

  buildListTiles(BookedFlight flight) {
    String rountripOrOneWay;
    flight.isRoundtrip == null
        ? rountripOrOneWay = 'Round Trip'
        : rountripOrOneWay = flight.isRoundtrip ? 'Round Trip' : 'One Way';

    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 50 * (1.0 - animation.value), 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HotelHomeScreen(
                        departureCode: flight.flyFrom,
                        arrivalCode: flight.flyTo,
                        departure: flight.cityFrom,
                        arrival: flight.cityTo,
                        startDate: flight.localDepartureFull,
                        endDate: flight.localArrivalFull,
                      ),
                      fullscreenDialog: true),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 8, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.getTheme().backgroundColor,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppTheme.getTheme().dividerColor.withAlpha(100),
                        offset: Offset(1, 3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 12),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    '${flight.cityFrom} -> ${flight.cityTo}, $rountripOrOneWay | ${flight.localDeparture}-${flight.localArrival}', //'New York -> London, Round Trip | 02/10-02/12', //hotelData.titleTxt,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child:Text(
                              'Airlines: ' + flight.getAirlines(airlineCodes),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.withOpacity(0.8)),
                            )),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Text(
                                'Cost: \$${flight.price}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.withOpacity(0.8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class EmptyFlightList extends StatelessWidget {
  const EmptyFlightList({
    Key key,
    @required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Stack(children: <Widget>[
              ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.5, 0.9],
                    colors: [
                      Colors.black.withOpacity(0),
                      Colors.black.withOpacity(.25),
                      Colors.black.withOpacity(0),
                    ],
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcOver,
                child: Container(
                  height: 250,
                  child: Image.asset(
                    'assets/images/sandy_beach.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                  top: 70,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 96,
                      child: Text(
                        text,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline.copyWith(
                            color: Colors.white,
                            fontFamily: 'Dona',
                            fontSize: 24,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  )),
            ])),
        BookFlightButton(
        )
      ],
    );
  }
}
