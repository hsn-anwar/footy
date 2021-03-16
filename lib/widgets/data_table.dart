import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footy/models/game_models.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/widgets/table_components.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:footy/Utils/functions.dart';

import '../const.dart';

class GameRecordsDataTable extends StatefulWidget {
  final String userID;

  const GameRecordsDataTable({Key key, this.userID}) : super(key: key);

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
      setState(() {
        showGameTypes = !showGameTypes;
      });
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
                child: allGameRecords.isNotEmpty
                    ? GameRecordTable(
                        gameRecordList: allGameRecords[dropdownValue],
                      )
                    : Container(
                        child: Text(
                          'NO GAME DATA TO SHOW!',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 18,
                          ),
                        ),
                      ),
              )
      ],
    );
  }

  Future<bool> initializeRecords() async {
    logger.wtf("In initializing records wtf");
    allGameRecords.clear();
    setState(() {
      isLoading = true;
    });

    allGameRecords = await utils.getAllUserGameRecords(widget.userID);
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
    // logger.wtf(allGameRecords);
    return isEmpty;
  }
}
