import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:footy/views/home_screen.dart';
import 'package:footy/views/login_screen.dart';

import 'auth_base.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class AuthRoot extends StatefulWidget {
  static String id = 'auth_root';

  AuthRoot({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _AuthRootState();
}

class _AuthRootState extends State<AuthRoot> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String userID = "";
  bool isProfessional = true;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    if (widget.auth.isUserSignedIn()) {
      userID = widget.auth.getCurrentUser().uid;
    }
    authStatus = widget.auth.getCurrentUser()?.uid == null
        ? AuthStatus.NOT_LOGGED_IN
        : AuthStatus.LOGGED_IN;
  }

  void loginCallback() {
    setState(() {
      userID = widget.auth.getCurrentUser().uid;
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      userID = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        print('returning from auth root');
        return LoginScreen(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (userID.length > 0 && userID != null) {
          return
              // isProfessional
              // ? HomeScreenProfessional() :
              HomeScreen(
            userID: userID,
            auth: widget.auth,
            logoutCallback: logoutCallback,
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
