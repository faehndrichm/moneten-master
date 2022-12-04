import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_budget/entities/cash.dart';
import 'package:simple_budget/entities/limit.dart';
import 'package:simple_budget/helper.dart';
import 'package:simple_budget/persistence/settings_persistence_interface.dart';

class SettingsPersistenceJsonFile {
  String backupPath = "";

  void saveMoneySpent(Cash cash, String backupPath) async {

    String toSave = const JsonEncoder().convert(cash.cashPerDay); // TODO jsonize data
    try {
      File returnedFile = File(backupPath);
      await returnedFile.writeAsString(toSave);
    } catch (e) {}
  }

  Future<Cash> loadMoneySpent(String backupPath) async {
    // open json file
    File loadFile = File(backupPath);
    String moneyJsonized = await loadFile.readAsString(encoding: utf8);

    Map<String, double> money = Map<String, double>.from(const JsonDecoder().convert(moneyJsonized));

    return Cash(cashPerDay: money);
  }
}
