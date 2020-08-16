import 'package:flutter/material.dart';
import 'package:motel/models/recentlFlightSearch.dart';
import 'package:motel/modules/hotelBooking/hotelHomeScreen.dart';
import 'package:motel/network/blocs.dart';

import '../../appTheme.dart';
import '../../models/hotelListData.dart';
import 'bookFlightButton.dart';
import 'flightsListView.dart';

class SearchedListView extends StatefulWidget {
  final AnimationController animationController;

  const SearchedListView({Key key, this.animationController}) : super(key: key);
  @override
  _SearchedListViewState createState() => _SearchedListViewState();
}

class _SearchedListViewState extends State<SearchedListView> {
  var hotelList = HotelListData.hotelList;

  @override
  void initState() {
    widget.animationController.forward();
    flyLinebloc.flightSearchHistory();

    super.initState();
  }

  getCount() => hotelList.length;

  calculateAnimation(int scale) =>
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: widget.animationController,
          curve: Interval((1 / getCount()) * scale, 1.0,
              curve: Curves.fastOutSlowIn)));
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: flyLinebloc.recentFlightSearches,
        builder: (context, AsyncSnapshot<List<RecentFlightSearch>> snapshot) {
          if (snapshot.data != null) {
            getCount() => snapshot.data.length;

            calculateAnimation(int scale) =>
                Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: widget.animationController,
                    curve: Interval((1 / getCount()) * scale, 1.0,
                        curve: Curves.fastOutSlowIn)));

            return snapshot.data.isEmpty
                ? EmptyFlightList(
                    text: 'You have no searched flights. Start searching!',
                  )
                : RecentFlightSearchesListView(
                    searchData: snapshot.data,
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

class RecentFlightSearchesListView extends StatelessWidget {
  final VoidCallback callback;
  final List<RecentFlightSearch> searchData;
  final AnimationController animationController;
  final Animation animation;

  const RecentFlightSearchesListView({
    Key key,
    @required this.searchData,
    @required this.animationController,
    @required this.animation,
    this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: searchData.length,
        padding: EdgeInsets.only(top: 8, bottom: 16),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          var search = searchData[index];
          String rountripOrOneWay;
          search.isRoundtrip == null
              ? rountripOrOneWay = 'Round Trip'
              : rountripOrOneWay =
                  search.isRoundtrip ? 'Round Trip' : 'One Way';

          animationController.forward();
          return Column(
            children: <Widget>[
              AnimatedBuilder(
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
                                      departureCode: search.flyFrom,
                                      arrivalCode: search.flyTo,
                                      departure: search.cityFrom,
                                      arrival: search.cityTo,
                                      startDate: search.departureDateFull,
                                      endDate: search.arrivalDateFull,
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
                                  color: AppTheme.getTheme()
                                      .dividerColor
                                      .withAlpha(100),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              '${search.cityFrom}-> ${search.cityTo}, $rountripOrOneWay | ${search.departureDate}-${search.arrivalDate}',
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (index == searchData.length - 1) BookFlightButton()
            ],
          );
        },
      ),
    );
  }
}
