import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:footy/views/notification_history_screen.dart';

class SplashScreen extends StatefulWidget {
  static final String id = '/splash_screen';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  initializeAndroid() async {
    //  Using local notification package to show push
    //   notifications when user is in app
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('sheiny_viewer_logo');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);
  }

  showNotification(RemoteMessage message) async {
    // Group notifications for Android only using local notification
    const String groupKey = 'com.android.example.WORK_EMAIL';
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      groupKey: groupKey,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      notificationNumber,
      message.notification.title,
      message.notification.body,
      platformChannelSpecifics,
    );
    notificationNumber += 1;
  }

  int notificationNumber = 0;

  initializeIOS() async {
    NotificationSettings settings = NotificationSettings();
    // Initializing for push notification
    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
    }
    // Initializing for foreground
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  initializeNotificationSettings() async {
    if (Platform.isAndroid) {
      initializeAndroid();
      //  When user receives notification inside App
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showNotification(message);
      });
    } else if (Platform.isIOS) {
      initializeIOS();
      //  When user receives notification inside App
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message == null) {
          // navigate to home screen
          // navigateToAuthRoot();
        } else {
          // navigateToAuthRoot();
        }
      });
    }

    // Platform unspecific code will run for IOS and Android
    // when user taps push notification from app in
    // terminated state

    await _firebaseMessaging.getInitialMessage().then((RemoteMessage message) {
      if (message == null) {
        // navigate to home screen
        // navigateToAuthRoot();
      } else {
        // navigateToAuthRoot();
      }
    });

    // Platform unspecific code will run for IOS and Android!
    // when user taps push notification from app in
    // background state

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message == null) {
        // navigate to home screen
        // navigateToAuthRoot();
      } else {
        // navigateToAuthRoot();
      }
    });
  }

  void navigateToNotificationScreen() async {
    await Future.delayed(Duration(milliseconds: 3000), () {
      Navigator.pushReplacementNamed(context, NotificationHistoryScreen.id);
    });
  }

  @override
  void initState() {
    initializeNotificationSettings();
    navigateToNotificationScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('splash screen');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Icon(
        FontAwesomeIcons.footballBall,
        color: Colors.green,
        size: 100.0,
      )),
    );
  }
}
