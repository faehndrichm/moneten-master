import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_budget/entities/cash.dart';
import 'package:simple_budget/entities/limit.dart';
import 'package:simple_budget/persistence/settings_persistence_interface.dart';

class SettingsPersistenceSharedPrefs implements SettingsPersistenceInterface {
  static const String limitPersistenceName = 'money_limit';
  static const int standardLimit = 50;
  static const String cashPersistenceName = 'cash_per_day';

  @override
  void saveLimit(Limit limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(limitPersistenceName, limit.value);
  }

  @override
  Future<Limit> loadLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return Limit(value: prefs.getInt(limitPersistenceName) ?? standardLimit);
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

    Map<String, int> cashPerDay = {};

    if(cashPerDayJsonized != "") {
      cashPerDay = Map<String, int>.from(const JsonDecoder().convert(cashPerDayJsonized));
    }

    return Cash(cashPerDay: cashPerDay);
  }
}
