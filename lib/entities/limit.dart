import 'dart:ffi';

class Limit {
  double value;
  // The date from which the current values should be calculated
  DateTime beginCountDate;
  Limit({required this.value, required this.beginCountDate}); 
}