import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/widgets/count_down_timer.dart';
import 'package:footy/widgets/time_picker.dart';
import 'package:footy/widgets/timer_control_button.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

// import 'package:numberpicker/numberpicker.dart';
// import 'package:flutter_duration_picker/flutter_duration_picker.dart';

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

  bool _startFlag = false;
  bool _pauseFlag = true;

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
    _primaryTimer.onExecute.add(StopWatchExecute.stop);
  }

  void resetSecondaryTimer() {
    _secondaryTimer.onExecute.add(StopWatchExecute.reset);
    _secondaryTimer.onExecute.add(StopWatchExecute.stop);
  }

  void resetTimers() {
    _primaryTimer.onExecute.add(StopWatchExecute.reset);
    _primaryTimer.onExecute.add(StopWatchExecute.stop);

    _secondaryTimer.onExecute.add(StopWatchExecute.reset);
    _secondaryTimer.onExecute.add(StopWatchExecute.stop);
  }

  int getTimeInMilliseconds({int hours = 0, int mins = 0, int secs = 0}) {
    return ((hours * 120) + (mins * 60) + secs) * 1000;
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
    // _initializeNumberPickers();
    return Scaffold(
      appBar: AppBar(
        title: Text('Timer'.toUpperCase()),
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        child: SingleChildScrollView(
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
                              !_secondaryTimer.isRunning) {
                            resetPrimaryTimer();

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
                              mins: primaryPresetMin,
                              secs: primaryPresetSec,
                              soundFlag: true,
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
                                          _startFlag = false;

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
                              !_secondaryTimer.isRunning) {
                            resetSecondaryTimer();
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
                              soundFlag: false,
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
                                          _startFlag = false;
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
                height: SizeConfig.blockSizeVertical * 7,
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                buttonMinWidth: SizeConfig.blockSizeHorizontal * 30,
                children: _startFlag
                    ? [
                        _pauseFlag
                            ? TimerControlButton(
                                buttonLabel: 'Pause',
                                buttonColor: Colors.orange[900],
                                buttonFunction: () {
                                  if (_primaryTimer.isRunning &&
                                      _secondaryTimer.isRunning) {
                                    setState(() {
                                      stopTimers();
                                      _pauseFlag = false;
                                    });
                                  }
                                },
                              )
                            : TimerControlButton(
                                buttonLabel: 'Resume',
                                buttonColor: Colors.green,
                                buttonFunction: () {
                                  setState(() {
                                    startTimers();
                                    _pauseFlag = true;
                                  });
                                }),
                        SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 1,
                        ),
                        TimerControlButton(
                          buttonLabel: 'Stop',
                          buttonColor: Colors.red[900],
                          buttonFunction: () {
                            setState(() {
                              _startFlag = !_startFlag;
                              resetTimers();
                            });
                          },
                        )
                      ]
                    : [
                        ButtonTheme(
                          minWidth: SizeConfig.blockSizeHorizontal * 65,
                          child: TimerControlButton(
                            buttonLabel: 'Start',
                            buttonColor: Colors.green,
                            buttonFunction: () {
                              setState(() {
                                _startFlag = true;
                                visibilityFlag1 = false;
                                visibilityFlag2 = false;
                                startTimers();
                              });
                            },
                          ),
                        ),
                      ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// class Timer extends StatefulWidget {
//   @override
//   _TimerState createState() => _TimerState();
// }
//
// class _TimerState extends State<Timer> {
//   @override
//   Widget build(BuildContext context) {
//     return               Column(
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               visibilityFlag1 = !visibilityFlag1;
//             });
//           },
//           child: Container(
//             width: SizeConfig.screenWidth,
//             child: Column(
//               children: [
//                 Text(
//                   'Game Duration'.toUpperCase(),
//                   style: kLabelStyle,
//                 ),
//                 CountDownTimer(
//                   stopWatchTimer: _primaryTimer,
//                   mins: primaryPresetMin,
//                   secs: primaryPresetSec,
//                   soundFlag: true,
//                 ),
//                 Visibility(
//                   visible: visibilityFlag1,
//                   child: Column(
//                     children: [
//                       TimePicker(
//                         minController: _minController,
//                         secController: _secController,
//                         minFormKey: _minFormKey,
//                         secFormKey: _secFormKey,
//                       ),
//                       RaisedButton(
//                         color: Colors.green,
//                         child: Text(
//                           'Set Timer',
//                           style: kButtonTextStyle,
//                         ),
//                         onPressed: () {
//                           if (_minFormKey.currentState.validate() &&
//                               _secFormKey.currentState.validate()) {
//                             setState(() {
//                               primaryPresetMin = int.parse(
//                                   _minController.value.text);
//                               primaryPresetSec = int.parse(
//                                   _secController.value.text);
//                               visibilityFlag1 = false;
//                             });
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
