import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footy/services/auth_base.dart';
import 'package:footy/services/auth_root.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/views/authenticate_phone_number_screen.dart';
import 'package:footy/views/countdown_timer_screen.dart';
import 'package:footy/views/create_notification_screen.dart';
import 'package:footy/views/game_records.dart';
import 'package:footy/views/notification_history_screen.dart';
import 'package:footy/views/qr_screen.dart';
import 'package:footy/views/rating_screen.dart';
import 'package:footy/views/scan_qr_screen.dart';
import 'package:footy/views/splash_screen.dart';
import 'package:footy/views/users_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../const.dart';
import 'Screen_Chat.dart';
import 'otp_screen.dart';
import 'package:footy/ads/ads.dart';

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

  final AdWidget adWidget = AdWidget(ad: myBanner);

  final AdListener listener = AdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an ad is in the process of leaving the application.
    onApplicationExit: (Ad ad) => print('Left application.'),
  );

  InterstitialAd _interstitialAd;
  bool _interstitialReady = false;

  void createInterstitialAd() {
    _interstitialAd ??= InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      request: AdRequest(),
      listener: AdListener(
        onAdLoaded: (Ad ad) {
          print('${ad.runtimeType} loaded.');
          _interstitialReady = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('${ad.runtimeType} failed to load: $error.');
          ad.dispose();
          _interstitialAd = null;
          createInterstitialAd();
        },
        onAdOpened: (Ad ad) => print('${ad.runtimeType} onAdOpened.'),
        onAdClosed: (Ad ad) {
          print('${ad.runtimeType} closed.');
          ad.dispose();
          createInterstitialAd();
        },
        onApplicationExit: (Ad ad) =>
            print('${ad.runtimeType} onApplicationExit.'),
      ),
    )..load();
  }

  @override
  void initState() {
    myBanner.load();
    createInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    myBanner.dispose();
    _interstitialAd?.dispose();
    super.dispose();
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
        body: Center(
          child: Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      if (!_interstitialReady) return;
                      _interstitialAd.show();
                      _interstitialReady = false;
                      _interstitialAd = null;
                      Navigator.pushNamed(context, CreateNotificationScreen.id);
                    },
                    child: Text('Create Notification')),
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
                  child: Text('New Timer'),
                  onPressed: () => Navigator.pushNamed(context, TimerScreen.id),
                ),
                ElevatedButton(
                  child: Text('View QR Code'),
                  onPressed: () => Navigator.pushNamed(context, QrScreen.id),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, ScanQrScreen.id),
                  child: Text('Scan QR Code'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, UsersScreen.id),
                  child: Text('Game Records'),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, Chat.id),
                  child: Text('Chat Screen'),
                ),
                ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, RatingScreen.id),
                    child: Text('Rating Screen')),
                ElevatedButton(
                    onPressed: () {
                      myInterstitial.show();
                      Navigator.pushNamed(context, SplashScreen.id);
                    },
                    child: Text('Notification History')),
                ElevatedButton(
                    onPressed: () async {
                      if (!_interstitialReady) return;
                      _interstitialAd.show();
                      _interstitialReady = false;
                      _interstitialAd = null;
                    },
                    child: Text('Show add')),
                Container(
                  alignment: Alignment.center,
                  child: adWidget,
                  width: myBanner.size.width.toDouble(),
                  height: myBanner.size.height.toDouble(),
                ),
              ],
            ),
          ),
        ));
  }
}
