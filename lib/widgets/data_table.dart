import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footy/models/game_models.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/widgets/table_components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:footy/utilities/functions.dart';

class GameRecordsDataTable extends StatefulWidget {
  @override
  _GameRecordsDataTableState createState() => _GameRecordsDataTableState();
}

class _GameRecordsDataTableState extends State<GameRecordsDataTable> {
  bool showGameTypes = false;
  bool showRecords = false;
  String dropdownValue;
  Utils utils = Utils();
  bool isLoading = false;
  List<String> gameTypes = [];
  Map<String, List<YearRecord>> allGameRecords = {};
  bool isGameDataFetched = false;
  bool result;
  bool getInitialDropDownValue() {
    allGameRecords.forEach((key, value) {
      if (key == 'Football')
        gameTypes.insert(0, key);
      else
        gameTypes.add(key);
    });
    logger.d(gameTypes);
    if (gameTypes.isEmpty) return false;

    if (gameTypes.contains('Football'))
      dropdownValue = 'Football';
    else
      dropdownValue = gameTypes[0];
    return true;
  }

  void onShowSummary() async {
    if (!isGameDataFetched) {
      isGameDataFetched = true;
      if (allGameRecords.isEmpty) {
        result = await initializeRecords();
      }
      if (result) {
        setState(() {
          showGameTypes = !showGameTypes;
        });
      } else {
        Fluttertoast.showToast(
          msg: "No Game Data to Show",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } else {
      setState(() {
        isGameDataFetched = false;
        showGameTypes = !showGameTypes;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(
                'Summary of Played Matches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: showGameTypes
                    ? Icon(FontAwesomeIcons.arrowAltCircleDown, size: 18.0)
                    : Icon(FontAwesomeIcons.arrowAltCircleRight, size: 18.0),
                onPressed: onShowSummary,
              ),
            ],
          ),
        ),
        Visibility(
          visible: showGameTypes,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Spacer(),
                Container(
                  height: SizeConfig.blockSizeHorizontal * 10,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(10)),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    underline: SizedBox(),
                    elevation: 16,
                    icon: Icon(
                      FontAwesomeIcons.chevronCircleDown,
                      size: 16,
                      color: Colors.green,
                    ),
                    style: TextStyle(color: Colors.green),
                    onChanged: (String newValue) {
                      setState(() {
                        logger.d(newValue);
                        dropdownValue = newValue;
                      });
                    },
                    items:
                        gameTypes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          '$value           ',
                          style: TextStyle(
                              color:
                                  value == 'None' ? Colors.red : Colors.green),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        isLoading
            ? Container(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Visibility(
                visible: showGameTypes,
                child: GameRecordTable(
                  gameRecordList: allGameRecords[dropdownValue],
                ),
              )
      ],
    );
  }

  Future<bool> initializeRecords() async {
    allGameRecords.clear();
    setState(() {
      isLoading = true;
    });

    // User user = _firebaseAuth.currentUser;
    // Query query = _firebaseFirestore
    //     .collection("users")
    //     .doc("2dPRIeIss7Z2SpmpY4p4V8BdPDS2")
    //     .collection("gamesRecord");
    // List<YearRecord> gameTypeRecords = [];
    //
    // QuerySnapshot querySnapshot = await query.get();
    // List<DocumentSnapshot> docs = querySnapshot.docs;
    // logger.i(docs.length);
    // int index;
    // for (DocumentSnapshot doc in docs) {
    //   GameRecord gameRecord = GameRecord(
    //       gameID: doc.data()['gameID'],
    //       matchStatus: doc.data()['matchStatus'],
    //       playedAt: doc.data()['playedAt'],
    //       gameType: doc.data()['gameType'],
    //       isMVP: doc.data()['isMVP'],
    //       goals: int.parse(doc.data()['goals'] ?? '0'));
    //
    //   if (!allGameRecords.containsKey(gameRecord.gameType)) {
    //     allGameRecords[gameRecord.gameType] = [];
    //   }
    //
    //   gameTypeRecords = allGameRecords[gameRecord.gameType];
    //
    //   index = gameTypeRecords
    //       .indexWhere((record) => record.year == gameRecord.getYearPlayed());
    //
    //   if (index == -1) {
    //     YearRecord yearRecord = YearRecord(
    //       year: gameRecord.getYearPlayed(),
    //       totalDraws: 0,
    //       totalGoals: 0,
    //       totalLosses: 0,
    //       totalPlayed: 0,
    //       totalWins: 0,
    //       timesMVP: 0,
    //       showGoals: false,
    //       dateTimePlayed: gameRecord.playedAt.toDate(),
    //     );
    //
    //     gameTypeRecords.add(yearRecord);
    //     index = gameTypeRecords
    //         .indexWhere((record) => record.year == gameRecord.getYearPlayed());
    //   }
    //
    //   if (gameRecord.gameType == 'Football' ||
    //       gameRecord.gameType == 'Field Hockey') {
    //     gameTypeRecords[index].showGoals = true;
    //     gameTypeRecords[index].totalGoals += gameRecord.goals;
    //   }
    //
    //   gameTypeRecords[index].totalPlayed += 1;
    //   if (gameRecord.isMVP) gameTypeRecords[index].timesMVP += 1;
    //
    //   if (gameRecord.matchStatus == 'W') gameTypeRecords[index].totalWins += 1;
    //
    //   if (gameRecord.matchStatus == 'L')
    //     gameTypeRecords[index].totalLosses += 1;
    //
    //   if (gameRecord.matchStatus == 'D') gameTypeRecords[index].totalDraws += 1;
    //   gameTypeRecords
    //       .sort((a, b) => int.parse(b.year).compareTo(int.parse(a.year)));
    //   allGameRecords[gameRecord.gameType] = gameTypeRecords;
    // }
    allGameRecords = await utils.getAllUserGameRecords();
    for (MapEntry<String, List<YearRecord>> entry in allGameRecords.entries) {
      logger.wtf(entry.key);
      for (YearRecord yearRecord in entry.value) {
        yearRecord.displayRecord();
      }
    }
    bool isEmpty = getInitialDropDownValue();
    setState(() {
      isLoading = false;
    });
    return isEmpty;
  }
}
