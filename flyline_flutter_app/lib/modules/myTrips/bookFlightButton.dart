import 'package:flutter/material.dart';
import 'package:motel/modules/hotelBooking/hotelHomeScreen.dart';

class BookFlightButton extends StatelessWidget {
  const BookFlightButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Container(
          margin: EdgeInsets.only(left: 16.0, right: 16, top: 2, bottom: 12),
          color: Colors.lightBlue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text("Book a Flight",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 19.0,
                        fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HotelHomeScreen(),
                        fullscreenDialog: true),
                  );
                },
              ),
            ],
          ),
        ));
  }
}
