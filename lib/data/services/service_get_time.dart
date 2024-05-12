import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

//flutter pub add intl

class ServiceGetTime {
  Stream<bool> secTickStream;
  Stream<String> dataTimeNowStream;

  ServiceGetTime()
      : secTickStream = _getSecTickStream().asBroadcastStream(),
        dataTimeNowStream = _getNowTimeStream();

  static Stream<bool> _getSecTickStream() async* {
    while (true) {
      await Future.delayed(Duration(milliseconds: 1000));
      yield true;
    }
  }

  static Stream<String> _getNowTimeStream() async* {
    print(DateFormat.allLocalesWithSymbols());
    while (true) {
      await Future.delayed(Duration(milliseconds: 1000));
      DateFormat dateFormat = DateFormat("EEE, MMM d HH:mm:ss", 'ru');
      var timeNow = DateTime.now();
      String dateTime = dateFormat.format(timeNow);
      yield dateTime;
    }
  }
}
