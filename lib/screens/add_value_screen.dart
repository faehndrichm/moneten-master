import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budget/providers.dart';

import '../helper.dart';

class AddValueScreen extends ConsumerWidget {
  const AddValueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valueController = TextEditingController();
    final currentDate = ref.read(dayProvider).currentDate;

    valueController.text = "";

    String selectedDate = toDateStringUI(currentDate);

    final textField = TextField(
        style: const TextStyle(fontSize: 28),
        controller: valueController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Cash to add for $selectedDate',
        ),
        onSubmitted: (value) {
          int? amount = int.tryParse(value);
          if (amount != null) {
            ref
                .read(cashProvider.notifier)
                .addCash(amount, ref.read(dayProvider).currentDate);
            Navigator.pop(context);
          } else {
            valueController.text = ""; //reset
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
            "Add Expenditure",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                color: Colors.grey.shade700),
          ),
        ),
        body: Center(child: textField));
  }
}
