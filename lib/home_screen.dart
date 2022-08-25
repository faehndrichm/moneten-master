import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:simple_budget/providers.dart';

import 'helper.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final limitController = TextEditingController();
  final pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    var cash = ref.watch(cashProvider);
    limitController.text = cash.limit.toString();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        title: Text(
          widget.title,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 28, color: Colors.grey.shade700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: PageView.builder(
            controller: pageViewController,
            reverse: true,
            itemBuilder: (BuildContext context, int index) {
              int limit = cash.limit;
              int spentToday = cash.cashPerDay[toDateString(DateTime.now().add(Duration(days: -index)))] ?? 0;

              print(toDateString(DateTime.now().add(Duration(days: -index))));
              print("limit $limit");
              print("spentToday $spentToday");
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              pageViewController.animateToPage(index + 1,
                                  duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                            },
                            icon: HeroIcon(
                              HeroIcons.arrowLeft,
                              size: 64,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            toDateStringUI(DateTime.now().add(Duration(days: -index))),
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
                                    duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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
                              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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
                            padding: const EdgeInsets.only(top: 32.0, bottom: 32.0),
                            child: Material(
                              borderRadius: BorderRadius.circular(10),
                              elevation: 0.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      child: TextField(
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
                                              ref.read(cashProvider.notifier).setLimit(limit);
                                            } else {
                                              limitController.text = ref.read(cashProvider).limit.toString(); //reset
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
                                          }),
                                    ),
                                  ],
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
                                              color: Colors.grey.shade700,
                                              backgroundColor: Colors.grey.shade100,
                                              strokeWidth: 30,
                                              value: spentToday / limit,
                                            ),
                                          ),
                                          Text(
                                            '${cash.cashPerDay[toDateString(DateTime.now().add(Duration(days: -index)))] ?? 0} €',
                                            style: Theme.of(context).textTheme.headline4,
                                          ),
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
                          onPressed: () => ref.read(cashProvider.notifier).addCash(1),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+1€',
                            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => ref.read(cashProvider.notifier).addCash(5),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+5€',
                            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
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
                          onPressed: () => ref.read(cashProvider.notifier).addCash(10),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+10€',
                            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => ref.read(cashProvider.notifier).addCash(50),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(70, 70),
                            shape: const CircleBorder(),
                          ),
                          child: const Text(
                            '+50€',
                            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                  ),
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