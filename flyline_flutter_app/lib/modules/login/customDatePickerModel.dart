import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CustomDatePickerModel extends DatePickerModel {
  CustomDatePickerModel(
      {DateTime currentTime,
      DateTime maxTime,
      DateTime minTime,
      LocaleType locale})
      : super(
            currentTime: currentTime,
            maxTime: maxTime,
            minTime: minTime,
            locale: locale) {

    this.rightList = List();
  }

  @override
  List<int> layoutProportions() {
      return [1, 1, 0];
  }
}
