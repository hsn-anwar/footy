import 'package:flutter/material.dart';
import 'package:footy/services/auth_base.dart';
import 'package:footy/services/auth_root.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/views/authenticate_phone_number_screen.dart';
import 'package:footy/views/qr_screen.dart';
import 'package:footy/views/scan_qr_screen.dart';
import 'package:footy/views/timer_view.dart';
import 'opt_screen.dart';

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
  @override
  Widget build(BuildContext context) {
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
              RaisedButton(
                child: Text('Phone Authentication'),
                onPressed: () => Navigator.pushNamed(
                    context, AuthenticatePhoneNumberScreen.id),
              ),
              RaisedButton(
                child: Text('View OTP Screen'),
                onPressed: () => Navigator.pushNamed(context, OTPScreen.id),
              ),
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
