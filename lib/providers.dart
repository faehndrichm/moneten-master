import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entities/limit.dart';
import 'entities/cash.dart';
import 'entities/day.dart';
import 'helper.dart';


final cashProvider = StateNotifierProvider<CashNotifier, Cash>((ref) {
  return CashNotifier();
});

final limitProvider = StateNotifierProvider<LimitNotifier, Limit>((ref) {
  return LimitNotifier();
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
 LimitNotifier() : super(Limit(value: 50));

 setLimit(int value) {
  state = Limit(value: value);
 }
}

class CashNotifier extends StateNotifier<Cash> {
  CashNotifier() : super(Cash(cashPerDay: {"2022-11-25": 60, "2022-11-24": 70, "2022-11-23": 80}));

    int getRemainingCashFromPreviousDays(Limit limit, DateTime forDay) {
      int remaining = 0;

      DateTime comparisonDate = forDay.add(const Duration(days: -1));

      var datesBefore = state.cashPerDay.keys.where((element) => DateTime.parse(element).isBefore(comparisonDate));
      for (var day in datesBefore) {
        remaining += limit.value - (state.cashPerDay[day] ?? 0);
      }

      for(int i = 1; i < forDay.day; i++) {
        String dateString = toDateString(DateTime(forDay.year, forDay.month, i));
        if(state.cashPerDay.containsKey(dateString)) {
          continue;
        }
        remaining += limit.value;
      }
      return remaining;
  }

  setState(Cash cash) {
    state = cash;
  }

  addCash(int amount, DateTime forDay) {
    var cashPerDay = state.cashPerDay;
    String key = toDateString(forDay);
    cashPerDay[key] = amount + (cashPerDay[key] ?? 0);
    state = Cash(cashPerDay: cashPerDay);
  }

  removeCash(int amount) {

  }


}
