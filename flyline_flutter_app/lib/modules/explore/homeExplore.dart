import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motel/appTheme.dart';
import 'package:motel/models/flylineDeal.dart';
import 'package:motel/models/hotelListData.dart';
import 'package:motel/modules/explore/homeExploreSliderView.dart';
import 'package:motel/modules/explore/popularListView.dart';
import 'package:motel/modules/explore/titleView.dart';
import 'package:motel/modules/hotelBooking/hotelHomeScreen.dart';
import 'package:motel/modules/hotelBooking/hotelListView.dart';
import 'package:motel/modules/hotelDetailes/hotelDetailes.dart';
import 'package:motel/network/blocs.dart';

class HomeExploreScreen extends StatefulWidget {
  final AnimationController animationController;

  const HomeExploreScreen({Key key, this.animationController})
      : super(key: key);
  @override
  _HomeExploreScreenState createState() => _HomeExploreScreenState();
}

class _HomeExploreScreenState extends State<HomeExploreScreen>
    with TickerProviderStateMixin {
  var hotelList = HotelListData.hotelList;
  Map<String, dynamic> airlineCodes;
  ScrollController controller;
  AnimationController _animationController;
  var sliderImageHieght = 0.0;
  @override
  void initState() {
    _animationController =
        AnimationController(duration: Duration(milliseconds: 0), vsync: this);
    widget.animationController.forward();
    controller = ScrollController(initialScrollOffset: 0.0);

    controller.addListener(() {
      if (context != null) {
        if (controller.offset < 0) {
          // we static set the just below half scrolling values
          _animationController.animateTo(0.0);
        } else if (controller.offset > 0.0 &&
            controller.offset < sliderImageHieght) {
          // we need around half scrolling values
          if (controller.offset < ((sliderImageHieght / 1.5))) {
            _animationController
                .animateTo((controller.offset / sliderImageHieght));
          } else {
            // we static set the just above half scrolling values "around == 0.64"
            _animationController
                .animateTo((sliderImageHieght / 1.5) / sliderImageHieght);
          }
        }
      }
    });
    this.getAirlineCodes();
    flyLinebloc.randomDeals();
    super.initState();
  }

  void getAirlineCodes() async {
    airlineCodes = json.decode(await DefaultAssetBundle.of(context)
        .loadString("jsonFile/airline_codes.json"));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    sliderImageHieght = MediaQuery.of(context).size.width * 0.9;
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: widget.animationController,
          // FadeTransition and Transform : just for screen loading animation on fistTime
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 40 * (1.0 - widget.animationController.value), 0.0),
            child: Scaffold(
              backgroundColor: AppTheme.getTheme().backgroundColor,
              body: Stack(
                children: <Widget>[
                  Container(
                    color: AppTheme.getTheme().backgroundColor,
                    child: ListView.builder(
                      controller: controller,
                      itemCount: 4,
                      // padding on top is only for we need spec for sider
                      padding: EdgeInsets.only(
                          top: sliderImageHieght + 32, bottom: 16),
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        // some list UI
                        var count = 4;
                        var animation = Tween(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: widget.animationController,
                            curve: Interval((1 / count) * index, 1.0,
                                curve: Curves.fastOutSlowIn),
                          ),
                        );
                        if (index == 0) {
                          return TitleView(
                            titleTxt: 'Popular Destinations',
                            subTxt: '',
                            animation: animation,
                            animationController: widget.animationController,
                          );
                        } else if (index == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: PopularListView(
                              animationController: widget.animationController,
                              callBack: (index) {},
                            ),
                          );
                        } else if (index == 2) {
                          return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HotelHomeScreen(),
                                      fullscreenDialog: true),
                                );
                              },
                              child: TitleView(
                                titleTxt: 'Best Deals',
                                subTxt: 'View all',
                                animation: animation,
                                isLeftButton: true,
                                animationController: widget.animationController,
                              ));
                        } else {
                          //   return getDealListView(index);
                          return Column(
                            children: [_viewRandomDealsUI()],
                          );
                        }
                      },
                    ),
                  ),
                  // sliderUI with 3 images are moving
                  _sliderUI(),

                  // viewHotels Button UI for click event
//                  _viewHotelsButton(_animationController),

                  //just gradient for see the time and battry Icon on "TopBar"
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [
                          AppTheme.getTheme().backgroundColor.withOpacity(0.4),
                          AppTheme.getTheme().backgroundColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                    ),
                  ),
                  // serachUI on Top  Positioned
                  Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 0,
                    right: 0,
                    child: serachUI(),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _viewRandomDealsUI() {
    return StreamBuilder<List<FlylineDeal>>(
        stream: flyLinebloc.randomDealItems.stream,
        builder: (context, AsyncSnapshot<List<FlylineDeal>> snapshot) {
          if (snapshot.data != null && snapshot.data.isNotEmpty) {
            var deals = snapshot.data;

            List<Widget> list = List<Widget>();
            deals.forEach((deal) {
              list.add(InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HotelHomeScreen(
                                departureCode: deal.flyFrom,
                                departure: deal.cityFromName,
                                arrivalCode: deal.flyTo,
                                arrival: deal.cityToName,
                                startDate: deal.departureDate,
                                endDate: deal.returnDate,
                              ),
                          fullscreenDialog: true),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.getTheme().backgroundColor,
                        borderRadius: BorderRadius.all(Radius.circular(1)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppTheme.getTheme().dividerColor,
                            blurRadius: 8,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.only(
                              top: 18.0,
                              bottom: 10.0,
                            ),
                            height: 78,
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      deal.dealString,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.8,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                      'Airlines : ' +
                                          deal.getAirlines(airlineCodes) +
                                          '    Cost: ' +
                                          deal.cost,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: AppTheme.getTheme()
                                              .disabledColor),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )));
            });

            return Column(
              children: list,
            );
          } else {
            return Container();
          }
        });
  }

//  Widget _viewHotelsButton(AnimationController _animationController) {
//    return AnimatedBuilder(
//      animation: _animationController,
//      builder: (BuildContext context, Widget child) {
//        var opecity = 1.0 -
//            (_animationController.value > 0.64
//                ? 1.0
//                : _animationController.value);
//        return Positioned(
//          left: 0,
//          right: 0,
//          top: 0,
//          height: sliderImageHieght * (1.0 - _animationController.value),
//          child: Stack(
//            children: <Widget>[
//              Positioned(
//                bottom: 32,
//                left: 24,
//                child: Opacity(
//                  opacity: opecity,
//                  child: Container(
//                    height: 48,
//                    decoration: BoxDecoration(
//                      color: AppTheme.getTheme().primaryColor,
//                      borderRadius: BorderRadius.all(Radius.circular(1)),
//                      boxShadow: <BoxShadow>[
//                        BoxShadow(
//                          color: AppTheme.getTheme().dividerColor,
//                          blurRadius: 8,
//                          offset: Offset(4, 4),
//                        ),
//                      ],
//                    ),
//                    child: Material(
//                      color: Colors.transparent,
//                      child: InkWell(
//                        borderRadius: BorderRadius.all(Radius.circular(1)),
//                        highlightColor: Colors.transparent,
//                        onTap: () {
//                          if (opecity != 0) {
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                  builder: (context) => HotelHomeScreen()),
//                            );
//                          }
//                        },
//                        child: Center(
//                          child: Padding(
//                            padding: const EdgeInsets.only(
//                                left: 24, right: 24, top: 8, bottom: 8),
//                            child: Text(
//                              "View Hotels",
//                              style: TextStyle(
//                                  fontWeight: FontWeight.w500,
//                                  fontSize: 16,
//                                  color: Colors.white),
//                            ),
//                          ),
//                        ),
//                      ),
//                    ),
//                  ),
//                ),
//              ),
//            ],
//          ),
//        );
//      },
//    );
//  }

  Widget _sliderUI() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          // we calculate the opecity between 0.64 to 1.0
          var opecity = 1.0 -
              (_animationController.value > 0.64
                  ? 1.0
                  : _animationController.value);
          return SizedBox(
            height: sliderImageHieght * (1.0 - _animationController.value),
            child: HomeExploreSliderView(
              opValue: opecity,
              click: () {},
            ),
          );
        },
      ),
    );
  }

  Widget getDealListView(int index) {
    var hotelList = HotelListData.hotelList;
    List<Widget> list = List<Widget>();
    hotelList.forEach((f) {
      var animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: widget.animationController,
          curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn),
        ),
      );
      list.add(
        HotelListView(
          callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HotelDetailes(
                        hotelData: f,
                      ),
                  fullscreenDialog: true),
            );
          },
          hotelData: f,
          animation: animation,
          animationController: widget.animationController,
        ),
      );
    });
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: list,
      ),
    );
  }

  Widget serachUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getTheme().backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(1)),
          // border: Border.all(
          //   color: HexColor("#757575").withOpacity(0.6),
          // ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppTheme.getTheme().dividerColor,
              blurRadius: 8,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Container(
            height: 48,
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(1)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HotelHomeScreen(),
                        fullscreenDialog: true),
                  );
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.search,
                      size: 18,
                      color: AppTheme.getTheme().primaryColor,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: TextField(
                        maxLines: 1,
                        // onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(builder: (context) => SearchScreen(), fullscreenDialog: true),
                        //   );
                        // },
                        enabled: false,
                        onChanged: (String txt) {},
                        style: TextStyle(
                          fontSize: 16,
                          // color: AppTheme.dark_grey,
                        ),
                        cursorColor: AppTheme.getTheme().primaryColor,
                        decoration: new InputDecoration(
                          errorText: null,
                          border: InputBorder.none,
                          hintText: "Where are you going?",
                          hintStyle: TextStyle(
                              color: AppTheme.getTheme().disabledColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
