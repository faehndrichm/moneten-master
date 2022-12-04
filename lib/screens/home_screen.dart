import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:simple_budget/entities/day.dart';
import 'package:simple_budget/providers.dart';
import 'package:simple_budget/screens/add_value_screen.dart';
import 'package:simple_budget/screens/set_value_screen.dart';
import 'package:simple_budget/screens/settings_screen.dart';
import '../helper.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// TODO set currency


// TODO implement month selection

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final limitController = TextEditingController();
  final pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    var cash = ref.watch(cashProvider);
    var dailyLimit = ref.watch(limitProvider);

    limitController.text = dailyLimit.value.toString();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.lightGreen,
        title: Text(
          widget.title,
          style: TextStyle(
              fontFamily: 'Poppins', fontSize: 28, color: Colors.grey.shade700),
        ),
      ),
      drawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(padding: EdgeInsets.zero, children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Moneten Master'),
            ),
            ListTile(
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Update the state of the app
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                  // Then close the drawer
                })
          ])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: PageView.builder(
            controller: pageViewController,
            reverse: true,
            itemBuilder: (BuildContext context, int index) {
              DateTime selectedDate =
                  DateTime.now().add(Duration(days: -index));
              double spentToday = cash.cashPerDay[toDateString(selectedDate)] ?? 0;
              int currentDayOfMonth = selectedDate.day;

              double limit = dailyLimit.value +
                  ref
                      .read(cashProvider.notifier)
                      .getRemainingCashFromPreviousDays(
                          dailyLimit, selectedDate);
              double progressLimit = limit >= 0 ? limit : 0;
              double progressIndicatorValue =
                  progressLimit > 0 ? (spentToday / progressLimit) : 100;

              Color progressIndicatorColor = Colors.lightGreen;

              if (spentToday > limit) {
                progressIndicatorColor = Colors.red;
              }

              ref.read(dayProvider.notifier).setCurrentDay(selectedDate);

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (!selectedDate.isAfter(ref.read(limitProvider).beginCountDate.add(Duration(days: 1))))
                            const SizedBox(
                              width: 64,
                            ),
                          if (selectedDate.isAfter(ref.read(limitProvider).beginCountDate.add(Duration(days: 1))))
                            IconButton(
                              onPressed: () {
                                pageViewController.animateToPage(index + 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut);
                              },
                              icon: HeroIcon(
                                HeroIcons.arrowLeft,
                                size: 64,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          Text(
                            toDateStringUI(selectedDate),
                            style: const TextStyle(fontSize: 28),
                          ),
                          if (index <= 0)
                            const SizedBox(
                              width: 64,
                            ),
                          if (index > 0)
                            IconButton(
                              onPressed: () {
                                pageViewController.animateToPage(index - 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut);
                              },
                              icon: HeroIcon(
                                HeroIcons.arrowRight,
                                size: 64,
                                color: Colors.grey.shade700,
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          pageViewController.animateToPage(0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut);
                        },
                        icon: HeroIcon(
                          HeroIcons.calendar,
                          size: 64,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Text(
                        'Heute',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 32.0, bottom: 32.0),
                            child: Material(
                              borderRadius: BorderRadius.circular(10),
                              elevation: 0.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [],
                                ),
                              ),
                            ),
                          ),
                          Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 0.0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 300,
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    /*const Text(
                                'Heute versoffen',
                                style: TextStyle(fontSize: 20),
                              ),*/
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            height: 200,
                                            width: 200,
                                            child: CircularProgressIndicator(
                                              color: progressIndicatorColor,
                                              backgroundColor:
                                                  Colors.grey.shade100,
                                              strokeWidth: 30,
                                              value: progressIndicatorValue,
                                            ),
                                          ),
                                          GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const SetValueScreen()));
                                                // Then close the drawer
                                              },
                                              child: Text(
                                                '${cash.cashPerDay[toDateString(selectedDate)]?.toStringAsFixed(2) ?? 0}€ / ${limit.toStringAsFixed(2)}€',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // TODO create new class for this
        backgroundColor: Colors.grey.shade700,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            builder: (BuildContext context) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => ref
                              .read(cashProvider.notifier)
                              .addCash(
                                  1,
                                  ref
                                      .read(dayProvider.notifier)
                                      .getCurrentDay()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+1€',
                            style:
                                TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(cashProvider.notifier)
                              .addCash(
                                  2,
                                  ref
                                      .read(dayProvider.notifier)
                                      .getCurrentDay()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+2€',
                            style:
                                TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => ref
                              .read(cashProvider.notifier)
                              .addCash(
                                  5,
                                  ref
                                      .read(dayProvider.notifier)
                                      .getCurrentDay()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+5€',
                            style:
                                TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(cashProvider.notifier)
                              .addCash(
                                  10,
                                  ref
                                      .read(dayProvider.notifier)
                                      .getCurrentDay()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+10€',
                            style:
                                TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => ref
                              .read(cashProvider.notifier)
                              .addCash(
                                  20,
                                  ref
                                      .read(dayProvider.notifier)
                                      .getCurrentDay()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+20€',
                            style:
                                TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(cashProvider.notifier)
                              .addCash(
                                  50,
                                  ref
                                      .read(dayProvider.notifier)
                                      .getCurrentDay()),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+50€',
                            style:
                                TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddValueScreen()))
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+',
                            style:
                                TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        },
        tooltip: 'Add Cash',
        child: const Icon(Icons.add),
      ),
    );
  }
}
