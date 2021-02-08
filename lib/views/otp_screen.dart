import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'file:///E:/Projects/footy/lib/models/otp_data.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pinput/pin_put/pin_put_state.dart';

class OtpScreen extends StatefulWidget {
  static final String id = 'otp_screen';

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      color: const Color.fromRGBO(235, 236, 237, 1),
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  validateAndLink(
      BuildContext context,
      String verificationId,
      DocumentReference documentReference,
      String phoneNumber,
      String userPin) async {
    print('user pin: $userPin');
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: userPin);
    try {
      await _firebaseAuth.currentUser.linkWithCredential(phoneAuthCredential);
      print('d');
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Phone number linked')));
      documentReference.update({
        'phoneNumber': phoneNumber,
        'isVerified': true,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('Invalid PIN entered. Try again.')));
        _pinPutController.clear();
      }
      print('Failed with error code: ${e.code}');
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final OtpData otpData = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('OTP'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Builder(
            builder: (context) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        // color: Colors.white,
                        margin: const EdgeInsets.all(20.0),
                        padding: const EdgeInsets.all(20.0),
                        child: PinPut(
                          fieldsCount: 6,
                          onSubmit: (String pin) {
                            validateAndLink(context, otpData.verificationId,
                                otpData.docRef, otpData.phoneNumber, pin);
                          },
                          focusNode: _pinPutFocusNode,
                          controller: _pinPutController,
                          submittedFieldDecoration: _pinPutDecoration,
                          selectedFieldDecoration: _pinPutDecoration.copyWith(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.green.withOpacity(.5),
                            ),
                          ),
                          followingFieldDecoration: _pinPutDecoration,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
