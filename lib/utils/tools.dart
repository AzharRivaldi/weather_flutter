import 'package:intl/intl.dart';

class SetTime {
  static String setTime(String strDate) {
    var inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    var inputDate = inputFormat.parse(strDate);
    var outputFormat = DateFormat("HH:mm");
    var outputDate = outputFormat.format(inputDate);

    return outputDate;
  }
}

String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('EEEE\nd MMM yy');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0
      || diff.inSeconds > 0 && diff.inMinutes == 0
      || diff.inMinutes > 0 && diff.inHours == 0
      || diff.inHours > 0 && diff.inDays == 0) {
    time = format.format(date);
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    if (diff.inDays == 1) {
      time = '${diff.inDays} DAY AGO';
    } else {
      time = '${diff.inDays} DAYS AGO';
    }
  } else {
    if (diff.inDays == 7) {
      time = '${(diff.inDays / 7).floor()} WEEK AGO';
    } else {

      time = '${(diff.inDays / 7).floor()} WEEKS AGO';
    }
  }

  return time;
}