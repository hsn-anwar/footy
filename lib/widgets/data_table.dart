import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footy/models/game_models.dart';
import 'package:footy/shared/constants.dart';

class GameRecordsDataTable extends StatefulWidget {
  @override
  _GameRecordsDataTableState createState() => _GameRecordsDataTableState();
}

class _GameRecordsDataTableState extends State<GameRecordsDataTable> {
  bool showGameTypes = false;
  bool showRecords = false;
  String dropdownValue = 'None';
  List<String> items = [
    'None',
    'Football',
    'Tennis',
    'Field Hockey',
    'Ice Hockey'
  ];
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<YearRecord> gameRecordList = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text('Summary of played matches'),
              IconButton(
                icon: showGameTypes
                    ? Icon(
                        Icons.arrow_downward,
                        size: 14.0,
                      )
                    : Icon(
                        Icons.arrow_forward,
                        size: 14.0,
                      ),
                onPressed: () {
                  setState(() {
                    showGameTypes = !showGameTypes;
                  });
                },
              ),
            ],
          ),
        ),
        Visibility(
          visible: showGameTypes,
          child: Container(
            height: SizeConfig.blockSizeHorizontal * 15,
            color: Colors.green[100],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text('Category'),
                  Spacer(),
                  Container(
                    height: SizeConfig.blockSizeHorizontal * 10,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      underline: SizedBox(),
                      elevation: 16,
                      icon: Icon(Icons.arrow_drop_down),
                      style: TextStyle(color: Colors.green),
                      onChanged: (String newValue) {
                        setState(() {
                          if (newValue != 'None') {
                            showRecords = true;
                            gameRecordList.clear();
                            getGameRecords(newValue);
                            logger.d(newValue);
                          } else {
                            showRecords = false;
                          }
                          dropdownValue = newValue;
                        });
                      },
                      items:
                          items.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            '$value           ',
                            style: TextStyle(
                                color: value == 'None'
                                    ? Colors.red
                                    : Colors.green),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        gameRecordList.length != 0
            ? Visibility(
                visible: showRecords,
                child: SizedBox(
                  width: double.infinity,
                  height: SizeConfig.blockSizeVertical * 20,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Color(0x00000000)),
                        child: DataTable(
                            columnSpacing: SizeConfig.blockSizeHorizontal * 11,
                            dividerThickness: 0,
                            dataRowHeight: SizeConfig.blockSizeVertical * 4,
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
                            rows: gameRecordList
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
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  void getGameRecords(String gameType) async {
    setState(() {
      isLoading = true;
    });

    gameRecordList.clear();
    User user = _firebaseAuth.currentUser;
    Query query = _firebaseFirestore
        .collection("users")
        .doc("2dPRIeIss7Z2SpmpY4p4V8BdPDS2")
        .collection("gamesRecord")
        .where("gameType", isEqualTo: gameType);

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
          goals:
              doc.data()['goals'] == null ? 0 : int.parse(doc.data()['goals']));

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
          totalDraws: 0,
          totalGoals: 0,
          totalLosses: 0,
          totalPlayed: 0,
          totalWins: 0,
          isMVP: false,
          showGoals: false,
        );

        if (gameRecord.gameType == 'Football' ||
            gameRecord.gameType == 'Field Hockey') {
          yearRecord.showGoals = true;
          yearRecord.totalGoals += gameRecord.goals;
        }

        yearRecord.totalPlayed += 1;
        if (gameRecord.isMVP) yearRecord.isMVP = gameRecord.isMVP;

        if (gameRecord.matchStatus == 'W') yearRecord.totalWins += 1;

        if (gameRecord.matchStatus == 'L') yearRecord.totalLosses += 1;

        if (gameRecord.matchStatus == 'D') yearRecord.totalDraws += 1;
        gameRecordList.add(yearRecord);
      }
    }
    if (gameRecordList.length == 0) {
      Fluttertoast.showToast(
          msg: "No game data to display",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      gameRecordList
          .sort((a, b) => int.parse(b.year).compareTo(int.parse(a.year)));
    }
    for (YearRecord record in gameRecordList) {
      record.displayRecord();
    }
    setState(() {
      isLoading = true;
    });
  }
}
