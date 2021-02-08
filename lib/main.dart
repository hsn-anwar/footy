import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:footy/services/auth_base.dart';
import 'package:footy/services/auth_root.dart';
import 'package:footy/views/authenticate_phone_number_screen.dart';
import 'package:footy/views/home_screen.dart';
import 'package:footy/views/login_screen.dart';
import 'package:footy/views/qr_screen.dart';
import 'package:footy/views/result_screen.dart';
import 'package:footy/views/scan_qr_screen.dart';
import 'package:footy/views/timer_view.dart';
import 'views/opt_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Auth _auth = Auth();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        key: scaffoldKey,
        title: 'Footy',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        initialRoute: AuthRoot.id,
        routes: {
          AuthRoot.id: (context) => AuthRoot(auth: _auth),
          AuthenticatePhoneNumberScreen.id: (context) =>
              AuthenticatePhoneNumberScreen(),
          HomeScreen.id: (context) => HomeScreen(),
          OTPScreen.id: (context) => OTPScreen(),
          TimerView.id: (context) => TimerView(),
          QrScreen.id: (context) => QrScreen(),
          ScanQrScreen.id: (context) => ScanQrScreen(),
          ResultScreen.id: (context) => ResultScreen(),
        });
  }
}
