import 'package:logger/logger.dart';

class LoggerUtils {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2,
        // number of method calls to be displayed
        errorMethodCount: 8,
        // number of method calls if stacktrace is provided
        lineLength: 120,
        // width of the output
        colors: true,
        // Colorful log messages
        printEmojis: true,
        // Print an emoji for each log message
        printTime: false // Should each log print contain a timestamp
        ),
  );

  static void d(dynamic data) {
    _logger.d(data);
  }

  static void i(dynamic data) {
    _logger.i(data);
  }

  static void e(dynamic data) {
    _logger.e(data);
  }
}
