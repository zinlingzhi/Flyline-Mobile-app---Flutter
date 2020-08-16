import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motel/appTheme.dart';
import 'package:motel/testScreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'introductionScreen.dart';
import 'modules/bottomTab/bottomTabScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(new MyApp()));
  // runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  static restartApp(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    final _MyAppState state = context.findAncestorStateOfType<_MyAppState>();

    state.restartApp();
  }

  static setCustomeTheme(BuildContext context) {
    final _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setCustomeTheme();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = new UniqueKey();

  @override
  void initState() {
    super.initState();

    this.initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    await OneSignal.shared.init("905d4559-c3bb-442c-bed5-93a097da8a7e",
        iOSSettings: {
          OSiOSSettings.autoPrompt: true,
          OSiOSSettings.inAppLaunchUrl: true
        });
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);
  }

  void restartApp() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  void setCustomeTheme() {
    setState(() {
      AppTheme.isLightTheme = !AppTheme.isLightTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          AppTheme.isLightTheme ? Brightness.dark : Brightness.light,
      statusBarBrightness:
          AppTheme.isLightTheme ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:
          AppTheme.isLightTheme ? Colors.white : Colors.black,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness:
          AppTheme.isLightTheme ? Brightness.dark : Brightness.light,
    ));
    return MaterialApp(
      key: key,
      title: 'FlyLine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(),
      routes: routes,
    );
  }

  var routes = <String, WidgetBuilder>{
//    Routes.SPLASH: (BuildContext context) => IntroductionScreen(),
    Routes.SPLASH: (BuildContext context) => TestScreen(),
    Routes.TabScreen: (BuildContext context) => new BottomTabScreen(),
  };
}

class Routes {
  static const String SPLASH = "/";
  static const String TabScreen = "/bottomTab/bottomTabScreen";
}
