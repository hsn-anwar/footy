import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy/views/home_screen.dart';
import 'package:footy/widgets/count_down_timer.dart';
import 'file:///E:/Projects/footy/lib/models/otp_data.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pinput/pin_put/pin_put_state.dart';
import 'package:footy/shared/constants.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class OtpScreen extends StatefulWidget {
  static final String id = 'otp_screen';
  final String phoneNumber;
  OtpScreen({this.phoneNumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _verificationCode;
  String _pinCode;
  int _resendToken;

  int resendCodeTime = 60;
  bool _showResendButton = false;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      color: const Color.fromRGBO(235, 236, 237, 1),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  autoValidate(PhoneAuthCredential credentials) async {
    print('In auto Validate');
    User user = _firebaseAuth.currentUser;
    DocumentReference documentReference =
        _firestore.collection('users').doc(user.uid);
    Navigator.pushReplacementNamed(context, HomeScreen.id, arguments: true);
    try {
      await _firebaseAuth.currentUser.linkWithCredential(credentials);
      documentReference.update({
        'phoneNumber': widget.phoneNumber,
        'isPhoneNumberVerified': true,
      });

      print('auto validating complete');
    } on FirebaseAuthException catch (e) {
      print(e.code);
      print(e.message);
      _pinPutController.text = '';
    }
  }

  linkNumber() async {
    User user = _firebaseAuth.currentUser;
    DocumentReference documentReference =
        _firestore.collection('users').doc(user.uid);

    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: _verificationCode, smsCode: _pinCode);
      await _firebaseAuth.currentUser.linkWithCredential(phoneAuthCredential);
      documentReference.update({
        'phoneNumber': widget.phoneNumber,
        'isPhoneNumberVerified': true,
      });
      print('verified and linked');
      Navigator.pushReplacementNamed(context, HomeScreen.id, arguments: true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        print(e.code);
        Fluttertoast.showToast(
            msg: "Invalid code entered",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

        _pinPutController.clear();
      } else if (e.code == 'credential-already-in-use') {
        print(e.code);
        Fluttertoast.showToast(
            msg: "This number has already been linked to an account",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.code == 'too-many-requests') {
        print(e.code);
        Fluttertoast.showToast(
            msg: "Too many requests has been sent. Please try again later.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        print('Uncaught exception');
        print('Failed with error code: ${e.code}');
        Fluttertoast.showToast(
            msg: "${e.message}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  failedVerification(FirebaseAuthException e) {
    if (e.code == 'invalid-phone-number') {
      setState(() {
        error = e.message;
        setState(() {
          error = e.message;
        });
      });
      print('Invalid phone number');
    } else if (e.code == 'too-many-requests') {
      print(e.code);
      Fluttertoast.showToast(
          msg: "Too many requests has been sent. Please try again later.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else if (e.code == 'credential-already-in-use') {
      print(e.code);
      Fluttertoast.showToast(
          msg: "This number has already been linked to an account",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      print('Uncaught exception');
      print('Failed with error code: ${e.code}');
      Fluttertoast.showToast(
          msg: "${e.message}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      //TODO: Remove this
      setState(() {
        error = e.message;
      });
      print(e.code);
      setState(() {
        error = e.message;
      });
      print(e.message);
    }
  }

  validatePhone() async {
    // TODO: Check if user or number already linked
    print('In validating');
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('in auto validate');
          autoValidate(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed');
          failedVerification(e);
        },
        codeSent: (String verificationCode, int resendToken) async {
          print('In code sent');
          setState(() {
            _verificationCode = verificationCode;
            _resendToken = resendToken;
          });
        },
        codeAutoRetrievalTimeout: (String verificationCode) {
          setState(() {
            print('timed out');
            print('Timed out code: $_verificationCode');
            _verificationCode = verificationCode;
          });
        },
        timeout: Duration(seconds: resendCodeTime),
      );
    } catch (e) {
      print(e);
    }
  }

  final StopWatchTimer timerController = StopWatchTimer();

  bool _isSubmitted = false;

  String error = '';
  @override
  void initState() {
    timerController.onExecute.add(StopWatchExecute.start);
    validatePhone();
    // initializeAutoValidatorFlag();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final OtpData otpData = ModalRoute.of(context).settings.arguments;
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Builder(
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 100.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                    child: Text(
                      'An OTP code has been sent to\t\t${widget.phoneNumber} for verification',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        shadows: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    child: Text(
                      'Enter  PIN here',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        shadows: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(20.0),
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                    child: PinPut(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      fieldsCount: 6,
                      onSubmit: (String pin) {
                        setState(() {
                          _pinCode = pin;
                          // timerController.onExecute.add(StopWatchExecute.stop);
                          linkNumber();
                        });
                        // validateAndLink(context, otpData.verificationId,
                        //     otpData.docRef, otpData.phoneNumber, pin);
                      },
                      focusNode: _pinPutFocusNode,
                      controller: _pinPutController,
                      submittedFieldDecoration: _pinPutDecoration.copyWith(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.green[100],
                        border: Border.all(
                          color: Colors.green.withOpacity(.5),
                        ),
                      ),
                      selectedFieldDecoration: _pinPutDecoration.copyWith(
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Colors.green.withOpacity(.5),
                        ),
                      ),
                      followingFieldDecoration: _pinPutDecoration,
                    ),
                  ),
                  // _showResendButton
                  //     ? RaisedButton(
                  //         color: Colors.green,
                  //         child: Text(
                  //           'Resend code',
                  //           style: TextStyle(color: Colors.white),
                  //         ),
                  //         onPressed: resendSmsFunctionality,
                  //       )
                  //     : Text(
                  //         'Didn\'t receive code?\nYou can resend code in: \t $resendCodeTime secs'),
                  Text(
                    error.toString(),
                    style: TextStyle(fontSize: 22.0),
                  ),
                  !_showResendButton
                      ? Column(
                          children: [
                            Text(
                              'Didn\'t receive a code yet?',
                              style: kResendLabelStyle,
                            ),
                            SizedBox(height: 4),
                            Text('You can resend SMS for a code in',
                                style: kResendLabelStyle),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(),
                              child: CountDownTimer(
                                stopWatchTimer: timerController,
                                mins: 0,
                                secs: 60,
                                soundFlag: false,
                                onPrimaryTimerStopped: onPrimaryTimerStopped,
                                callSetState: callSetState,
                                radius: 60,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          child: Text(
                            'Resend code',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: resendSmsFunctionality,
                        ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void onPrimaryTimerStopped(bool changeFlag) {
    setState(() {
      _showResendButton = true;
    });
  }

  void callSetState() {
    setState(() {});
  }

  void resendSmsFunctionality() {
    setState(() {
      timerController.onExecute.add(StopWatchExecute.reset);
      timerController.onExecute.add(StopWatchExecute.start);
      _showResendButton = false;
      resendCodeTime = 60;
    });
    validatePhone();
  }
}
