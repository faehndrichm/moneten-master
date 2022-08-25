import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cash.dart';
import 'helper.dart';

final cashProvider = StateNotifierProvider<cashNotifier, Cash>((ref) {
  return cashNotifier();
});

class cashNotifier extends StateNotifier<Cash> {
  cashNotifier() : super(Cash(cashPerDay: {"2022-08-25": 60, "2022-08-24": 70, "2022-08-23": 80}));

  setState(Cash cash) {
    state = cash;
  }

  addCash(int amount) {
    var cashPerDay = state.cashPerDay;
    String key = toDateString(DateTime.now());
    cashPerDay[key] = amount + (cashPerDay[key] ?? 0);
    state = Cash(cashPerDay: cashPerDay, limit: state.limit);
  }

  removeCash(int amount) {}

  setLimit(int limit) {
    state = Cash(cashPerDay: state.cashPerDay, limit: limit);
  }
}
