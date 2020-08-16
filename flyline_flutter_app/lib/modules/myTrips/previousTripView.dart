import 'package:flutter/material.dart';
import 'package:motel/models/bookedFlight.dart';
import 'package:motel/modules/myTrips/bookFlightButton.dart';

import '../../network/blocs.dart';
import 'flightsListView.dart';

class PreviousTripView extends StatefulWidget {
  final AnimationController animationController;
  final Map<String, dynamic> airlineCodes;

  const PreviousTripView(
      {Key key,
      @required this.animationController,
      @required this.airlineCodes})
      : super(key: key);

  @override
  _PreviousTripViewState createState() => _PreviousTripViewState();
}

class _PreviousTripViewState extends State<PreviousTripView> {
  @override
  void initState() {
    widget.animationController.forward();
    super.initState();
    flyLinebloc.pastOrUpcomingFlightSummary(false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookedFlight>>(
        stream: flyLinebloc.pastFlights,
        builder: (context, AsyncSnapshot<List<BookedFlight>> snapshot) {
          if (snapshot.data != null) {
            getCount() => snapshot.data.length;

            calculateAnimation(int position) =>
                Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: widget.animationController,
                    curve: Interval((1 / getCount()) * position, 1.0,
                        curve: Curves.fastOutSlowIn)));

            return snapshot.data.isEmpty
                ? EmptyFlightList(
                    text: 'You have no previous trips. Start booking!',
                  )
                : FlightsListView(
                    airlineCodes: widget.airlineCodes,
                    flightData: snapshot.data,
                    animation: calculateAnimation(getCount()),
                    animationController: widget.animationController,
                  );
          } else
            return Column(
              children: <Widget>[
                Center(child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(const Color(0xFF00AFF5)),
                )),
                BookFlightButton()
              ],
            );
        });
  }
}
