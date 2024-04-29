import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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

  static String? formatToYear(DateTime? dateTime, {String locale = 'ru'}) {
    if (dateTime == null) return null;
    return DateFormat.y(locale).format(dateTime);
  }

  void testData() {
    DateTime now = DateTime.now();
    initializeDateFormatting('ru');

    print('Formatted DateTime: ${ToolDateFormatter.formatDateTime(now, "EEE, MMM d HH:mm:ss")}');
    print('Formatted to Locale DateTime: ${ToolDateFormatter.formatToLocaleDateTime(now)}');
    print('Formatted to Time: ${ToolDateFormatter.formatToTime(now)}');
    print('Formatted to Full Date: ${ToolDateFormatter.formatToFullDate(now)}');
    print('Formatted to Short Date: ${ToolDateFormatter.formatToShortDate(now)}');
    print('Formatted to Year: ${ToolDateFormatter.formatToYear(now)}');
    print('Formatted to MonthDay: ${ToolDateFormatter.formatToMonthDay(now)}');
  }
}


