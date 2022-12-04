import 'dart:async';
import 'dart:ffi';

import 'package:simple_budget/entities/cash.dart';
import 'package:simple_budget/entities/limit.dart';

abstract class SettingsPersistenceInterface {


  void saveLimit(Limit limit) async {}
  Future<Limit> loadLimit() async {
    return Limit(value: 0, beginCountDate: DateTime.now());
  }

  void saveMoneySpent(Cash cash) async {}
  Future<Cash> loadMoneySpent() async {
    return Cash(cashPerDay: {});
  }

}