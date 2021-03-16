import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footy/models/game_models.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_maps_place_picker/google_maps_place_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:footy_app/Screens/UserProfile/Screen_UserProfileView.dart';
// import 'package:footy_app/Screens/QRCode/Screen_ScanQRCode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footy/views/Screen_Chat.dart';
import 'dart:async';

class Utils {
  static final Utils _utils = Utils._internal();
  Map<String, DocumentSnapshot> playersMap = Map();
  DocumentSnapshot lastMessage;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  int messagesPerRequest = 20;
  bool isMoreMessages = true;
  Map<String, Map<String, List<YearRecord>>> allUsersRecords = {};

  factory Utils() {
    return _utils;
  }

  Utils._internal();

  void startConversation(context, String id, isPrivate) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Chat(
        chatId: id,
        isPrivate: isPrivate,
      );
    }));
  }

  Future<DocumentSnapshot> getUserDetails(id) async {
    // print('get usersDetails'+isFollowing().toString());
    logger.d(id);
    if (playersMap.containsKey(id)) {
      //print('in Contains');

      return playersMap[id];
    } else {
      //print('in else');
      DocumentSnapshot snapshot =
          await _firestore.collection("users").doc(id).get();
      //print(snapshot.get('name'));
      playersMap.putIfAbsent(id, () => snapshot);
      return snapshot;
    }
  }

  Future<List<DocumentSnapshot>> getMessagesFromFirestore(
      String conversationID) async {
    List<DocumentSnapshot> messages;
    if (lastMessage == null)
      // messages = await getInitialMessages(conversationID);
      return null;
    else {
      messages = await getMoreMessages(conversationID);
      // messages.forEach((element) {
      //   logger.d(element.data());
      // });
      return messages;
    }
  }

  List<DocumentSnapshot> initializeMessaging(
      List<DocumentChange> documentChanges,
      StreamController _streamController) {
    var isChange = false;
    // lastMessage = documentChanges.last.doc;
    List<DocumentSnapshot> messages = [];

    print('last msg' + lastMessage.toString());
    print('doc changes 2' + documentChanges.toString());

    documentChanges.forEach((productChange) async {
      if (productChange.type == DocumentChangeType.added) {
        print('type added');
        //  if (timesRan <= messagesPerRequest - 1) {
        messages.add(productChange.doc);
        //   isInitialCall = false;
        //   timesRan += 1;
        //  } else {
        //print(productChange.doc.data());
        //_products.insert(0, productChange.doc);
        //  }
        //  isChange = true;
      }
    });

    // if (isChange) {
    //   // _streamController.add(_products);
    // }

    //print(_products);
    return messages;
  }

  Future<List<DocumentSnapshot>> getInitialMessages(
      String conversationID) async {
    // logger.d("Getting initial messages");
    Query getMessagesQuery = _firestore
        .collection('conversations')
        .doc(conversationID)
        .collection(conversationID)
        .limit(messagesPerRequest)
        .orderBy('timestamp', descending: true);

    QuerySnapshot messages = await getMessagesQuery.get();
    logger.wtf(messages.docs.length);
    if (messages.docs.length < messagesPerRequest) {
      isMoreMessages = false;
    } else {
      isMoreMessages = true;
    }
    messages.docs.forEach((element) {
      print(element.data());
    });
    // logger.i('Initial messages length: ${messages.docs.length}');
    lastMessage = messages.docs.last;
    return messages.docs;
  }

  List<DocumentSnapshot> _products = [];
  bool isInitialCall = false;
  int streamLength;
  int timesRan = 0;
  // initializeMessaging(List<DocumentChange> documentChanges,
  //     StreamController _streamController) {
  //   var isChange = false;
  //   lastMessage = documentChanges.last.doc;
  //   documentChanges.forEach((productChange) async {
  //     if (productChange.type == DocumentChangeType.added) {
  //       if (timesRan <= messagesPerRequest - 1) {
  //         _products.add(productChange.doc);
  //         isInitialCall = false;
  //         timesRan += 1;
  //       } else {
  //         print(productChange.doc.data());
  //         _products.insert(0, productChange.doc);
  //       }
  //       isChange = true;
  //     }
  //   });
  //
  //   if (isChange) {
  //     // _streamController.add(_products);
  //   }
  //
  //   return _products;
  // }

  Future<List<DocumentSnapshot>> getMoreMessages(String conversationID) async {
    if (isMoreMessages) {
      logger.d("Getting more messages");

      Query getMessagesQuery = _firestore
          .collection('conversations')
          .doc(conversationID)
          .collection(conversationID)
          .limit(messagesPerRequest)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastMessage);
      QuerySnapshot messages = await getMessagesQuery.get();
      if (messages.docs.length < messagesPerRequest) {
        isMoreMessages = false;
      } else {
        isMoreMessages = true;
      }
      messages.docs.forEach((element) {
        print(element.data());
      });
      logger.wtf('More messages length: ${messages.docs.length}');
      logger.wtf('Last document is: ${messages.docs.last.data()}');
      logger.wtf('Is more messages left: $isMoreMessages');
      lastMessage = messages.docs.last;

      return messages.docs;
    } else {
      logger.wtf(isMoreMessages);
      return null;
    }
  }

  Future<Map<String, List<YearRecord>>> getAllUserGameRecords(
      String userID) async {
    logger.wtf(userID);

    User user = _firebaseAuth.currentUser;
    Query query = _firestore
        .collection("users")
        //TODO: Change this to userID
        .doc(userID)
        // .doc(user.uid)
        .collection("gamesRecord");

    if (allUsersRecords.containsKey(userID)) {
      logger.d("in if");
      print(allUsersRecords);
      return allUsersRecords[userID];
    } else {
      List<YearRecord> gameTypeRecords = [];

      QuerySnapshot querySnapshot = await query.get();
      List<DocumentSnapshot> docs = querySnapshot.docs;
      logger.i(docs.length);
      int index;
      Map<String, List<YearRecord>> allGameRecords = {};

      for (DocumentSnapshot doc in docs) {
        GameRecord gameRecord = GameRecord(
            gameID: doc.data()['gameID'],
            matchStatus: doc.data()['matchStatus'],
            playedAt: doc.data()['playedAt'],
            gameType: doc.data()['gameType'],
            isMVP: doc.data()['isMVP'],
            goals: int.parse(doc.data()['goals'] ?? '0'));

        if (!allGameRecords.containsKey(gameRecord.gameType)) {
          allGameRecords[gameRecord.gameType] = [];
        }

        gameTypeRecords = allGameRecords[gameRecord.gameType];

        index = gameTypeRecords
            .indexWhere((record) => record.year == gameRecord.getYearPlayed());

        if (index == -1) {
          YearRecord yearRecord = YearRecord(
            year: gameRecord.getYearPlayed(),
            totalDraws: 0,
            totalGoals: 0,
            totalLosses: 0,
            totalPlayed: 0,
            totalWins: 0,
            timesMVP: 0,
            showGoals: false,
            dateTimePlayed: gameRecord.playedAt.toDate(),
          );

          gameTypeRecords.add(yearRecord);
          index = gameTypeRecords.indexWhere(
              (record) => record.year == gameRecord.getYearPlayed());
        }

        if (gameRecord.gameType == 'Football' ||
            gameRecord.gameType == 'Field Hockey') {
          gameTypeRecords[index].showGoals = true;
          gameTypeRecords[index].totalGoals += gameRecord.goals;
        }

        gameTypeRecords[index].totalPlayed += 1;
        if (gameRecord.isMVP) gameTypeRecords[index].timesMVP += 1;

        if (gameRecord.matchStatus == 'W')
          gameTypeRecords[index].totalWins += 1;

        if (gameRecord.matchStatus == 'L')
          gameTypeRecords[index].totalLosses += 1;

        if (gameRecord.matchStatus == 'D')
          gameTypeRecords[index].totalDraws += 1;
        gameTypeRecords
            .sort((a, b) => int.parse(b.year).compareTo(int.parse(a.year)));
        allGameRecords[gameRecord.gameType] = gameTypeRecords;
      }
      logger.wtf(allUsersRecords.keys.toList());
      print(allGameRecords);
      allUsersRecords[userID] = allGameRecords;
      print(userID);
      print(allUsersRecords);
      return allUsersRecords[userID];
    }
  }
}
