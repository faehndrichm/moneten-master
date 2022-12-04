import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budget/helper.dart';
import 'package:simple_budget/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitController = TextEditingController();
    var limit = ref.watch(limitProvider);

    limitController.text = limit.value.toString();

    final dateController = TextEditingController();
    dateController.text = toDateStringUI(limit.beginCountDate);

    final textField = TextField(
        style: const TextStyle(fontSize: 18),
        controller: limitController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Limit',
        ),
        onSubmitted: (value) {
          double? limit = double.tryParse(value);
          if (limit != null && limit > 0) {
            ref.read(limitProvider.notifier).setLimitValue(limit);
            Navigator.pop(context);
          } else {
            limitController.text =
                ref.read(limitProvider).value.toString(); //reset
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

    final textFieldBeginDate = TextField(
        style: const TextStyle(fontSize: 18),
        controller: dateController, //editing controller of this TextField
        decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today), //icon of text field
            labelText: "Enter Date" //label text of field
            ),
        readOnly: true, // when true user cannot edit text
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: limit.beginCountDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now());

          if (pickedDate != null) {
            dateController.text = toDateStringUI(pickedDate);
            ref.read(limitProvider.notifier).setStartDate(pickedDate);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 20),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {},
                ),
                content: const Text("No date was selected"),
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
            "Settings",
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                color: Colors.grey.shade700),
          ),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 50,
              ),
              textField,
              const SizedBox(height: 10),
              textFieldBeginDate
            ]));
  }
}
