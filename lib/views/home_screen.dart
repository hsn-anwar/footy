import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footy/services/auth_base.dart';
import 'package:footy/services/auth_root.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/views/authenticate_phone_number_screen.dart';
import 'package:footy/views/countdown_timer_screen.dart';
import 'package:footy/views/game_records.dart';
import 'package:footy/views/qr_screen.dart';
import 'package:footy/views/rating_screen.dart';
import 'package:footy/views/scan_qr_screen.dart';
import 'package:footy/views/timer_screen.dart';
import '../const.dart';
import 'Screen_Chat.dart';
import 'otp_screen.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'home_screen';
  HomeScreen({Key key, this.auth, this.userID, this.logoutCallback})
      : super(key: key);

  final String userID;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _checkIfPhoneLinked = true;
  showSuccessPhoneLinked() {
    Fluttertoast.showToast(
        msg: "${'Phone number has been linked to your account'}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }

  showErrorPhoneLinked() {
    Fluttertoast.showToast(
        msg: "${'Phone number could not be linked to your account'}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final bool _isPhoneLinked = ModalRoute.of(context).settings.arguments;

    if (_isPhoneLinked != null) {
      print(_isPhoneLinked);
      if (_checkIfPhoneLinked) {
        _checkIfPhoneLinked = false;
        if (_isPhoneLinked) {
          showSuccessPhoneLinked();
        } else {
          showErrorPhoneLinked();
        }
      }
    }

    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Home Screen'),
          actions: [
            IconButton(
              onPressed: () {
                print(widget.auth);
                widget.auth.signOut().then((value) {
                  print('signed out');
                  widget.logoutCallback();
                  Navigator.pushReplacementNamed(context, AuthRoot.id);
                });
              },
              icon: Icon(Icons.exit_to_app),
              iconSize: 22.0,
            ),
          ],
        ),
        body: Container(
          width: SizeConfig.screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Phone Authentication'),
                onPressed: () => Navigator.pushNamed(
                    context, AuthenticatePhoneNumberScreen.id),
              ),
              ElevatedButton(
                child: Text('View OTP Screen'),
                onPressed: () => Navigator.pushNamed(context, OtpScreen.id),
              ),
              ElevatedButton(
                child: Text('Timer'),
                onPressed: () => Navigator.pushNamed(context, TimerView.id),
              ),
              ElevatedButton(
                child: Text('New Timer'),
                onPressed: () => Navigator.pushNamed(context, TimerScreen.id),
              ),
              ElevatedButton(
                child: Text('View QR Code'),
                onPressed: () => Navigator.pushNamed(context, QrScreen.id),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, ScanQrScreen.id),
                child: Text('Scan QR Code'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, GameRecords.id),
                child: Text('Game Records'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, Chat.id),
                child: Text('Chat Screen'),
              ),
              ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, RatingScreen.id),
                  child: Text('Rating Screen'))
            ],
          ),
        ));
  }
}
