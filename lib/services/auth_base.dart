import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  User getCurrentUser();

  void sendEmailVerification();

  Future<void> signOut();

  bool isEmailVerified();

  bool isUserSignedIn();

  void deleteUserDocument(String uid);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('users');

  Future<String> signIn(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    User user = userCredential.user;
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    User user = userCredential.user;
    return user.uid;
  }

  User getCurrentUser() {
    User user = _firebaseAuth.currentUser;
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  void sendEmailVerification() {
    User user = _firebaseAuth.currentUser;
    user.sendEmailVerification();
  }

  bool isEmailVerified() {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  bool isUserSignedIn() {
    User user = _firebaseAuth.currentUser;
    return user?.uid == null ? false : true;
  }

  Future<void> deleteUserDocument(String uid) async {
    await _collection.doc(uid).delete();
  }
}
