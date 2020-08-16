import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motel/appTheme.dart';
import 'package:motel/modules/login/forgotPassword.dart';
import 'package:motel/network/blocs.dart';

import '../../main.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool isLoggingIn=false;
  bool isCalledOnce=false;

  @override
  void initState() {
    super.initState();

//    passwordController.text = "Mgoblue16!";
//    emailController.text = "zach@joinflyline.com";
    
    flyLinebloc.loginResponse.stream.listen((data) => onLogginResult(data));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        // backgroundColor: AppTheme.getTheme().backgroundColor,
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
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
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
                              SizedBox(
                                width: 16,
                              ),
                              
                              SizedBox(
                                width: 24,
                              )
                            ],
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
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
                            child:Container(
                              height: 48,
                              child: Center(
                                child: TextField(
                              maxLines: 1,
                              onChanged: (String txt) {},
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                fontSize: 16,
                                // color: AppTheme.dark_grey,
                              ),
                              cursorColor: AppTheme.getTheme().primaryColor,
                              decoration: new InputDecoration(
                                errorText: null,
                                border: InputBorder.none,
                                hintText: "Enter your email",
                                hintStyle: TextStyle(color: AppTheme.getTheme().disabledColor),
                              ),),),
                            ),
                          ),
                        ),
                      ),
                      Padding(
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
                                child: TextField(
                                  obscureText: true,
                                  maxLines: 1,
                                  controller: passwordController,
                                  keyboardType: TextInputType.text,
                                  onChanged: (String txt) {},
                                  style: TextStyle(
                                    fontSize: 16,
                                    // color: AppTheme.dark_grey,
                                  ),
                                  cursorColor: AppTheme.getTheme().primaryColor,
                                  decoration: new InputDecoration(
                                    errorText: null,
                                    border: InputBorder.none,
                                    hintText: "Enter your password",
                                    hintStyle: TextStyle(color: AppTheme.getTheme().disabledColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              borderRadius: BorderRadius.all(Radius.circular(1)),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Forgot your password?",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.getTheme().disabledColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 8),
                        child: 
                          isLoggingIn ? 
                            Container(
                              margin: EdgeInsets.only(left: 40.0, right: 40.0, top: 30.0, bottom: 30.0),
                              child: CircularProgressIndicator(
                                    valueColor: new AlwaysStoppedAnimation<Color>(
                                        const Color(0xFF00AFF5)
                                    ),
                                    strokeWidth: 3.0),
                                height: 40.0,
                                width: 40.0,):
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00AFF5),
                            borderRadius: BorderRadius.all(Radius.circular(1)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AppTheme.getTheme().dividerColor,
                                blurRadius: 8,
                                offset: Offset(4, 4),
                              ),
                            ],
                          ),
                          child: 
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.all(Radius.circular(1)),
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    isLoggingIn = true;
                                  });
                                  isCalledOnce = true;
                                  flyLinebloc.tryLogin(emailController.text.toString(), passwordController.text.toString());
                                  // Navigator.pushAndRemoveUntil(context, Routes.SPLASH, (Route<dynamic> route) => false);
                                  // Navigator.pushReplacementNamed(context, Routes.TabScreen);
                                },
                                child: Center(
                                  child: Text(
                                    "Log In",
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getFTButton({bool isFacebook: true}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: HexColor(isFacebook ? "#3C5799" : "#05A9F0"),
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
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
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
          highlightColor: Colors.transparent,
          onTap: () {},
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(isFacebook ? FontAwesomeIcons.facebookF : FontAwesomeIcons.twitter, size: 20, color: Colors.white),
                SizedBox(
                  width: 4,
                ),
                Text(
                  isFacebook ? "Facebook" : "Twitter",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
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
                    Radius.circular(1.0),
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
            "Log In",
            style: new TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  onLogginResult(String data) async {
    print (data);
    if(isCalledOnce){

      if(this.mounted) setState(() {
        isLoggingIn = false;
      });

      if(data != ""){
        Navigator.pushNamedAndRemoveUntil(context, Routes.TabScreen, (Route<dynamic> route) => false);

      }else{

        Flushbar(
            icon : Icon(
              Icons.info_outline,
              size: 28.0,
              color: Colors.blueAccent,
            ),
            messageText : Text("Credentials are incorrect.",
                style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 14.0 )
            ),
            duration : Duration(seconds: 3),
            isDismissible : true
        )..show(context);

      }
    }

  }

}
