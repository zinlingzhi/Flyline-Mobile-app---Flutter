import 'dart:convert';

import 'package:flutter/material.dart';

import '../../appTheme.dart';
import 'previousTripView.dart';
import 'recentSearchesListView.dart';
import 'upcomingListView.dart';

class MyTripsScreen extends StatefulWidget {
  final AnimationController animationController;

  const MyTripsScreen({Key key, this.animationController}) : super(key: key);
  @override
  _MyTripsScreenState createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen>
    with TickerProviderStateMixin {
  AnimationController tabAnimationController;
  Map<String, dynamic> airlineCodes;

  Widget indexView = Container();
  TopBarType topBarType = TopBarType.Upcomming;

  @override
  void initState() {
    this.getAirlineCodes();
    tabAnimationController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);

    tabAnimationController..forward();
    widget.animationController.forward();

    setState(() {
      indexView = FutureBuilder(
        future: Future<String>.delayed(
          Duration(seconds: 1),
              () => 'Data Loaded',
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(const Color(0xFF00AFF5)),
                )
              )
            );
          } else {
            return UpcomingListView(
              airlineCodes: airlineCodes,
              animationController: tabAnimationController,
            );

          }
        },
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    tabAnimationController.dispose();
    super.dispose();
  }

  void getAirlineCodes() async {
    airlineCodes = json.decode(await DefaultAssetBundle.of(context)
        .loadString("jsonFile/airline_codes.json"));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: widget.animationController,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 40 * (1.0 - widget.animationController.value), 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Container(child: appBar()),
                ),
                tabViewUI(topBarType),
                Expanded(
                  child: indexView,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void tabClick(TopBarType tabType) {
    if (tabType != topBarType) {
      topBarType = tabType;
      tabAnimationController.reverse().then((f) {
        if (tabType == TopBarType.Upcomming) {
          setState(() {
            indexView = UpcomingListView(
              airlineCodes: airlineCodes,
              animationController: tabAnimationController,
            );
          });
        } else if (tabType == TopBarType.Previous) {
          setState(() {
            indexView = PreviousTripView(
              airlineCodes: airlineCodes,
              animationController: tabAnimationController,
            );
          });
        } else if (tabType == TopBarType.Searched) {
          setState(() {
            indexView = SearchedListView(
              animationController: tabAnimationController,
            );
          });
        }
      });
    }
  }

  Widget tabViewUI(TopBarType tabType) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(1.0)),
          color: AppTheme.getTheme().dividerColor.withOpacity(0.05),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      highlightColor: Colors.transparent,
                      splashColor:
                          AppTheme.getTheme().primaryColor.withOpacity(0.2),
                      onTap: () {
                        tabClick(TopBarType.Upcomming);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 16),
                        child: Center(
                          child: Text(
                            "Upcoming",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: tabType == TopBarType.Upcomming
                                    ? AppTheme.getTheme().primaryColor
                                    : AppTheme.getTheme().disabledColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      highlightColor: Colors.transparent,
                      splashColor:
                          AppTheme.getTheme().primaryColor.withOpacity(0.2),
                      onTap: () {
                        tabClick(TopBarType.Previous);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 16),
                        child: Center(
                          child: Text(
                            "Previous",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: tabType == TopBarType.Previous
                                    ? AppTheme.getTheme().primaryColor
                                    : AppTheme.getTheme().disabledColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      highlightColor: Colors.transparent,
                      splashColor:
                          AppTheme.getTheme().primaryColor.withOpacity(0.2),
                      onTap: () {
                        tabClick(TopBarType.Searched);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 16),
                        child: Center(
                          child: Text(
                            "Searched",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: tabType == TopBarType.Searched
                                    ? AppTheme.getTheme().primaryColor
                                    : AppTheme.getTheme().disabledColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24 + 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "My Trips",
            style: new TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

enum TopBarType { Upcomming, Previous, Searched }
