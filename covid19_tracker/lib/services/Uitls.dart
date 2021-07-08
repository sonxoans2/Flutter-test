import 'package:intl/intl.dart';

class Utils {
  static String formatNumber(int count) {
    return NumberFormat.decimalPattern('en-US').format(count);
  }

  static callNative() {}
}
