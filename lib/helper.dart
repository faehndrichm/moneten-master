import 'package:intl/intl.dart';
// TODO convert to extension 

String toDateString(DateTime date) {
  final f = DateFormat('yyyy-MM-dd');
  return f.format(date);
}

String toDateStringUI(DateTime date) {
  final f = DateFormat('dd.MM.yyyy');
  return f.format(date);
}

DateTime fromDateString(String date) {
  return DateTime.parse(date);
}
