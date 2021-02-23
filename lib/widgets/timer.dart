import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:audioplayers/audio_cache.dart';

class CountDownTimer extends StatefulWidget {
  final StopWatchTimer stopWatchTimer;
  final StopWatchTimer primaryTimer;
  final StopWatchTimer secondaryTimer;
  final int mins;
  final int secs;
  final int primaryMins;
  final int primarySecs;
  final bool soundFlag;
  final Function onCycleComplete;
  final onPrimaryTimerStopped;
  final double radius;
  final double fontSize;

  CountDownTimer({
    @required this.stopWatchTimer,
    @required this.mins,
    @required this.secs,
    @required this.soundFlag,
    this.primaryMins,
    this.primarySecs,
    this.primaryTimer,
    this.secondaryTimer,
    this.onCycleComplete,
    this.onPrimaryTimerStopped,
    this.radius,
    this.fontSize,
  });

  @override
  _CountDownTimerState createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  int getTimeInMilliseconds({int mins = 0, int secs = 0}) {
    return ((mins * 60) + secs) * 1000;
  }

  void playSound() {
    final player = AudioCache();
    player.play('referee_whistle.mp3');
  }

  bool isPrimaryRunning = true;
  int pMilliSeconds;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stopWatchTimer.rawTime,
      initialData: 0,
      builder: (context, snapshot) {
        int _liveCount = snapshot.data;

        int _mSecs =
            getTimeInMilliseconds(mins: widget.mins, secs: widget.secs);
        if (widget.primaryMins != null || widget.primarySecs != null)
          pMilliSeconds = getTimeInMilliseconds(
              mins: widget.primaryMins, secs: widget.primarySecs);
        int _timerValue = _mSecs + 999 - _liveCount;
        String displayTimer = StopWatchTimer.getDisplayTime(
          _timerValue,
          milliSecond: false,
          hours: false,
        );

        if (widget.soundFlag) {
          if (_liveCount >= _mSecs) {
            if (widget.soundFlag && widget.stopWatchTimer.isRunning) {
              playSound();
            }
            if (widget.soundFlag && widget.primaryTimer.isRunning) {
              // if (_liveCount < pMilliSeconds) {
              widget.stopWatchTimer.onExecute.add(StopWatchExecute.reset);
              widget.stopWatchTimer.onExecute.add(StopWatchExecute.start);
              // } else if (_liveCount == _mSecs) {
              //   print('STOP');
              // }
            } else {
              widget.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
            }
            print('Timer value: $_timerValue');
            WidgetsBinding.instance
                .addPostFrameCallback((_) => widget.onCycleComplete());
          }
        } else {
          if (_liveCount >= _mSecs) {
            // if (widget.stopWatchTimer.isRunning) {
            //   playSound();
            // }

            widget.stopWatchTimer.onExecute.add(StopWatchExecute.stop);
            // widget.secondaryTimer.onExecute.add(StopWatchExecute.stop);

            WidgetsBinding.instance.addPostFrameCallback(
                (_) => widget.onPrimaryTimerStopped(true));
            WidgetsBinding.instance
                .addPostFrameCallback((_) => widget.onCycleComplete());
          }
        }

        return Column(
          children: <Widget>[
            CircularPercentIndicator(
              radius: 140,
              percent: _liveCount / _mSecs > 1 ? 1 : _liveCount / _mSecs,
              center: Text(
                _timerValue <= 0 ? '00:00' : displayTimer,
                // displayTimer,
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
