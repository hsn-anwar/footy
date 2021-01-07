import 'package:flutter/material.dart';
import 'package:footy/views/timer_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Footy',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: TimerView.id,
      routes: {
        TimerView.id: (context) => TimerView(),
      },
    );
  }
}
