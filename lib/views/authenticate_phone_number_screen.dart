import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:footy/services/auth_base.dart';
import 'package:footy/views/opt_screen.dart';
import 'package:footy/views/otp_data.dart';

class AuthenticatePhoneNumberScreen extends StatefulWidget {
  static final String id = 'authenticate_phone_number_screen';
  @override
  _AuthenticatePhoneNumberScreenState createState() =>
      _AuthenticatePhoneNumberScreenState();
}

class _AuthenticatePhoneNumberScreenState
    extends State<AuthenticatePhoneNumberScreen> {
  String countryCode;
  TextEditingController _numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _showMyDialog(String verificationId,
      DocumentReference documentReference, String phoneNumber) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter OTP'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: otpController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                validateAndLink(verificationId, documentReference, phoneNumber);
              },
            ),
          ],
        );
      },
    );
  }

  validateAndLink(String verificationId, DocumentReference documentReference,
      String phoneNumber) {
    String smsCode = otpController.value.text;
    if (smsCode.length == 6 && smsCode.isNotEmpty) {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      try {
        _firebaseAuth.currentUser.linkWithCredential(phoneAuthCredential);
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Phone number linked')));
      } catch (e) {
        print(e);
      }
      documentReference.update({
        'phoneNumber': phoneNumber,
        'isVerified': true,
      });
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid code')));
    }
  }

  int token;
  validatePhoneNumber(BuildContext context, String phoneNumber) async {
    User user = _firebaseAuth.currentUser;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentReference documentReference =
        _firestore.collection('users').doc(user.uid);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        timeout: const Duration(seconds: 10),
        phoneNumber: phoneNumber,
        // Automatic handling of the SMS code on Android devices.
        forceResendingToken: token,
        verificationCompleted: (PhoneAuthCredential credential) {
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text('Phone number linked.')));
        },
        // Handle failure events such as invalid phone numbers or whether the SMS quota has been exceeded.
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.code)));
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.code)));
          }
        },
        // Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code.
        codeSent: (String verificationId, int resendToken) async {
          // _showMyDialog(verificationId, documentReference, phoneNumber);
          OtpData otpData = OtpData(
              docRef: documentReference,
              phoneNumber: phoneNumber,
              verificationId: verificationId);
          Navigator.pushReplacementNamed(context, OTPScreen.id,
              arguments: otpData);
        },
        // Handle a timeout of when automatic SMS code handling fails.
        codeAutoRetrievalTimeout: (String verificationId) async {
          print('in time out');
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Authentication'),
        ),
        body: Stack(
          children: [
            Container(
              child: Center(
                child: _isLoading ? CircularProgressIndicator() : Container(),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28.0),
                    child: Text(
                      'Enter phone number to link to account',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CountryCodePicker(
                        onChanged: (value) {
                          countryCode = value.toString();
                        },
                        favorite: <String>['PAK'],
                        initialSelection: 'Pakistan',
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                      ),
                      SizedBox(
                        width: 3,
                      ),
                      Container(
                        width: 140,
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Field cannot be empty';
                              } else {
                                return null;
                              }
                            },
                            controller: _numberController,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                            autofocus: false,
                            decoration: new InputDecoration(
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderSide: new BorderSide(),
                              ),
                            ),
                            maxLengthEnforced: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Builder(builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: RaisedButton(
                        color: Colors.green[400],
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            validatePhoneNumber(context,
                                '$countryCode ${_numberController.value.text}');
                          }
                        },
                        child: Text(
                          'Enter Number',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
