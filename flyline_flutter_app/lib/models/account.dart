class Account {
  String firstName;
  String lastName;
  String email;
  Market market;
  String gender;
  String phoneNumber;
  String dob;
  String tsaPrecheckNumber;
  String passportNumber;

  Account(
      String firstName,
      String lastName,
      String email,
      Market market,
      String gender,
      String phoneNumber,
      String dob,
      String tsaPrecheckNumber,
      String passportNumber) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
    this.market = market;
    this.gender = gender;
    this.phoneNumber = phoneNumber;
    this.dob = dob;
    this.tsaPrecheckNumber = tsaPrecheckNumber;
    this.passportNumber = passportNumber;
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        json['first_name'],
        json['last_name'],
        json['email'],
        Market.fromJson(json['market']),
        json['gender'].toString(),
        json['phone_number'],
        json['dob'],
        json['tsa_precheck_number'],
        json['passport_number']);
  }

  List get jsonSerialize {
    return [
      {},
      {
        "key": 'First Name',
        "value": this.firstName,
      },
      {
        "key": 'Last Name',
        "value": this.lastName,
      },
      {
        "key": "Date of birth",
        "value": this.dob ?? "",
      },
      {
        "key": 'Gender',
        "value": this.gender ?? "0",
      },
      {
        "key": 'Email address',
        "value": this.email ?? "",
      },
      {
        "key": 'Phone Number',
        "value": this.phoneNumber ?? "",
      },
      {
        "key": 'Passport Number',
        "value": this.passportNumber ?? "",
      },
      {
        "key": 'KnownTraveler Number',
        "value": this.tsaPrecheckNumber ?? "",
      },
    ];
  }
}

class Market {
  String code;
  Country country;
  String name;
  Subdivision subdivision;
  String type;

  Market(String code, Country country, String name, Subdivision subdivision,
      String type) {
    this.code = code;
    this.country = country;
    this.name = name;
    this.subdivision = subdivision;
    this.type = type;
  }

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(json['code'], Country.fromJson(json['country']), json['name'],
        Subdivision.fromJson(json['subdivision']), json['type']);
  }
}

class Country {
  String code;

  Country(String code) {
    this.code = code;
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(json['code']);
  }
}

class Subdivision {
  String name;
  Subdivision(String name) {
    this.name = name;
  }

  factory Subdivision.fromJson(Map<String, dynamic> json) {
    return Subdivision(json['name']);
  }
}
