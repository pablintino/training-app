import 'package:tuple/tuple.dart';

class ConversionUtils {
  static Tuple3<int, int, int> secondsToSecMinHours(int seconds) {
    final hours = seconds ~/ 3600;
    final tmp = seconds.remainder(3600);
    final mins = tmp ~/ 60;
    final secs = tmp.remainder(60);

    return Tuple3(secs, mins, hours);
  }

  static String secondsTimeToPrettyString(int seconds) {
    final conversion = secondsToSecMinHours(seconds);
    var result = '';
    if (conversion.item3 != 0) {
      result = '${conversion.item3}h';
    }

    if (conversion.item2 != 0) {
      result = '$result ${conversion.item2}\'';
    }

    if (conversion.item1 != 0) {
      result = '$result ${conversion.item1}\'\'';
    }

    return result.trim();
  }
}
