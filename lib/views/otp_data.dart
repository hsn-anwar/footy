import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OtpData {
  final String phoneNumber;
  final String verificationId;
  final DocumentReference docRef;

  OtpData({
    @required this.docRef,
    @required this.phoneNumber,
    @required this.verificationId,
  });
}
