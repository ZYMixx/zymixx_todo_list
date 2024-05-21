import 'package:intl/intl.dart';

class ToolDateFormatter {
  static String? formatDateTime(DateTime? dateTime, String format) {
    if (dateTime == null) return null;
    return DateFormat(format).format(dateTime);
  }

  static String? formatToLocaleDateTime(DateTime? dateTime, {String locale = 'ru'}) {
    if (dateTime == null) return null;
    return DateFormat.yMMMMEEEEd(locale).format(dateTime);
  }

  static String? formatToTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    return DateFormat.Hm().format(dateTime);
  }

  static String? formatToFullDate(DateTime? dateTime, {String locale = 'ru'}) {
    if (dateTime == null) return null;
    return DateFormat.yMMMMEEEEd(locale).add_jms().format(dateTime);
  }

  static String? formatToShortDate(DateTime? dateTime, {String locale = 'ru'}) {
    if (dateTime == null) return null;
    return DateFormat.yMd(locale).format(dateTime);
  }

  static String? formatToMonthDay(DateTime? dateTime, {String locale = 'ru'}) {
    if (dateTime == null) return null;
    DateFormat dateFormat = DateFormat("dMMM", 'ru');
    return dateFormat.format(dateTime);
  }

  static String? formatToMonthDayWeek(DateTime? dateTime, {String locale = 'ru'}) {
    if (dateTime == null) return null;
    DateFormat dateFormat = DateFormat("EEE/dd/MMM ", 'ru');
    return dateFormat.format(dateTime);
  }

  static String? formatToYear(DateTime? dateTime, {String locale = 'ru'}) {
    if (dateTime == null) return null;
    return DateFormat.y(locale).format(dateTime);
  }
}


