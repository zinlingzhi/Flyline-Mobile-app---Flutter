import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:motel/appTheme.dart';
import 'package:motel/models/account.dart';
import 'package:motel/models/settingListData.dart';
import 'package:motel/network/blocs.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  List<SettingsListData> userInfoList = SettingsListData.userInfoList;
  Account account;
  TextEditingController firstNameController;
  TextEditingController lastNameController;
  TextEditingController dobController;
  TextEditingController genderController;
  TextEditingController emailController;
  TextEditingController phoneController;
  TextEditingController passportController;
  TextEditingController tempController;

  static var genders = [
    "Unselected",
    "Male",
    "Female",
  ];
  static var genderValues = ["1", "0", "1"];

  var selectedGender = genders[0];
  var selectedGenderValue = genderValues[0];

  void getAccountInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Country country = Country(prefs.getString('market.country.code'));
    Subdivision subdivision =
        Subdivision(prefs.getString('market.subdivision.name'));
    Market market = Market(
        prefs.getString('market.code'),
        country,
        prefs.getString('market.name'),
        subdivision,
        prefs.getString('market.type'));

    setState(() {
      account = Account(
        prefs.getString('first_name'),
        prefs.getString('last_name'),
        prefs.getString('email'),
        market,
        prefs.getString('gender'),
        prefs.getString('phone_number'),
        prefs.getString('dob'),
        prefs.getString('tsa_precheck_number'),
        prefs.getString('passport_number'),
      );

      firstNameController = TextEditingController();
      lastNameController = TextEditingController();
      dobController = TextEditingController();
      genderController = TextEditingController();
      emailController = TextEditingController();
      phoneController = TextEditingController();
      passportController = TextEditingController();
      var index = 0;
      account.jsonSerialize.forEach((v) {
        switch (index) {
          case 1:
            firstNameController.text = v['value'];
            break;
          case 2:
            lastNameController.text = v['value'];
            break;
          case 3:
            dobController.text = v['value'];
            break;
          case 4:
            if (v['value'].toString() != 'null') {
              genderController.text = int.parse(v['value']) == 0 ? 'Male' : 'Female';
            } else {
              genderController.text = 'Male';
            }
            break;
          case 5:
            emailController.text = v['value'];
            break;
          case 6:
            phoneController.text = v['value'];
            break;
          case 7:
            passportController.text = v['value'];
            break;
          default:
            break;
        }

        index++;
      });
    });
  }

  TextEditingController getController(int index) {
    switch (index) {
      case 1:
        return firstNameController;
      case 2:
        return lastNameController;
      case 3:
        return dobController;
      case 4:
        return genderController;
      case 5:
        return emailController;
      case 6:
        return phoneController;
      case 7:
        return passportController;
      default:
        return tempController;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    this.getAccountInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: AppTheme.getTheme().backgroundColor,
        body: InkWell(
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
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top, bottom: 16),
                child: appBar(),
              ),
             Expanded(
               flex: 3,
               child: ListView.builder(
                 primary: false,
                 padding: EdgeInsets.only(
                     bottom: 16 + MediaQuery.of(context).padding.bottom),
                 itemCount: account != null ? account.jsonSerialize.length : 0,
                 itemBuilder: (context, index) {
                   return index == 0
                       ? getProfileUI()
                       : InkWell(
                     onTap: () {},
                     child: Column(
                       children: <Widget>[
                         Padding(
                           padding:
                           const EdgeInsets.only(left: 8, right: 16),
                           child: Row(
                             children: <Widget>[
                               Expanded(
                                 child: Padding(
                                   padding: const EdgeInsets.only(
                                       left: 16.0, bottom: 16, top: 16),
                                   child: Text(
                                     account.jsonSerialize[index]['key'],
                                     style: TextStyle(
                                       fontWeight: FontWeight.w500,
                                       fontSize: 16,
                                       color: AppTheme.getTheme()
                                           .disabledColor
                                           .withOpacity(0.3),
                                     ),
                                   ),
                                 ),
                               ),
                               Expanded(
                                 child: Padding(
                                   padding: const EdgeInsets.only(
                                       right: 16.0, bottom: 1, top: 1),
                                   child: Container(
                                     child: TextField(
                                       onTap: () async {
                                         if (index == 3) {
                                           DatePicker.showDatePicker(context,
                                               showTitleActions: true,
                                               minTime: DateTime(1960, 1, 1),
                                               maxTime: DateTime.now(), onChanged: (date) {
                                                 print('change $date');
                                               }, onConfirm: (date) {
                                                 var formatter = new DateFormat('yyyy-MM-dd');
                                                 dobController.text = formatter.format(date);
                                               }, currentTime: DateTime.now(), locale: LocaleType.en);
                                         } else if (index == 4) {
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
                                           genders.forEach((item) {
                                             items.add(Container(
                                                 margin: const EdgeInsets.only(
                                                     left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
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
                                                       selectedGender = item;
                                                       selectedGenderValue =
                                                       genderValues[genders.indexOf(item)];
                                                       genderController.text = selectedGender;
                                                     });
                                                   },
                                                   child: Text(item),
                                                 )));
                                           });
                                           await showDialog(
                                               context: context,
                                               builder: (BuildContext context) {
                                                 return SimpleDialog(
                                                   title: const Text('Select Gender'),
                                                   children: items,
                                                 );
                                               });
                                         }
                                       },
                                       readOnly: (index == 3 || index == 4),
                                       maxLines: 1,
                                       onChanged: (String txt) {},
                                       controller: getController(index),
                                       keyboardType: TextInputType.text,
                                       style: TextStyle(
                                         fontSize: 16,
                                         // color: AppTheme.dark_grey,
                                       ),
                                       cursorColor: AppTheme.getTheme()
                                           .primaryColor,
                                       decoration: new InputDecoration(
                                         errorText: null,
                                         border: InputBorder.none,
                                       ),
                                     ),
                                   ),
                                 ),
                               )
                             ],
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.only(
                               left: 16, right: 16),
                           child: Divider(
                             height: 1,
                           ),
                         )
                       ],
                     ),
                   );
                 },
               ),
             ),
              Expanded(
                flex: 1,
                  child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16.0, right: 16, top: 10),
                    color: Colors.lightBlue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Text("Save",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.bold)),
                          onPressed: () {
                            if (genderController.text == "Unselected") {
                              return;
                            }

                            flyLinebloc.updateAccountInfo(
                              firstNameController.text,
                              lastNameController.text,
                              dobController.text,
                              genderController.text,
                              emailController.text,
                              phoneController.text,
                              passportController.text,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget getProfileUI() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 130,
            height: 0,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[],
            ),
          )
        ],
      ),
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
            "Edit Traveler Information",
            style: new TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
