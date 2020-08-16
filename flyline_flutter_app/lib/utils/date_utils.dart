///
/// Provides a set of utility functions for converting dates
///
class DateUtils {
  ///
  /// Convert duration in seconds to "XXd XXh XXm" format
  ///
  static String secs2hm(int value) {
    final totalMinutes = (value / 60).floor();
    final minutes = totalMinutes % 60;
    final totalHours = (totalMinutes / 60).floor();
    final hours = totalHours % 24;
    final days = (totalHours / 24).floor();
    final daysPart = (days != 0) ? "${days}d " : "";
    final hoursPart = (hours != 0) ? "${hours}h " : "";
    return "$daysPart$hoursPart${minutes}m";
  }

  static String monthDayFormat(DateTime date) {
    var month = date.month;
    var day = date.day;
    return '$month/$day';
  }
}
