import 'package:flutter/material.dart';
import 'package:footy/models/game_models.dart';
import 'package:footy/shared/constants.dart';

class GameRecordTable extends StatelessWidget {
  final List<YearRecord> gameRecordList;

  GameRecordTable({@required this.gameRecordList});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      width: SizeConfig.blockSizeHorizontal * 100,
      child: Table(
        children: [
          TableRow(children: [
            GameRecordTableHeader(showGoals: gameRecordList[0].showGoals),
          ]),
          TableRow(children: [
            Container(
              height: SizeConfig.blockSizeVertical * 15,
              child: ListView.builder(
                  primary: false,
                  itemCount: gameRecordList.length,
                  itemBuilder: (context, index) {
                    return GameRecordTableRow(
                      yearRecord: gameRecordList[index],
                    );
                  }),
            ),
          ])
        ],
      ),
    );
  }
}

class GameRecordTableHeader extends StatelessWidget {
  final bool showGoals;

  const GameRecordTableHeader({Key key, this.showGoals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Center(
            child: Text(
              'YEAR',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              'PL',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              'W',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              'D',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              'L',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              'MvP',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45),
            ),
          )),
          this.showGoals
              ? Expanded(
                  child: Center(
                  child: Text(
                    'GO',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45),
                  ),
                ))
              : Container(),
        ],
      ),
    );
  }
}

class GameRecordTableRow extends StatelessWidget {
  final YearRecord yearRecord;
  GameRecordTableRow({@required this.yearRecord});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Center(
            child: Text(
              this.yearRecord.year,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              this.yearRecord.totalPlayed.toString(),
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              this.yearRecord.totalWins.toString(),
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              this.yearRecord.totalDraws.toString(),
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              this.yearRecord.totalLosses.toString(),
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          )),
          Expanded(
              child: Center(
            child: Text(
              this.yearRecord.timesMVP.toString(),
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          )),
          yearRecord.showGoals
              ? Expanded(
                  child: Center(
                  child: Text(
                    this.yearRecord.totalGoals.toString(),
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ))
              : Container(),
        ],
      ),
    );
  }
}
