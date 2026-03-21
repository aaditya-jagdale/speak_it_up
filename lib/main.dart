import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speak_it_up/home/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: kDebugMode,
      title: 'Speak it up',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'geist',
      ),
      home: HomeScreen(),
    );
  }
}
