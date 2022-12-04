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

  LimitNotifier() : super(Limit(value: 50));

  setLimit(int value) async {
    state = Limit(value: value);
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

  int getRemainingCashFromPreviousDays(Limit limit, DateTime forDay) {
    int remaining = 0;

    DateTime comparisonDate = forDay.add(const Duration(days: -1));
    // If only current month should be counted then there needs to be a isAfter also
    var datesBefore = state.cashPerDay.keys
        .where((element) => DateTime.parse(element).isBefore(comparisonDate));
    for (var day in datesBefore) {
      remaining += limit.value - (state.cashPerDay[day] ?? 0);
    }

    for (int i = 1; i < forDay.day; i++) {
      String dateString = toDateString(DateTime(forDay.year, forDay.month, i));
      if (state.cashPerDay.containsKey(dateString)) {
        continue;
      }
      remaining += limit.value;
    }
    return remaining;
  }

  setState(Cash cash) {
    state = cash;
    saveCashToStandardPersistence(state);
  }

  addCash(int amount, DateTime forDay) {
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
