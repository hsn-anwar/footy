import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:footy/services/auth_base.dart';
import 'package:footy/views/otp_screen.dart';
import 'file:///E:/Projects/footy/lib/models/otp_data.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  int token;
  validatePhoneNumber(BuildContext context, String phoneNumber) async {
    setState(() {
      _isLoading = true;
    });
    User user = _firebaseAuth.currentUser;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentReference documentReference =
        _firestore.collection('users').doc(user.uid);
    print(user.phoneNumber);
    if (user.phoneNumber.isEmpty) {
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
            print(phoneNumber);
            if (e.code == 'invalid-phone-number') {
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid number entered')));
              setState(() {
                _isLoading = false;
              });
            } else {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text(e.code)));
              setState(() {
                _isLoading = false;
              });
            }
          },
          // Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code.
          codeSent: (String verificationId, int resendToken) async {
            OtpData otpData = OtpData(
                docRef: documentReference,
                phoneNumber: phoneNumber,
                verificationId: verificationId);
            Navigator.pushReplacementNamed(context, OtpScreen.id,
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
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content:
              Text('A number has already been registered with ${user.email}')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  final spinkit = SpinKitFadingCircle(
    color: Colors.green,
    size: 50.0,
  );
  final spinkit2 = SpinKitFadingGrid(
    color: Colors.green,
    size: 50.0,
  );
  bool _isLoading = false;
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
        body: Center(
          child: Stack(
            children: [
              _isLoading ? spinkit : Container(),
              AbsorbPointer(
                absorbing: _isLoading,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_isLoading.toString()),
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
                            print(value);
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
      ),
    );
  }
}
