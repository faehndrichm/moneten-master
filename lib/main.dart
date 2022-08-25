import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Poppins',
        backgroundColor: Colors.grey[50],
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.grey[700], //<-- SEE HERE
              displayColor: Colors.grey[700], //<-- SEE HERE
            ),
      ),
      home: const HomeScreen(title: 'Moneten Master'),
    );
  }
}
