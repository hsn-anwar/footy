import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footy/models/game_models.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/widgets/data_table.dart';
import 'package:logger/logger.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final Logger logger = Logger();

class GameRecords extends StatefulWidget {
  static final String id = 'game_records';
  @override
  _GameRecordsState createState() => _GameRecordsState();
}

class _GameRecordsState extends State<GameRecords> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<YearRecord> gameRecordList = [];
  bool isLoading = false;
  void getGameRecords() async {
    setState(() {
      isLoading = true;
    });

    gameRecordList.clear();
    User user = _firebaseAuth.currentUser;
    Query query = _firebaseFirestore
        .collection("users")
        .doc("2dPRIeIss7Z2SpmpY4p4V8BdPDS2")
        .collection("gamesRecord")
        .where("gameType", isEqualTo: "Football");

    QuerySnapshot querySnapshot = await query.get();
    List<DocumentSnapshot> docs = querySnapshot.docs;
    logger.i(docs.length);
    int index;
    for (DocumentSnapshot doc in docs) {
      logger.i(doc['gameID']);
      GameRecord gameRecord = GameRecord(
          gameID: doc['gameID'],
          matchStatus: doc['matchStatus'],
          playedAt: doc['playedAt'],
          gameType: doc['gameType'],
          isMVP: doc['isMVP'],
          goals: int.parse(doc['goals']));

      index = gameRecordList
          .indexWhere((record) => record.year == gameRecord.getYearPlayed());
      if (index > -1) {
        if (gameRecord.gameType == 'Football')
          gameRecordList[index].totalGoals += gameRecord.goals;

        if (gameRecord.isMVP) gameRecordList[index].isMVP = gameRecord.isMVP;

        if (gameRecord.matchStatus == 'W') gameRecordList[index].totalWins += 1;

        if (gameRecord.matchStatus == 'L')
          gameRecordList[index].totalLosses += 1;

        gameRecordList[index].totalPlayed += 1;

        if (gameRecord.matchStatus == 'D')
          gameRecordList[index].totalDraws += 1;
      } else {
        YearRecord yearRecord = YearRecord(
          year: gameRecord.getYearPlayed(),
          dateTimePlayed: gameRecord.playedAt.toDate(),
          totalDraws: 0,
          totalGoals: 0,
          totalLosses: 0,
          totalPlayed: 0,
          totalWins: 0,
          isMVP: false,
        );

        if (gameRecord.gameType == 'Football')
          yearRecord.totalGoals += gameRecord.goals;

        yearRecord.totalPlayed += 1;
        if (gameRecord.isMVP) yearRecord.isMVP = gameRecord.isMVP;

        if (gameRecord.matchStatus == 'W') yearRecord.totalWins += 1;

        if (gameRecord.matchStatus == 'L') yearRecord.totalLosses += 1;

        if (gameRecord.matchStatus == 'D') yearRecord.totalDraws += 1;
        gameRecordList.add(yearRecord);
      }
    }

    for (YearRecord record in gameRecordList) {
      record.displayRecord();
    }
    setState(() {
      isLoading = true;
    });
  }

  @override
  void initState() {
    getGameRecords();
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

  List<YearRecord> gameRecords = [];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // getGameRecords();
          // debugDataGenerator();
        },
      ),
      appBar: AppBar(
        title: Text('Game Records'),
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        child: GameData(
          gameRecords: gameRecordList,
        ),
      ),
    );
  }
}

class GameData extends StatelessWidget {
  GameData({this.gameRecords});
  final List<YearRecord> gameRecords;

  @override
  Widget build(BuildContext context) {
    return StickyGroupedListView<YearRecord, DateTime>(
      elements: gameRecords,
      order: StickyGroupedListOrder.DESC,
      groupBy: (YearRecord yearRecord) => yearRecord.dateTimePlayed,
      floatingHeader: true,
      groupSeparatorBuilder: (YearRecord yearRecord) => Container(),
      itemBuilder: (_, YearRecord yearRecord) {
        return TableRow(yearRecord: yearRecord);
      },
    );
  }
}

class TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: Text(
            'YEAR',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Text(
            'PL',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Text(
            'W',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Text(
            'D',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Text(
            'L',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Text(
            'MvP',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Center(
                  child: Text(
            'GO',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          ))),
        ],
      ),
    );
  }
}

class TableRow extends StatelessWidget {
  final YearRecord yearRecord;
  TableRow({@required this.yearRecord});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 8),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: Text(
            this.yearRecord.year,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Text(
            this.yearRecord.totalPlayed.toString(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Text(
            this.yearRecord.totalWins.toString(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Text(
            this.yearRecord.totalDraws.toString(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Text(
            this.yearRecord.totalLosses.toString(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Text(
            this.yearRecord.isMVP.toString(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          )),
          Expanded(
              child: Center(
                  child: Text(
            this.yearRecord.totalGoals.toString(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          ))),
        ],
      ),
    );
  }
}
