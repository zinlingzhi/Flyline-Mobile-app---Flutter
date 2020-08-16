import 'package:uuid/uuid.dart';

class CheckFlightResponse {
  Baggage baggage;
  bool flightsChecked;
  bool flightsInvalid;
  Conversion conversion;
  double total;

  CheckFlightResponse(this.baggage, this.flightsChecked, this.flightsInvalid, this.total);
  CheckFlightResponse.fromJson(Map<String, dynamic> json)
      : baggage = Baggage.fromJson(json['baggage']),
        flightsChecked = json['flights_checked'],
        flightsInvalid = json['flights_invalid'],
        conversion = Conversion.fromJson(json['conversion']),
        total = double.parse(json['total'].toString());

  bool get noAvailableForBooking => this.flightsInvalid;
}

class Baggage {
  BaggageItem combinations;
  BaggageItem definitions;

  Baggage(this.combinations, this.definitions);

  Baggage.fromJson(Map<String, dynamic> json)
      : combinations = BaggageItem.fromJson(json['combinations']),
        definitions = BaggageItem.fromJson(json['definitions']);
}

class Conversion {
  String currency;
  double amount;

  Conversion(this.currency, this.amount);

  factory Conversion.fromJson(Map<String, dynamic> json) {
    return Conversion(json['currency'], double.parse(json['amount'].toString()));
  }
}

class BaggageItem {
  List<BagItem> handBag;
  List<BagItem> holdBag;

  BaggageItem(this.handBag, this.holdBag);

  factory BaggageItem.fromJson(Map<String, dynamic> json) {
    var handBag = (json['hand_bag'] as List).map((i) => BagItem.fromJson(i)).toList();
    var holdBag = (json['hold_bag'] as List).map((i) => BagItem.fromJson(i)).toList();

    return BaggageItem(handBag, holdBag);
  }

}

class BagItem {
  String category;
  Conditions conditions;
  List<dynamic> indices;
  Price price;
  String uuid;

  BagItem(String category, Conditions conditions, List<dynamic> indices, Price price) {
    this.category = category;
    this.conditions = conditions;
    this.indices = indices;
    this.price = price;

    var uuid = new Uuid();
    this.uuid = uuid.v4();
  }

  BagItem.fromJson(Map<String, dynamic> json)
      : category = json['category'],
        conditions = Conditions.fromJson(json['conditions']),
        indices = json['indices'],
        price = Price.fromJson(json['price']),
        uuid = Uuid().v4();

  Map get jsonSerialize => {
      "category": this.category,
      "conditions": this.conditions.jsonSerialize,
      "indices": this.indices,
      "price": this.price.jsonSerialize,
  };
}

class Conditions {
  List<dynamic> passengerGroups;

  Conditions(this.passengerGroups);

  Conditions.fromJson(Map<String, dynamic> json)
      : passengerGroups = json['passenger_groups'];

  Map get jsonSerialize => {
    "passenger_groups": this.passengerGroups
  };
}

class Price {
  double amount;
  double base;
  String currency;
  int merchant;
  double service;
  int serviceFlat;

  Price(this.amount, this.base, this.currency, this.merchant, this.service,
      this.serviceFlat);

  Price.fromJson(Map<String, dynamic> json)
      : amount = double.parse(json['amount'].toString()),
        base = double.parse(json['base'].toString()),
        currency = json['currency'],
        merchant = json['merchant'],
        service = double.parse(json['service'].toString()),
        serviceFlat = json['service_flat'];

  Map get jsonSerialize => {
    "amount": this.amount,
    "base": this.base,
    "currency": this.currency,
    "merchant": this.merchant,
    "service": this.service,
    "service_flat": this.serviceFlat ?? "None"
  };
}
