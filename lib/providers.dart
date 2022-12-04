import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_budget/persistence/settings_persistence.dart';
import 'package:simple_budget/persistence/settings_persistence_interface.dart';

import 'entities/limit.dart';
import 'entities/cash.dart';
import 'entities/day.dart';
import 'helper.dart';

bool firstCashStart = true;
bool firstLimitStart = true;

final cashProvider = StateNotifierProvider<CashNotifier, Cash>((ref) {
  var ret = CashNotifier();
  if (firstCashStart) {
    ret.loadCashFromStandardPersistence();
    firstCashStart = false;
  }
  return ret;
});

final limitProvider = StateNotifierProvider<LimitNotifier, Limit>((ref) {
  var ret = LimitNotifier();
  if (firstLimitStart) {
    ret.loadLimitFromStandardPersistence();
    firstLimitStart = false;
  }
  return ret;
});

final dayProvider = StateNotifierProvider<DayNotifier, Day>((ref) {
  return DayNotifier();
});

class DayNotifier extends StateNotifier<Day> {
  DayNotifier() : super(Day(currentDate: DateTime.now()));

  setCurrentDay(DateTime currentDate) {
    state.currentDate = currentDate;
  }

  getCurrentDay() {
    return state.currentDate;
  }
}

class LimitNotifier extends StateNotifier<Limit> {
  SettingsPersistenceInterface standardPersistenceInterface =
      SettingsPersistenceSharedPrefs();

  LimitNotifier() : super(Limit(value: 50, beginCountDate: DateTime.now(), currency:"€"));

  setLimit(double value, DateTime beginCountDate) {
    state = Limit(value: value, beginCountDate: beginCountDate, currency: state.currency);
    saveLimitToStandardPersistence(state);
  }

  setStartDate(DateTime startDate) {
    state = Limit(value: state.value, beginCountDate: startDate, currency: state.currency);
    saveLimitToStandardPersistence(state);
  }

  setLimitValue(double value) {
    state = Limit(value: value, beginCountDate: state.beginCountDate, currency: state.currency);
    saveLimitToStandardPersistence(state);
  }

  setCurrency(String currency) {
    state = Limit(value: state.value, beginCountDate: state.beginCountDate, currency: currency);
    saveLimitToStandardPersistence(state);
  }

  saveLimitToStandardPersistence(Limit limit) async {
    await saveLimitToPersistence(standardPersistenceInterface, limit);
  }

  saveLimitToPersistence(
      SettingsPersistenceInterface persistenceInterface, Limit limit) async {
    persistenceInterface.saveLimit(limit);
  }

  loadLimitFromStandardPersistence() async {
    await loadLimitFromPersistence(standardPersistenceInterface);
  }

  loadLimitFromPersistence(
      SettingsPersistenceInterface persistenceInterface) async {
    state = await persistenceInterface.loadLimit();
  }
}

class CashNotifier extends StateNotifier<Cash> {
  SettingsPersistenceInterface standardPersistenceInterface =
      SettingsPersistenceSharedPrefs();

  CashNotifier() : super(Cash(cashPerDay: {}));

  double getRemainingCashFromPreviousDays(Limit limit, DateTime forDay) {
    double remaining = 0;

    DateTime comparisonDate = forDay.add(const Duration(days: -1));
    DateTime startDate = limit.beginCountDate;

    // If only current month should be counted then there needs to be a isAfter also
    var datesBefore = state.cashPerDay.keys
        .where((element) => DateTime.parse(element).isBefore(comparisonDate) && DateTime.parse(element).isAfter(startDate.add(const Duration(days: -1))));

    for (var day in datesBefore) {
      remaining += limit.value - (state.cashPerDay[day] ?? 0);
    }

    List<DateTime> days = [];
    for (int i = 0; i <= forDay.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }

    // Go through all days from the begin date to the searched for day and add the remainder 
    // for all days not already included before
    for(DateTime day in days) {
      String dateString = toDateString(day);
      if (state.cashPerDay.containsKey(dateString)) {
        continue;
      }
      remaining += limit.value;
    }

    return remaining;
  }

  setValue(DateTime date, double amount) {
    Cash temp = Cash(cashPerDay: state.cashPerDay);
    temp.cashPerDay[toDateString(date)] = amount;
    setState(temp);
  }

  setState(Cash cash) {
    state = cash;
    saveCashToStandardPersistence(state);
  }

  addCash(double amount, DateTime forDay) {
    var cashPerDay = state.cashPerDay;
    String key = toDateString(forDay);
    cashPerDay[key] = amount + (cashPerDay[key] ?? 0);
    state = Cash(cashPerDay: cashPerDay);
    saveCashToStandardPersistence(state);
  }

  removeCash(int amount, DateTime forDay) {
    saveCashToStandardPersistence(state);
  }

  saveCashToStandardPersistence(Cash cash) async {
    await saveCashToPersistence(standardPersistenceInterface, cash);
  }

  saveCashToPersistence(
      SettingsPersistenceInterface persistenceInterface, Cash cash) async {
    persistenceInterface.saveMoneySpent(cash);
  }

  loadCashFromStandardPersistence() async {
    await loadCashFromPersistence(standardPersistenceInterface);
  }

  loadCashFromPersistence(
      SettingsPersistenceInterface persistenceInterface) async {
    state = await persistenceInterface.loadMoneySpent();
  }
}
