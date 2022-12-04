import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_budget/entities/cash.dart';
import 'package:simple_budget/entities/limit.dart';
import 'package:simple_budget/helper.dart';
import 'package:simple_budget/persistence/settings_persistence_interface.dart';

class SettingsPersistenceSharedPrefs implements SettingsPersistenceInterface {
  static const String limitPersistenceName = 'money_limit';
  static const String beginCountDatePersistenceName = 'begin_count_date';
  static const double standardLimit = 50;
  static const String cashPersistenceName = 'cash_per_day';

  @override
  void saveLimit(Limit limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(limitPersistenceName, limit.value);
    await prefs.setString(beginCountDatePersistenceName, toDateString(limit.beginCountDate));
  }

  @override
  Future<Limit> loadLimit() async {
    final prefs = await SharedPreferences.getInstance();
    
    Limit ret = Limit(value: standardLimit, beginCountDate: DateTime.now());

    try {
      
      String date = prefs.getString(beginCountDatePersistenceName) ?? "";

      ret = Limit(value: prefs.getDouble(limitPersistenceName) ?? standardLimit, beginCountDate: fromDateString(date));
    }
    catch(_) {
     // do nothing 
    }

    return ret;
  }

  @override
  void saveMoneySpent(Cash cash) async {
    final prefs = await SharedPreferences.getInstance();

    String cashPerDayJsonized = const JsonEncoder().convert(cash.cashPerDay);
    await prefs.setString(cashPersistenceName, cashPerDayJsonized);
  }

  @override
  Future<Cash> loadMoneySpent() async {
    final prefs = await SharedPreferences.getInstance();
    String cashPerDayJsonized = prefs.getString(cashPersistenceName) ?? "";

    Map<String, double> cashPerDay = {};

    if(cashPerDayJsonized != "") {
      try {
        cashPerDay = Map<String, double>.from(const JsonDecoder().convert(cashPerDayJsonized));
      }
      catch (_) {
        cashPerDay = {};
      }
    }

    return Cash(cashPerDay: cashPerDay);
  }
}
