import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';
// import 'package:footy/widgets/count_down_timer.dart';
import 'package:footy/widgets/timer.dart';
import 'package:footy/widgets/error_notification.dart';
import 'package:footy/widgets/time_picker.dart';
import 'package:footy/widgets/timer_button.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

enum ResumeMode {
  user,
  auto,
}

class TimerView extends StatefulWidget {
  static String id = 'timer_view';

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> with TickerProviderStateMixin {
  bool visibilityFlag1 = false;
  bool visibilityFlag2 = false;

  int primaryPresetSec = 00;
  int primaryPresetMin = 00;

  int secondaryPresetSec = 00;
  int secondaryPresetMin = 00;

  bool flag;
  bool _startFlag = true;
  bool _pauseFlag = true;
  bool _errorFlag = false;
  ResumeMode _resumeMode = ResumeMode.auto;

  final StopWatchTimer _primaryTimer = StopWatchTimer();
  final StopWatchTimer _secondaryTimer = StopWatchTimer();

  final TextEditingController _minController =
      TextEditingController(text: '00');
  final TextEditingController _secController =
      TextEditingController(text: '00');
  final _minFormKey = GlobalKey<FormState>();
  final _secFormKey = GlobalKey<FormState>();

  final TextEditingController _minController2 =
      TextEditingController(text: '00');
  final TextEditingController _secController2 =
      TextEditingController(text: '00');
  final _minFormKey2 = GlobalKey<FormState>();
  final _secFormKey2 = GlobalKey<FormState>();

  void onPrimaryTimerStopped(bool changeFlag) {
    setState(() {
      _startFlag = changeFlag;
    });
  }

  void startTimers() {
    _primaryTimer.onExecute.add(StopWatchExecute.start);
    _secondaryTimer.onExecute.add(StopWatchExecute.start);
  }

  void stopTimers() {
    _primaryTimer.onExecute.add(StopWatchExecute.stop);
    _secondaryTimer.onExecute.add(StopWatchExecute.stop);
  }

  void resetPrimaryTimer() {
    _primaryTimer.onExecute.add(StopWatchExecute.reset);
  }

  void resetSecondaryTimer() {
    _secondaryTimer.onExecute.add(StopWatchExecute.reset);
  }

  void resetAndStopPrimaryTimer() {
    _primaryTimer.onExecute.add(StopWatchExecute.reset);
    _primaryTimer.onExecute.add(StopWatchExecute.stop);
  }

  void resetAndStopSecondaryTimer() {
    _secondaryTimer.onExecute.add(StopWatchExecute.reset);
    _secondaryTimer.onExecute.add(StopWatchExecute.stop);
  }

  void resetAndStopTimers() {
    resetAndStopPrimaryTimer();
    resetAndStopSecondaryTimer();
  }

  int getTimeInMilliseconds({int hours = 0, int mins = 0, int secs = 0}) {
    return ((hours * 120) + (mins * 60) + secs) * 1000;
  }

  void startButtonFunctionality() {
    setState(() {
      if (primaryPresetMin > 0 ||
          primaryPresetSec > 0 && secondaryPresetMin > 0 ||
          secondaryPresetSec > 0) {
        _errorFlag = false;
        resetAndStopTimers();
        _startFlag = false;
        visibilityFlag1 = false;
        visibilityFlag2 = false;
        startTimers();
      } else {
        setState(() {
          _errorFlag = true;
        });
      }
    });
  }

  void pauseButtonFunctionality() {
    if (_primaryTimer.isRunning && _secondaryTimer.isRunning) {
      _errorFlag = false;
      setState(() {
        _resumeMode = ResumeMode.user;
        stopTimers();
        _pauseFlag = false;
      });
    }
  }

  void resumeButtonFunctionality() {
    if (_resumeMode == ResumeMode.auto) {
      setState(() {
        _pauseFlag = true;
        resetSecondaryTimer();
        startTimers();
      });
    } else if (_resumeMode == ResumeMode.user) {
      setState(() {
        _pauseFlag = true;

        _resumeMode = ResumeMode.auto;
        startTimers();
      });
    }
  }

  void stopButtonFunctionality() {
    setState(() {
      _startFlag = !_startFlag;
      resetAndStopTimers();
    });
  }

  void callSetState() {
    setState(() {});
  }

  @override
  void dispose() async {
    super.dispose();
    await _primaryTimer.dispose();
    await _secondaryTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Timer'.toUpperCase()),
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        child: SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: SizeConfig.blockSizeVertical * 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!_primaryTimer.isRunning &&
                              !_secondaryTimer.isRunning &&
                              _startFlag) {
                            resetAndStopPrimaryTimer();

                            visibilityFlag1 = !visibilityFlag1;
                            visibilityFlag2 = false;
                          }
                        });
                      },
                      child: Container(
                        width: SizeConfig.screenWidth,
                        child: Column(
                          children: [
                            Text(
                              'Game Duration'.toUpperCase(),
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical * 3,
                            ),
                            CountDownTimer(
                              stopWatchTimer: _primaryTimer,
                              secondaryTimer: _secondaryTimer,
                              mins: primaryPresetMin,
                              secs: primaryPresetSec,
                              soundFlag: false,
                              callSetState: callSetState,
                              onPrimaryTimerStopped: onPrimaryTimerStopped,
                            ),
                            Visibility(
                              visible: visibilityFlag1,
                              child: Column(
                                children: [
                                  TimePicker(
                                    minController: _minController,
                                    secController: _secController,
                                    minFormKey: _minFormKey,
                                    secFormKey: _secFormKey,
                                  ),
                                  RaisedButton(
                                    color: Colors.green,
                                    child: Text(
                                      'Confirm',
                                      style: kButtonTextStyle,
                                    ),
                                    onPressed: () {
                                      if (_minFormKey.currentState.validate() &&
                                          _secFormKey.currentState.validate()) {
                                        setState(() {
                                          // _startFlag = false;

                                          primaryPresetMin = int.parse(
                                              _minController.value.text);
                                          primaryPresetSec = int.parse(
                                              _secController.value.text);
                                          visibilityFlag1 = false;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 7,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!_primaryTimer.isRunning &&
                              !_secondaryTimer.isRunning &&
                              _startFlag) {
                            resetAndStopSecondaryTimer();
                            visibilityFlag2 = !visibilityFlag2;
                            visibilityFlag1 = false;
                          }
                        });
                      },
                      child: Container(
                        width: SizeConfig.screenWidth,
                        child: Column(
                          children: [
                            Text(
                              'Goalkeeper/Player substitution'.toUpperCase(),
                              style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical * 3,
                            ),
                            CountDownTimer(
                              stopWatchTimer: _secondaryTimer,
                              mins: secondaryPresetMin,
                              secs: secondaryPresetSec,
                              primaryMins: primaryPresetMin,
                              primarySecs: primaryPresetSec,
                              callSetState: callSetState,
                              soundFlag: true,
                              primaryTimer: _primaryTimer,
                            ),
                            Visibility(
                              visible: visibilityFlag2,
                              child: Column(
                                children: [
                                  TimePicker(
                                    minController: _minController2,
                                    secController: _secController2,
                                    minFormKey: _minFormKey2,
                                    secFormKey: _secFormKey2,
                                  ),
                                  RaisedButton(
                                    color: Colors.green,
                                    child: Text(
                                      'Confirm',
                                      style: kButtonTextStyle,
                                    ),
                                    onPressed: () {
                                      if (_minFormKey2.currentState
                                              .validate() &&
                                          _secFormKey2.currentState
                                              .validate()) {
                                        setState(() {
                                          // _startFlag = false;
                                          visibilityFlag2 = false;
                                          secondaryPresetMin = int.parse(
                                              _minController2.value.text);
                                          secondaryPresetSec = int.parse(
                                              _secController2.value.text);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 4,
              ),
              _errorFlag ? ErrorNotification() : Container(),
              SizedBox(
                height: SizeConfig.blockSizeVertical * 3,
              ),
              _startFlag && !_primaryTimer.isRunning
                  ? TimerButton(
                      buttonLabel: 'Start',
                      buttonColor: Colors.green,
                      minWidth: 65,
                      buttonFunction: () {
                        startButtonFunctionality();
                      })
                  : ButtonBar(
                      alignment: MainAxisAlignment.center,
                      children: [
                        _primaryTimer.isRunning
                            ? TimerButton(
                                buttonLabel: 'Pause',
                                buttonColor: Colors.orange[900],
                                buttonFunction: () {
                                  pauseButtonFunctionality();
                                },
                              )
                            : TimerButton(
                                buttonLabel: 'Resume',
                                buttonColor: Colors.green,
                                buttonFunction: () {
                                  resumeButtonFunctionality();
                                },
                              ),
                        TimerButton(
                          buttonLabel: 'Stop',
                          buttonColor: Colors.red[900],
                          buttonFunction: () {
                            stopButtonFunctionality();
                          },
                        )
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
