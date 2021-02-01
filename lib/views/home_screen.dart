import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/views/qr_screen.dart';
import 'package:footy/views/scan_qr_screen.dart';
import 'package:footy/views/timer_view.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Home Screen'),
        ),
        body: Container(
          width: SizeConfig.screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RaisedButton(
                child: Text('Timer'),
                onPressed: () => Navigator.pushNamed(context, TimerView.id),
              ),
              RaisedButton(
                child: Text('View QR Code'),
                onPressed: () => Navigator.pushNamed(context, QrScreen.id),
              ),
              RaisedButton(
                onPressed: () => Navigator.pushNamed(context, ScanQrScreen.id),
                child: Text('Scan QR Code'),
              )
            ],
          ),
        ));
  }
}
