import 'package:logger/logger.dart';

class Log {
  static Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  //Debug log
  static d(dynamic text) {
    logger.d(text.toString());
  }

  static v(dynamic text) {
    logger.v(text.toString());
  }

  //Info log
  static i(dynamic text) {
    logger.i(text.toString());
  }

  //Warning log
  static w(dynamic text) {
    logger.w(text.toString());
  }

  //Error log
  static e(dynamic text) {
    logger.e(text.toString());
  }
}
