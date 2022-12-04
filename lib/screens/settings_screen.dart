import 'dart:io';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budget/helper.dart';
import 'package:simple_budget/persistence/settings_persistence_json_file.dart';
import 'package:simple_budget/providers.dart';

import '../entities/cash.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsPersistence = SettingsPersistenceJsonFile();

    final limitController = TextEditingController();
    var limit = ref.watch(limitProvider);

    limitController.text = limit.value.toString();

    final dateController = TextEditingController();
    dateController.text = toDateStringUI(limit.beginCountDate);

    final currencyController = TextEditingController();
    currencyController.text = limit.currency;

    void saveExpenditureToFile() async {
      // set up the buttons
      Widget cancelButton = TextButton(
        child: Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
      Widget continueButton = TextButton(
        child: Text("Yes"),
        onPressed: () {
          String saveFile =
              "/storage/emulated/0/Download/MonetenMasterBackup_${DateTime.now().microsecondsSinceEpoch}.txt";
          settingsPersistence.saveMoneySpent(ref.read(cashProvider), saveFile);
          Navigator.of(context).pop();

          ref.read(cashProvider.notifier).resetState();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 20),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
              content: const Text("Removed all Expenditure Entries"),
            ),
          );
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Backup Dialog"),
        content: Text("Would you like to save a backup of your expenditures?"),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    void loadExpenditureFromFile() async {
      const params = OpenFileDialogParams(
          dialogType: OpenFileDialogType.document,
          sourceType: SourceType.photoLibrary);

      final outputFile = await FlutterFileDialog.pickFile(params: params);

      if (outputFile != null) {
        Cash cash = await settingsPersistence.loadMoneySpent(outputFile);
        ref.read(cashProvider.notifier).setState(cash);
      }
    }

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

    final textFieldCurrency = TextField(
        style: const TextStyle(fontSize: 18),
        controller: currencyController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
            icon: Icon(Icons.money), //icon of text field
            labelText: "Enter Currency" //label text of field
            ),
        onTap: () async {
          var result = showCurrencyPicker(
            context: context,
            showFlag: true,
            showCurrencyName: true,
            showCurrencyCode: true,
            onSelect: (Currency currency) {
              currencyController.text = currency.symbol;
              ref.read(limitProvider.notifier).setCurrency(currency.symbol);
            },
          );
        });

    final resetSpentButton = TextButton(
        style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent, backgroundColor: Colors.red),
        onPressed: () => {saveExpenditureToFile()},
        child: const Text('Reset All Days Spent',
            style: TextStyle(fontSize: 18, color: Colors.white)));

    final loadBackupSpentButton = TextButton(
        style: TextButton.styleFrom(
            foregroundColor: Colors.greenAccent, backgroundColor: Colors.green),
        onPressed: () => {
              loadExpenditureFromFile(),
              // ref.read(cashProvider.notifier).resetState(),
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 20),
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {},
                  ),
                  content: const Text("Succesfully loaded Backup Entries."),
                ),
              )
            },
        child: const Text('Load Expenditure Entries from Backup',
            style: TextStyle(fontSize: 18, color: Colors.white)));

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
              textFieldBeginDate,
              const SizedBox(height: 10),
              textFieldCurrency,
              const SizedBox(height: 10),
              resetSpentButton,
              const SizedBox(height: 10),
              loadBackupSpentButton
            ]));
  }
}
