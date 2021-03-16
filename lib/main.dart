import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:footy/services/auth_base.dart';
import 'package:footy/services/auth_root.dart';
import 'package:footy/views/authenticate_phone_number_screen.dart';
import 'package:footy/views/countdown_timer_screen.dart';
import 'package:footy/views/game_records.dart';
import 'package:footy/views/home_screen.dart';
import 'package:footy/views/login_screen.dart';
import 'package:footy/views/notification_history_screen.dart';
import 'package:footy/views/qr_screen.dart';
import 'package:footy/views/rating_screen.dart';
import 'package:footy/views/result_screen.dart';
import 'package:footy/views/scan_qr_screen.dart';
import 'package:footy/views/splash_screen.dart';
import 'package:footy/views/timer_screen.dart';
import 'package:footy/views/users_screen.dart';
import 'views/otp_screen.dart';
import 'package:footy/views/Screen_Chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Auth _auth = Auth();
  final String peerID = "L0yZLcvTWUPJTFjR7Y8p9OOsrnB2"; // For device
  // final String peerID = "SSmuznRGQoV83WfXqJ69pb6Av0T2"; // for emulator

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        OtpScreen.id: (context) => OtpScreen(),
        TimerView.id: (context) => TimerView(),
        TimerScreen.id: (context) => TimerScreen(),
        QrScreen.id: (context) => QrScreen(),
        GameRecords.id: (context) => GameRecords(),
        ScanQrScreen.id: (context) => ScanQrScreen(),
        ResultScreen.id: (context) => ResultScreen(),
        Chat.id: (context) => Chat(isPrivate: true, chatId: peerID),
        RatingScreen.id: (context) => RatingScreen(),
        UsersScreen.id: (context) => UsersScreen(),
        SplashScreen.id: (context) => SplashScreen(),
        NotificationHistoryScreen.id: (context) => NotificationHistoryScreen(),
      },
    );
  }
}
