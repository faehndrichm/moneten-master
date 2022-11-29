import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budget/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitController = TextEditingController();
    limitController.text =
                ref.read(limitProvider).value.toString();

    final textField = TextField(
        style: const TextStyle(fontSize: 28),
        controller: limitController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Limit',
        ),
        onSubmitted: (value) {
          int? limit = int.tryParse(value);
          if (limit != null && limit > 0) {
            ref.read(limitProvider.notifier).setLimit(limit);
            Navigator.pop(context);
          } else {
            limitController.text =
                ref.read(limitProvider).value.toString(); //reset
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 20),
                action: SnackBarAction(
                  label: 'OK',
                  onPressed: () {
                  },
                ),
                content: const Text("Na das geht aber nicht!"),
              ),
            );
          }
        });

    return Scaffold(appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.lightGreen,
        title: Text(
          "Settings",
          style: TextStyle(
              fontFamily: 'Poppins', fontSize: 28, color: Colors.grey.shade700),
        ),
      ), body: Center(child: textField));
  }
}
