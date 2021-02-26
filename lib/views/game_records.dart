import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:footy/shared/constants.dart';
import 'package:logger/logger.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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

        if (gameRecord.matchStatus == 'D')
          gameRecordList[index].totalDraws += 1;
      } else {
        YearRecord yearRecord = YearRecord(
          year: gameRecord.getYearPlayed(),
          totalDraws: 0,
          totalGoals: 0,
          totalLosses: 0,
          totalPlayed: 0,
          totalWins: 0,
          isMVP: false,
        );

        if (gameRecord.gameType == 'Football')
          yearRecord.totalGoals += gameRecord.goals;

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

  int gameID = 999;
  bool debugFlag = false;
  String status;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          getGameRecords();
          //   gameID--;
          //   debugFlag = !debugFlag;
          //   if (gameID % 2 == 0) {
          //     status = 'W';
          //   } else if (gameID % 3 == 0) {
          //     status = 'L';
          //   } else {
          //     status = 'D';
          //   }
          //   await _firebaseFirestore
          //       .collection("users")
          //       .doc("2dPRIeIss7Z2SpmpY4p4V8BdPDS2")
          //       .collection("gamesRecord")
          //       .add({
          //     "gameID": "$gameID",
          //     "isMVP": "$debugFlag",
          //     "matchStatus": status,
          //     "gameType": "Football",
          //   });
        },
      ),
      appBar: AppBar(
        title: Text('Game Records'),
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        child: GameRecordsDataTable(
          record: gameRecordList,
        ),
      ),
    );
  }
}

class GameRecordsDataTable extends StatelessWidget {
  final List<YearRecord> record;

  const GameRecordsDataTable({Key key, @required this.record})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SizedBox(
      width: double.infinity,
      // height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              columnSpacing: SizeConfig.blockSizeHorizontal * 11,
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'Year',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'PL',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'W',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'D',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'L',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'MvP',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'GO',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              rows: this
                  .record
                  .map((e) => DataRow(cells: [
                        DataCell(Text(e.year.toString())),
                        DataCell(Text(e.totalPlayed.toString())),
                        DataCell(Text(e.totalWins.toString())),
                        DataCell(Text(e.totalDraws.toString())),
                        DataCell(Text(e.totalLosses.toString())),
                        DataCell(Text(e.isMVP.toString())),
                        DataCell(Text(e.totalGoals.toString())),
                      ]))
                  .toList()),
        ),
      ),
    );
  }
}

class GameRecord {
  final String gameID;
  final String gameType;
  final bool isMVP;
  final int goals;
  final String matchStatus;
  final Timestamp playedAt;

  GameRecord(
      {@required this.gameID,
      @required this.gameType,
      @required this.isMVP,
      @required this.goals,
      @required this.matchStatus,
      @required this.playedAt});

  getYearPlayed() {
    if (this.playedAt != null) {
      DateTime dateTime = this.playedAt.toDate();
      DateFormat _formatter = DateFormat('yyyy');
      String year = _formatter.format(dateTime);
      return year;
    }
    return null;
  }
}

class YearRecord {
  final String year;
  int totalPlayed = 0;
  int totalWins = 0;
  int totalLosses = 0;
  int totalDraws = 0;
  int totalGoals = 0;
  bool isMVP = false;

  YearRecord({
    @required this.year,
    this.totalPlayed,
    this.totalWins,
    this.totalLosses,
    this.totalDraws,
    this.totalGoals,
    this.isMVP,
  });

  void displayRecord() {
    logger.i("year: $year\n"
        "games: $totalPlayed\n"
        "wins: $totalWins\n"
        "losses: $totalLosses\n"
        "draws: $totalDraws\n"
        "goals: $totalGoals\n"
        "isMVP: $isMVP\n");
  }
}
