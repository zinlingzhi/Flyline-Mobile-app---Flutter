import 'package:motel/models/checkFlightResponse.dart';

class BookRequest {
  Baggage baggage;
  String currency;
  String lang;
  String locale;
  String paymentGateway;
  Payment payment;
  List<Passenger> passengers;
  Map<String, dynamic> retailInfo;
  String bookingToken;

  static const String DEFAULT_CURRENCY = 'usd';
  static const String DEFAULT_LANG = 'en';
  static const String DEFAULT_LOCALE = 'en';
  static const String DEFAULT_PAYMENT_GATEWAY = 'payu';

  BookRequest(
      this.baggage,
      this.currency,
      this.lang,
      this.locale,
      this.paymentGateway,
      this.payment,
      this.passengers,
      this.retailInfo,
      this.bookingToken);

  Map get jsonSerialize {
    List<Map> lists = List();
    this.passengers.forEach((p) {
      lists.add(p.jsonSerialize);
    });
    return {
      "booking_token": this.bookingToken,
      "baggage": this.baggage.jsonSerialize,
      "currency": this.currency,
      "lang": this.lang,
      "locale": this.locale,
      "payment_gateway": this.paymentGateway,
      "payment": this.payment.jsonSerializeHardCode,
      "passengers": lists,
      "retail_info": this.retailInfo,
    };
  }
}

class Payment {
  String cartNumber;
  String creditCartCVV;
  String email;
  String expiry;
  String holderName;
  String phone;
  String promoCode;

  Payment(this.cartNumber, this.creditCartCVV, this.email, this.expiry,
      this.holderName, this.phone, this.promoCode);

  Map get jsonSerialize => {
        "card_number": this.cartNumber,
        "credit_card_cvv": this.creditCartCVV,
        "email": this.email,
        "expiry": this.expiry,
        "holder_name": this.holderName,
        "phone": this.phone,
        "promocode": this.promoCode
      };

  Map get jsonSerializeHardCode => {
        "card_number": "4242424242424242",
        "credit_card_cvv": "123",
        "email": "leotrubach@gmail.com",
        "expiry": "11/21",
        "holder_name": "LEV TRUBACH",
        "phone": "+77774483022",
        "promocode": ""
      };
}

class Baggage {
  List<BaggageItem> items;

  Baggage(this.items);

  void add(BaggageItem item) {
    this.items.add(item);
  }

  List<Map> get jsonSerialize {
    List<Map> lists = List();
    this.items.forEach((i) {
      lists.add(i.jsonSerialize);
    });
    return lists;
  }
}

class BaggageItem {
  Combination combination;
  List<int> passengers;
  BaggageItem(this.combination, this.passengers);

  Map get jsonSerialize =>
      {"combination": this.combination.jsonSerialize, "passengers": passengers};
}

class Combination {
  BagItem item;

  Combination(this.item);

  Map get jsonSerialize => item.jsonSerialize;
}

class Passenger {
  DateTime birthday;
  String cardno;
  String category;
  String expiration;
  String name;
  String nationality;
  String surname;
  String title;

  Passenger(this.birthday, this.cardno, this.category, this.expiration,
      this.name, this.nationality, this.surname, this.title);

  Map get jsonSerialize => {
        "birthday": birthday.toIso8601String(), // "2001-08-11T17:00:00.000Z"
        "cardno": this.cardno,
        "category": this.category,
        "expiration": this.expiration,
        "name": this.name,
        "nationality": this.nationality,
        "surname": this.surname,
        "title": this.title
      };
}
