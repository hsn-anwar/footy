import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:audioplayers/audio_cache.dart';

class CountDownTimer extends StatelessWidget {
  final StopWatchTimer stopWatchTimer;
  final int mins;
  final int secs;
  final bool soundFlag;

  //  _primaryTimer passed to secondary CountDownTimer
  //  to check status of PrimaryCountDownTimer
  final StopWatchTimer primaryTimer;

  CountDownTimer({
    @required this.stopWatchTimer,
    @required this.mins,
    @required this.secs,
    @required this.soundFlag,
    this.primaryTimer,
  });

  int getTimeInMilliseconds({int mins = 0, int secs = 0}) {
    return ((mins * 60) + secs) * 1000;
  }

  void playSound() {
    final player = AudioCache();
    player.play('referee_whistle.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: this.stopWatchTimer.rawTime,
      initialData: 0,
      builder: (context, snapshot) {
        int _liveCount = snapshot.data;
        int _msecs = getTimeInMilliseconds(mins: this.mins, secs: this.secs);
        int _timerValue = _msecs + 999 - _liveCount;
        String displayTimer = StopWatchTimer.getDisplayTime(
          _timerValue,
          milliSecond: false,
          hours: false,
        );

        if (soundFlag) {
          if (_liveCount >= _msecs) {
            if (this.soundFlag && this.stopWatchTimer.isRunning) {
              playSound();
            }
            this.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
          }
        } else {
          if (_liveCount >= _msecs && this.primaryTimer.isRunning) {
            this.stopWatchTimer.onExecute.add(StopWatchExecute.reset);
            this.stopWatchTimer.onExecute.add(StopWatchExecute.start);
          } else if (!this.primaryTimer.isRunning && _liveCount >= _msecs) {
            this.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
          }
        }

        return Column(
          children: <Widget>[
            CircularPercentIndicator(
              radius: 140,
              percent: _liveCount / _msecs > 1 ? 1 : _liveCount / _msecs,
              center: Text(
                displayTimer,
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'Helvetica',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
