import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entities/limit.dart';
import 'entities/cash.dart';
import 'helper.dart';

final cashProvider = StateNotifierProvider<CashNotifier, Cash>((ref) {
  return CashNotifier();
});

final limitProvider = StateNotifierProvider<LimitNotifier, Limit>((ref) {
  return LimitNotifier();
});

class LimitNotifier extends StateNotifier<Limit> {
 LimitNotifier() : super(Limit(value: 50));

 setLimit(int value) {
  state = Limit(value: value);
 }
}

class CashNotifier extends StateNotifier<Cash> {
  CashNotifier() : super(Cash(cashPerDay: {"2022-08-25": 60, "2022-08-24": 70, "2022-08-23": 80}));

  setState(Cash cash) {
    state = cash;
  }

  addCash(int amount) {
    var cashPerDay = state.cashPerDay;
    String key = toDateString(DateTime.now());
    cashPerDay[key] = amount + (cashPerDay[key] ?? 0);
    state = Cash(cashPerDay: cashPerDay);
  }

  removeCash(int amount) {}
}
