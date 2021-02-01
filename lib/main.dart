import 'package:flutter/material.dart';
import 'package:footy/views/home_screen.dart';
import 'package:footy/views/qr_screen.dart';
import 'package:footy/views/result_screen.dart';
import 'package:footy/views/scan_qr_screen.dart';
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
        initialRoute: HomeScreen.id,
        routes: {
          HomeScreen.id: (context) => HomeScreen(),
          TimerView.id: (context) => TimerView(),
          QrScreen.id: (context) => QrScreen(),
          ScanQrScreen.id: (context) => ScanQrScreen(),
          ResultScreen.id: (context) => ResultScreen(),
        });
  }
}
