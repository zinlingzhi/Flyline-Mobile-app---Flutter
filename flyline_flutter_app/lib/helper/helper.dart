import 'package:intl/intl.dart';

class Helper {
  static getDateViaString(String date, String format) {
    DateTime d = DateTime.parse(date);
    var formatter = new DateFormat(format);
    return formatter.format(d);
  }

  static getDateViaDate(DateTime date, String format) {
    var formatter = new DateFormat(format);
    return formatter.format(date);
  }

  static duration(Duration duration) {
    List<String> d = List();
    if (duration.inDays != 0) {
      d.add(duration.inDays.toString() + "d");
    }

    if (duration.inHours != 0) {
      d.add(duration.inHours.remainder(60).toString() + "h");
    }

    if (duration.inMinutes != 0) {
      d.add(duration.inMinutes.remainder(60).toString() + "m");
    }

    return d.join(" ");
  }

  static cost(double total, double conversationAmount, double amount) {
    if (amount == 0) {
      return " \$0.00";
    }

    double price = (conversationAmount / total) * amount;
    var f = new NumberFormat("###.00", "en_US");
    return " \$" + f.format(price);
  }

  static costNumber(double total, double conversationAmount, double amount) {
    if (amount == 0) {
      return 0.00;
    }

    double price = (conversationAmount / total) * amount;
    return price;
  }

  static getCostNumber(double total, double conversationAmount, double amount) {
    if (amount == 0) {
      return amount;
    }

    return (conversationAmount / total) * amount;
  }

  static formatNumber(double number) {
    if (number == 0) {
      return " \$0.00";
    }

    var f = new NumberFormat("###.00", "en_US");
    return " \$" + f.format(number);
  }

  static age(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
}
