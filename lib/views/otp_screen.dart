import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'file:///E:/Projects/footy/lib/models/otp_data.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pinput/pin_put/pin_put_state.dart';
import 'package:footy/shared/constants.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

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

    try {
      await _firebaseAuth.currentUser.linkWithCredential(credentials);
      documentReference.update({
        'phoneNumber': widget.phoneNumber,
        'isPhoneNumberVerified': true,
      });

      print('verified and linked');
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
          if (e.code == 'invalid-phone-number') {
            setState(() {
              error = e.message;
              setState(() {
                error = e.message;
              });
            });
            print('Invalid phone number');
          } else {
            setState(() {
              error = e.message;
            });
            print(e.code);
            setState(() {
              error = e.message;
            });
            print(e.message);
          }
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

  void startTimer() {
    Timer _timer;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (resendCodeTime == 1) {
          setState(() {
            _showResendButton = true;
            timer.cancel();
          });
        } else {
          if (mounted) {
            setState(() {
              resendCodeTime--;
            });
          }
        }
      },
    );
  }

  String error = '';
  @override
  void initState() {
    validatePhone();
    startTimer();
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'An OTP code has been sent to\t\t${widget.phoneNumber} for verification',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'PIN  INPUT',
                      style: TextStyle(
                        fontSize: 32,
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
                    padding: const EdgeInsets.all(20.0),
                    child: PinPut(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      fieldsCount: 6,
                      onSubmit: (String pin) {
                        setState(() {
                          _pinCode = pin;
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
                  _showResendButton
                      ? RaisedButton(
                          color: Colors.green,
                          child: Text(
                            'Resend code',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: resendSmsFunctionality,
                        )
                      : Text(
                          'Didn\'t receive code?\nYou can resend code in: \t $resendCodeTime secs'),
                  Text(
                    error,
                    style: TextStyle(fontSize: 22.0),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void resendSmsFunctionality() {
    setState(() {
      _showResendButton = false;
      resendCodeTime = 60;
    });
    startTimer();
    validatePhone();
  }
}
