import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footy/models/game_models.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/widgets/data_table.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footy/widgets/table_components.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../const.dart';

final Logger logger = Logger();

class GameRecords extends StatefulWidget {
  static final String id = 'game_records';
  @override
  _GameRecordsState createState() => _GameRecordsState();
}

class _GameRecordsState extends State<GameRecords> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    // getAllGameRecords();
    super.initState();
  }

  void debugDataGenerator() async {
    gameID--;
    debugFlag = !debugFlag;
    if (gameID % 2 == 0) {
      status = 'W';
    } else if (gameID % 3 == 0) {
      status = 'L';
    } else {
      status = 'D';
    }
    await _firebaseFirestore
        .collection("users")
        .doc("2dPRIeIss7Z2SpmpY4p4V8BdPDS2")
        .collection("gamesRecord")
        .add({
      "gameID": "$gameID",
      "isMVP": "$debugFlag",
      "matchStatus": status,
      "gameType": "Football",
    });
  }

  int gameID = 999;
  bool debugFlag = false;
  String status;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // getGameRecords();
          // debugDataGenerator();
          // getAllGameRecords();
        },
      ),
      appBar: AppBar(
        title: Text('Game Records'),
      ),
      body: GameRecordsDataTable(),
    );
  }
}
