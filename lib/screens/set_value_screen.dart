import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budget/providers.dart';

import '../helper.dart';

class SetValueScreen extends ConsumerWidget {
  const SetValueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valueController = TextEditingController();
    final currentDate = ref.read(dayProvider).currentDate;

    valueController.text =
        "${ref.read(cashProvider).cashPerDay[toDateString(currentDate)] ?? 0}";

    String selectedDate = toDateStringUI(currentDate);

    final textField = TextField(
        style: const TextStyle(fontSize: 28),
        controller: valueController,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Value for $selectedDate',
        ),
        onSubmitted: (value) {
          double? amount = double.tryParse(value);
          if (amount != null) {
            ref
                .read(cashProvider.notifier)
                .setValue(ref.read(dayProvider).currentDate, amount);
            Navigator.pop(context);
          } else {
            valueController.text =
                ref.read(limitProvider).value.toStringAsFixed(2); //reset
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 20),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {},
                ),
                content: const Text("Na das geht aber nicht!"),
              ),
            );
          }
        });

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.lightGreen,
          title: Text(
            "Daily Spent",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                color: Colors.grey.shade700),
          ),
        ),
        body: Center(child: textField));
  }
}
