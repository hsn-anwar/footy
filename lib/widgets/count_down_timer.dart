import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:audioplayers/audio_cache.dart';

class CountDownTimer extends StatelessWidget {
  final StopWatchTimer stopWatchTimer;
  final int mins;
  final int secs;
  final bool soundFlag;
  final Function callSetState;
  final onPrimaryTimerStopped;
  final double radius;
  final double fontSize;

  //  _primaryTimer passed to secondary CountDownTimer
  //  to check status of PrimaryCountDownTimer
  final StopWatchTimer primaryTimer;

  CountDownTimer({
    @required this.stopWatchTimer,
    @required this.mins,
    @required this.secs,
    @required this.soundFlag,
    this.primaryTimer,
    this.callSetState,
    this.onPrimaryTimerStopped,
    this.radius,
    this.fontSize,
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
        String secondsOnly = StopWatchTimer.getDisplayTime(
          _timerValue,
          milliSecond: false,
          hours: false,
          minute: false,
        );
        //
        // if (soundFlag) {
        //   if (_liveCount >= _msecs) {
        //     if (this.soundFlag && this.stopWatchTimer.isRunning) {
        //       playSound();
        //     }
        //     this.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
        //   }
        // } else {
        //   if (_liveCount >= _msecs && this.primaryTimer.isRunning) {
        //     this.stopWatchTimer.onExecute.add(StopWatchExecute.reset);
        //     this.stopWatchTimer.onExecute.add(StopWatchExecute.start);
        //   } else if (!this.primaryTimer.isRunning && _liveCount >= _msecs) {
        //     this.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
        //   }
        // }

        if (soundFlag) {
          if (_liveCount >= _msecs) {
            if (this.soundFlag && this.stopWatchTimer.isRunning) {
              playSound();
            }
            this.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
            this.primaryTimer.onExecute.add(StopWatchExecute.stop);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => this.callSetState());
          }
        } else {
          if (_liveCount >= _msecs) {
            this.stopWatchTimer.onExecute.add(StopWatchExecute.stop);

            WidgetsBinding.instance
                .addPostFrameCallback((_) => this.onPrimaryTimerStopped(true));
            WidgetsBinding.instance
                .addPostFrameCallback((_) => this.callSetState());
          }
        }

        // if (soundFlag) {
        //   if (_liveCount >= _msecs) {
        //     if (this.soundFlag && this.stopWatchTimer.isRunning) {
        //       playSound();
        //     }
        //     this.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
        //     this.primaryTimer.onExecute.add(StopWatchExecute.stop);
        //   }
        // } else {
        //   if (_liveCount >= _msecs) {
        //     this.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
        //   }
        // }

        return radius == null
            ? Column(
                children: <Widget>[
                  CircularPercentIndicator(
                    radius: radius ?? 140,
                    percent: _liveCount / _msecs > 1 ? 1 : _liveCount / _msecs,
                    center: Text(
                      displayTimer,
                      style: TextStyle(
                        fontSize: this.fontSize ?? 40,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  CircularPercentIndicator(
                    progressColor: Colors.green,
                    backgroundColor: Colors.red[400],
                    radius: radius,
                    percent:
                        _liveCount / _msecs > 1 ? 1 : _liveCount / (_msecs),
                    center: Text(
                      '${secondsOnly == '00' ? '60' : secondsOnly}\nsecs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: this.fontSize,
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
