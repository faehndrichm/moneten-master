import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moneten Master',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Poppins',
        backgroundColor: Colors.grey[50],
        textTheme: const TextTheme(
          bodyText2: TextStyle(fontSize: 20),
        )
        ,
      ),
      home: const HomeScreen(title: 'Moneten Master'),
    );
  }
}
