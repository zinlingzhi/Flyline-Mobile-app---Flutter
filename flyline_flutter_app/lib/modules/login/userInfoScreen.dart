import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:motel/appTheme.dart';
import 'package:motel/models/locations.dart';
import 'package:motel/modules/login/customDatePickerModel.dart';
import 'package:motel/network/blocs.dart';
import '../../main.dart';
import 'loginScreen.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class UserInfoScreen extends StatefulWidget {
  String home;
  String email;
  String password;
  LocationObject selectedHomeAirport;

  UserInfoScreen(
      this.home, this.email, this.password, this.selectedHomeAirport);
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  String plan;
  String home;
  String email;
  String password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> planList = [
    "Basic (\$49.99/yr)",
    "Premium (\$79.99/yr)",
  ];
  List<String> planValues = [
    "basic",
    "premium",
  ];
  final Map<String, dynamic> _formData = {
    'home_airport': null,
    'email': null,
    'password': null,
    'first_name': null,
    'last_name': null,
    'promo_code': null,
    'zip': null,
    'card_number': null,
    'expiry': null,
    'cvc': null,
    'plan': null,
  };

  var expDateController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        // backgroundColor: AppTheme.getTheme().backgroundColor,
        body: Form(
          key: _formKey,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: appBar(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 24,
                                ),
                                Expanded(
                                  child: getFTButton(),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: getFTButton(isFacebook: false),
                                ),
                                SizedBox(
                                  width: 24,
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 16),
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                  text: '- As a reminder we\'ll email you',
                                  style: TextStyle(
                                    color: const Color(0xFF929292),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' 3 days',
                                      style: TextStyle(
                                        color: const Color(0xFF929292),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Before.',
                                      style: TextStyle(
                                        color: const Color(0xFF929292),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    )
                                  ]),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 24),
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                  text: '- No Commitments.',
                                  style: TextStyle(
                                    color: const Color(0xFF929292),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' Cancel',
                                      style: TextStyle(
                                        color: const Color(0xFF929292),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' at anytime.',
                                      style: TextStyle(
                                        color: const Color(0xFF929292),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    )
                                  ]),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getTheme().backgroundColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AppTheme.getTheme().dividerColor,
                                  blurRadius: 8,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Container(
                                height: 58,
                                child: Center(
                                  child: TextFormField(
                                    maxLines: 1,
                                    onChanged: (String txt) {},
                                    // ignore: missing_return
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return 'Fill this field';
                                      }
                                    },
                                    onSaved: (String value) {
                                      _formData['first_name'] = value;
                                    },
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    cursorColor:
                                        AppTheme.getTheme().primaryColor,
                                    decoration: new InputDecoration(
                                      errorText: null,
                                      border: InputBorder.none,
                                      hintText: "First Name",
                                      hintStyle: TextStyle(
                                          color: AppTheme.getTheme()
                                              .disabledColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getTheme().backgroundColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AppTheme.getTheme().dividerColor,
                                  blurRadius: 8,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Container(
                                height: 58,
                                child: Center(
                                  child: TextFormField(
                                    maxLines: 1,
                                    onChanged: (String txt) {},
                                    // ignore: missing_return
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return 'Fill this field';
                                      }
                                    },
                                    onSaved: (String value) {
                                      _formData['last_name'] = value;
                                    },
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    cursorColor:
                                        AppTheme.getTheme().primaryColor,
                                    decoration: new InputDecoration(
                                      errorText: null,
                                      border: InputBorder.none,
                                      hintText: "Last Name",
                                      hintStyle: TextStyle(
                                          color: AppTheme.getTheme()
                                              .disabledColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getTheme().backgroundColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AppTheme.getTheme().dividerColor,
                                  blurRadius: 8,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Container(
                                height: 58,
                                child: Center(
                                  child: DropdownButtonFormField<String>(
                                    items: planList
                                        .map((String dropDownStringItem) {
                                      return DropdownMenuItem<String>(
                                        value: dropDownStringItem,
                                        child: Text(dropDownStringItem),
                                      );
                                    }).toList(),
                                    onChanged: (String newValueSelected) {
                                      print("onChanged");
                                      setState(() {
                                        plan = newValueSelected;
                                      });
                                    },
                                    onSaved: (String value) {
                                      print("onSaved");

                                      _formData['plan'] =
                                          planValues[planList.indexOf(value)];
                                    },
                                    decoration:
                                        InputDecoration.collapsed(hintText: ''),
                                    hint: Text(
                                      'Select a Plan',
                                      style: TextStyle(
                                          color: AppTheme.getTheme()
                                              .disabledColor),
                                    ),
                                    value: plan,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getTheme().backgroundColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AppTheme.getTheme().dividerColor,
                                  blurRadius: 8,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Container(
                                height: 58,
                                child: Center(
                                  child: TextFormField(
                                    maxLines: 1,
                                    onChanged: (String txt) {},
                                    onSaved: (String value) {
                                      _formData['promo_code'] = value;
                                    },
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    cursorColor:
                                        AppTheme.getTheme().primaryColor,
                                    decoration: new InputDecoration(
                                      errorText: null,
                                      border: InputBorder.none,
                                      hintText: "Promo Code",
                                      hintStyle: TextStyle(
                                          color: AppTheme.getTheme()
                                              .disabledColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getTheme().backgroundColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AppTheme.getTheme().dividerColor,
                                  blurRadius: 8,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Container(
                                height: 58,
                                child: Center(
                                  child: TextFormField(
                                    maxLines: 1,
                                    onChanged: (String txt) {},
                                    onSaved: (String value) {
                                      _formData['zip'] = value;
                                    },
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    cursorColor:
                                        AppTheme.getTheme().primaryColor,
                                    decoration: new InputDecoration(
                                      errorText: null,
                                      border: InputBorder.none,
                                      hintText: "Billing Zip",
                                      hintStyle: TextStyle(
                                          color: AppTheme.getTheme()
                                              .disabledColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getTheme().backgroundColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AppTheme.getTheme().dividerColor,
                                  blurRadius: 8,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Container(
                                height: 58,
                                child: Center(
                                  child: TextFormField(
                                    maxLines: 1,
                                    onChanged: (String txt) {},
                                    onSaved: (String value) {
                                      _formData['card_number'] = value;
                                    },
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    cursorColor:
                                        AppTheme.getTheme().primaryColor,
                                    decoration: new InputDecoration(
                                      errorText: null,
                                      border: InputBorder.none,
                                      hintText: "Credit Card Number",
                                      hintStyle: TextStyle(
                                          color: AppTheme.getTheme()
                                              .disabledColor),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 24, right: 12, bottom: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.getTheme().backgroundColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(1)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: AppTheme.getTheme().dividerColor,
                                        blurRadius: 8,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: Container(
                                      height: 58,
                                      child: Center(
                                        child: TextField(
                                          controller: expDateController,
                                          onTap: () {
                                            DatePicker.showPicker(
                                              context,
                                              showTitleActions: true,
                                              pickerModel:
                                                  CustomDatePickerModel(
                                                      currentTime:
                                                          DateTime.now(),
                                                      minTime:
                                                          DateTime(1960, 1, 1),
                                                      locale: LocaleType.en),
                                              onChanged: (date) {
                                                print('change $date');
                                              },
                                              onConfirm: (date) {
                                                var formatter =
                                                    new DateFormat('MM/yy');
                                                expDateController.text =
                                                    _formData['expiry'] =
                                                        formatter.format(date);
                                              },
                                            );
//                                            DatePicker.showDatePicker(context,
//                                                showTitleActions: true,
//                                                minTime: DateTime(1960, 1, 1),
//                                                onChanged: (date) {
//                                              print('change $date');
//                                            }, onConfirm: (date) {
//                                              var formatter =
//                                                  new DateFormat('MM/yy');
//                                              expDateController.text =
//                                                  _formData['expiry'] =
//                                                      formatter.format(date);
//                                            },
//                                                currentTime: DateTime.now(),
//                                                locale: LocaleType.en);
                                          },
                                          maxLines: 1,
                                          onChanged: (String txt) {},
//                                          onSaved: (String value) {
//                                            _formData['expiry'] = value + "111";
//                                          },
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                          cursorColor:
                                              AppTheme.getTheme().primaryColor,
                                          decoration: new InputDecoration(
                                            errorText: null,
                                            border: InputBorder.none,
                                            hintText: "Exp Date",
                                            hintStyle: TextStyle(
                                                color: AppTheme.getTheme()
                                                    .disabledColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, right: 24, bottom: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.getTheme().backgroundColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(1)),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: AppTheme.getTheme().dividerColor,
                                        blurRadius: 8,
                                        offset: Offset(4, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: Container(
                                      height: 58,
                                      child: Center(
                                        child: TextFormField(
                                          maxLines: 1,
                                          onChanged: (String txt) {},
                                          onSaved: (String value) {
                                            _formData['cvc'] = value;
                                          },
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                          cursorColor:
                                              AppTheme.getTheme().primaryColor,
                                          decoration: new InputDecoration(
                                            errorText: null,
                                            border: InputBorder.none,
                                            hintText: "CCV Code",
                                            hintStyle: TextStyle(
                                                color: AppTheme.getTheme()
                                                    .disabledColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 8, top: 24),
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              color: AppTheme.getTheme().primaryColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(1)),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24.0)),
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  register(_formData);

                                  //   Navigator.pushNamedAndRemoveUntil(
                                  //       context,
                                  //       Routes.TabScreen,
                                  //       (Route<dynamic> route) => false);
                                },
                                child: Center(
                                  child: Text(
                                    "Get Started",
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
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "By signing up, you agree to FlyLine Terms of\nServices and Privacy Policy.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.getTheme().disabledColor,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Already have account?.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.getTheme().disabledColor,
                              ),
                            ),
                            InkWell(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Log in",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.getTheme().primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 24,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getFTButton({bool isFacebook: true}) {
    return Container(
      height: 4,
    );
  }

  Widget appBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: AppBar().preferredSize.height,
          child: Padding(
            padding: EdgeInsets.only(top: 8, left: 8),
            child: Container(
              width: AppBar().preferredSize.height - 8,
              height: AppBar().preferredSize.height - 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 24),
          child: Text(
            "Get Started",
            style: new TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  void register(Map<String, dynamic> _formData) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    FocusScope.of(context).requestFocus(FocusNode());
    print("aaappppiii");
    print(widget.home);
    print(widget.email.trim());
    print(_formData['first_name']);
    Map<String, String> headers = {'Content-Type': 'application/json'};
    final params = jsonEncode({
      'home_airport': widget.selectedHomeAirport.raw,
      'email': widget.email.trim(),
      'password': widget.password,
      'first_name': _formData['first_name'],
      'last_name': _formData['last_name'],
      'promo_code': _formData['promo_code'],
      'zip': _formData['zip'],
      'card_number': _formData['card_number'],
      'expiry': _formData['expiry'],
      'cvc': _formData['cvc'],
      'plan': _formData['plan'],
    });
    
    try {
      http.post(
        'https://joinflyline.com/api/get-started/',
        headers: {'Content-Type': 'application/json'},
        body: params,
      ).then((http.Response response) async {
        var jsonResponse = json.decode(response.body);
        if (response.statusCode == 200) {
          print("A new user has registered successfully.................");
          await flyLinebloc.tryLogin(widget.email.trim(), widget.password);
          Navigator.pushNamedAndRemoveUntil(context, Routes.TabScreen, (Route<dynamic> route) => false);
        }
      });
    } on DioError catch (e) {
      var result = e.response.statusCode.toString();
      print(result);
    } on Error catch (e) {
      print(e);
    }
  }
}
