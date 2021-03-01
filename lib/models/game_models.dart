import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

Logger logger = Logger();

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
  final DateTime dateTimePlayed;
  int totalPlayed = 0;
  int totalWins = 0;
  int totalLosses = 0;
  int totalDraws = 0;
  int totalGoals = 0;
  int timesMVP = 0;
  bool showGoals = false;

  YearRecord({
    @required this.year,
    @required this.dateTimePlayed,
    this.totalPlayed,
    this.totalWins,
    this.totalLosses,
    this.totalDraws,
    this.totalGoals,
    this.showGoals,
    this.timesMVP,
  });

  void displayRecord() {
    logger.i("year: $year\n"
        "games: $totalPlayed\n"
        "wins: $totalWins\n"
        "losses: $totalLosses\n"
        "draws: $totalDraws\n"
        "goals: $totalGoals\n"
        "isMVP: $timesMVP\n");
  }
}
