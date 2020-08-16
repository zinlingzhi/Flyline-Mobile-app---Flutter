import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:motel/appTheme.dart';
import 'package:motel/modules/login/loginScreen.dart';
import 'package:motel/modules/profile/myWebView.dart';

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  var pageController = PageController(initialPage: 0);
  var pageViewModelData = List<PageViewData>();

  Timer sliderTimer;
  var currentShowIndex = 0;

  @override
  void initState() {
    pageViewModelData.add(PageViewData(
      titleText: 'Stop Paying Retail',
      subText:
          'We source flights from over 250 airlines and sell them directly to you with zero markups.',
      assetsImage: 'assets/images/bg_introduction1.png',
    ));

    pageViewModelData.add(PageViewData(
      titleText: 'Virtual Interlining',
      subText:
          'We connect one-way flights from different carriers to deliver the best savings.',
      assetsImage: 'assets/images/bg_introduction2.png',
    ));

    pageViewModelData.add(PageViewData(
      titleText: 'Always the Cheapest',
      subText:
          'We will always display the cheapest fare, whether it is a public or FlyLine fare.',
      assetsImage: 'assets/images/bg_introduction3.png',
    ));

//    sliderTimer = Timer.periodic(Duration(seconds: 4), (timer) {
//      if (currentShowIndex == 0) {
//        pageController.animateTo(MediaQuery.of(context).size.width,
//            duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
//      } else if (currentShowIndex == 1) {
//        pageController.animateTo(MediaQuery.of(context).size.width * 2,
//            duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
//      } else if (currentShowIndex == 2) {
//        pageController.animateTo(0,
//            duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
//      }
//    });
    super.initState();
  }

  @override
  void dispose() {
    sliderTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: AppTheme.getTheme().backgroundColor,
        body: Column(
          children: <Widget>[
            Expanded(
                child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00AFF5),
                    image: DecorationImage(
                      image: AssetImage('assets/images/bg_introduction2.png'),
                      fit: BoxFit.cover,
                    )
                  ),
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentShowIndex = index;
                      });
                    },
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      PagePopup(imageData: pageViewModelData[0]),
                      PagePopup(imageData: pageViewModelData[1]),
                      PagePopup(imageData: pageViewModelData[2]),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10.0,
                  left: 0.0,
                  right: 0.0,
                  child: Center(
                    child: PageIndicator(
                      layout: PageIndicatorLayout.WARM,
                      size: 15.0,
                      controller: pageController,
                      space: 10.0,
                      count: 3,
                      color: const Color(0xFFFFFFFF),
                      activeColor: AppTheme.getTheme().primaryColor,
                    )
                  ),
                ),
              ],
            )),
            Padding(
              padding: const EdgeInsets.only(
                  left: 48, right: 48, bottom: 8, top: 32),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00AFF5),
                  borderRadius: BorderRadius.all(Radius.circular(1.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppTheme.getTheme().dividerColor,
                      blurRadius: 8,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(1.0)),
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen()),
                      );
                    },
                    child: Center(
                      child: Text(
                        "Log In",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
            Padding(
              padding: const EdgeInsets.only(
                   bottom: 32, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      highlightColor: Colors.transparent,
                      onTap: () {},
                      child: Center(
                        child: Text(
                          "Flyline",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppTheme.getTheme().disabledColor),
                        ),
                      ),
                    ),
                  ),
                  Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.all(Radius.circular(1.0)),
                    highlightColor: Colors.transparent,
                    onTap: () {},
                    child: Center(
                      child: Text(
                        " - ",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppTheme.getTheme().disabledColor),
                      ),
                    ),
                  ),
                ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyWebView(
                              title: "Terms of Service",
                              selectedUrl:
                              "https://joinflyline.com/terms-of-services",
                            ),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          "Terms of Service",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppTheme.getTheme().disabledColor),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      highlightColor: Colors.transparent,
                      onTap: () {},
                      child: Center(
                        child: Text(
                          " | ",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppTheme.getTheme().disabledColor),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                      highlightColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyWebView(
                              title: "Privacy Policy",
                              selectedUrl:
                              "https://joinflyline.com/privacy-policy",
                            ),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppTheme.getTheme().disabledColor),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}

class PagePopup extends StatelessWidget {
  final PageViewData imageData;

  const PagePopup({Key key, this.imageData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Text(
            imageData.titleText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 25.0, left: 30, right: 30),
          child: Text(
            imageData.subText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFFFFFFFF),
                height: 1.5
            ),
          ),
        ),
      ],
    );
  }
}

class PageViewData {
  final String titleText;
  final String subText;
  final String assetsImage;

  PageViewData({this.titleText, this.subText, this.assetsImage});
}
