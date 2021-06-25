import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/widgets/time_picker.dart';
import 'package:footy/widgets/timer_button.dart';
import 'package:logger/logger.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
// import 'package:audioplayers/audio_cache.dart';

import '../const.dart';

Logger logger = Logger();

enum TimerType {
  Primary,
  Secondary,
}

enum ResumeMode {
  user,
  auto,
}

class TimerScreen extends StatefulWidget {
  static final String id = "timer_screen";

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool visibilityFlag1 = false;
  bool visibilityFlag2 = false;

  bool isPrimaryTimerRunning = false;
  bool isSecondaryTimerRunning = false;
  bool isPaused = false;

  bool isPrimarySet = false;
  bool isSecondarySet = false;

  final TextEditingController _primaryMinsController =
      TextEditingController(text: '00');
  final TextEditingController _primarySecsController =
      TextEditingController(text: '00');

  final TextEditingController _secondaryMinsController =
      TextEditingController(text: '00');
  final TextEditingController _secondarySecsController =
      TextEditingController(text: '00');

  final _primaryMinsFormKey = GlobalKey<FormState>();
  final _primarySecsFormKey = GlobalKey<FormState>();

  final _secondaryMinsFormKey = GlobalKey<FormState>();
  final _secondarySecsFormKey = GlobalKey<FormState>();

  int primaryPresetSecs = 00;
  int primaryPresetMins = 00;
  int secondaryPresetSecs = 00;
  int secondaryPresetMins = 00;

  List<int> timerDivisions = [];
  int currentCycle = 0;

  @override
  void initState() {
    super.initState();
  }

  CountDownController primaryCounterController = CountDownController();
  CountDownController secondaryCounterController = CountDownController();

  Color timerFillColor = kStoppedFillColor;
  Color timerBcgColor = kStoppedBackgroundColor;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(title: Text('Timer')),
      body: Container(
        width: SizeConfig.screenWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    'Game Duration'.toUpperCase(),
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                    ),
                  ),
                  // Text(
                  //   primaryCounterController,
                  //   style: TextStyle(
                  //     fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                  //   ),
                  // ),
                  GestureDetector(
                    onTap: () {
                      if (!isPrimaryTimerRunning) {
                        setState(() {
                          visibilityFlag1 = !visibilityFlag1;
                        });
                      }
                    },
                    child: CountDownTimer(
                      timerController: primaryCounterController,
                      onStart: () => onTimersStart(TimerType.Primary),
                      onComplete: () => onTimersComplete(TimerType.Primary),
                      bcgColor: isPrimarySet
                          ? kRunningBackgroundColor
                          : kStoppedBackgroundColor,
                      fillColor: isPrimaryTimerRunning
                          ? kRunningFillColor
                          : kStoppedFillColor,
                      secondsOnly: false,
                    ),
                  ),
                  Visibility(
                    visible: visibilityFlag1,
                    child: Column(
                      children: [
                        TimePicker(
                          minController: _primaryMinsController,
                          secController: _primarySecsController,
                          minFormKey: _primaryMinsFormKey,
                          secFormKey: _primarySecsFormKey,
                        ),
                        ElevatedButton(
                          child: Text(
                            'Confirm',
                            style: kButtonTextStyle,
                          ),
                          onPressed: () => validateAndSetTimer(
                            TimerType.Primary,
                            _primaryMinsFormKey,
                            _primarySecsFormKey,
                            _primaryMinsController.value.text,
                            _primarySecsController.value.text,
                            primaryCounterController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Game Interval'.toUpperCase(),
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!isSecondaryTimerRunning) {
                        setState(() {
                          visibilityFlag2 = !visibilityFlag2;
                        });
                      }
                    },
                    child: CountDownTimer(
                      timerController: secondaryCounterController,
                      onStart: () => onTimersStart(TimerType.Secondary),
                      onComplete: () => onTimersComplete(TimerType.Secondary),
                      bcgColor: isSecondarySet
                          ? kRunningBackgroundColor
                          : kStoppedBackgroundColor,
                      fillColor: isSecondaryTimerRunning
                          ? kRunningFillColor
                          : kStoppedFillColor,
                      secondsOnly: false,
                    ),
                  ),
                  Visibility(
                    visible: visibilityFlag2,
                    child: Column(
                      children: [
                        TimePicker(
                          minController: _secondaryMinsController,
                          secController: _secondarySecsController,
                          minFormKey: _secondaryMinsFormKey,
                          secFormKey: _secondarySecsFormKey,
                        ),
                        ElevatedButton(
                          child: Text(
                            'Confirm',
                            style: kButtonTextStyle,
                          ),
                          onPressed: () => validateAndSetTimer(
                            TimerType.Secondary,
                            _secondaryMinsFormKey,
                            _secondarySecsFormKey,
                            _secondaryMinsController.value.text,
                            _secondarySecsController.value.text,
                            secondaryCounterController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              isPrimaryTimerRunning
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isPaused
                            ? TimerButton(
                                buttonLabel: 'Resume',
                                buttonColor: Colors.green,
                                buttonFunction: resumeTimers,
                              )
                            : TimerButton(
                                buttonLabel: 'Pause',
                                buttonColor: Colors.orange[900],
                                buttonFunction: pauseTimers,
                              ),
                        SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
                        TimerButton(
                          buttonLabel: 'Stop',
                          buttonColor: Colors.red[900],
                          buttonFunction: stopTimers,
                        ),
                      ],
                    )
                  : TimerButton(
                      buttonLabel: 'Start',
                      buttonColor: Colors.green,
                      minWidth: 65,
                      buttonFunction: startTimers,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void validateAndSetTimer(
      TimerType timerType,
      GlobalKey<FormState> minFormKey,
      GlobalKey<FormState> secFormKey,
      String minutes,
      String seconds,
      CountDownController timerController) {
    if (timerType == TimerType.Primary) {
      setState(() {
        visibilityFlag1 = !visibilityFlag1;
      });
    }

    if (timerType == TimerType.Secondary) {
      setState(() {
        visibilityFlag2 = !visibilityFlag2;
      });
    }

    if (minFormKey.currentState.validate() &&
        secFormKey.currentState.validate()) {
      int totalTime = getTotalTimeInSeconds(minutes, seconds);
      setTimer(totalTime, timerController);
    }
  }

  void setTimer(int totalTime, CountDownController timerController) {
    // int totalTime = getTotalTimeInSeconds(minutes, seconds);
    logger.wtf(totalTime);
    timerController.restart(duration: totalTime);
    timerController.pause();
  }

  int getTotalTimeInSeconds(String minutes, String seconds) {
    logger.wtf(minutes);
    logger.wtf(seconds);
    logger.wtf(int.parse(minutes) * 60 + int.parse(seconds));
    return int.parse(minutes) * 60 + int.parse(seconds);
  }

  int primaryTimerTotalTime = 0;
  int secondaryTimerTotalTime = 0;
  void createDivisions() {
    timerDivisions.clear();
    primaryTimerTotalTime = getTotalTimeInSeconds(
        _primaryMinsController.value.text, _primarySecsController.value.text);
    secondaryTimerTotalTime = getTotalTimeInSeconds(
        _secondaryMinsController.value.text,
        _secondarySecsController.value.text);

    int remainingTime =
        ((primaryTimerTotalTime % secondaryTimerTotalTime)).floor();
    int secondaryTimerCycles =
        (primaryTimerTotalTime / secondaryTimerTotalTime).floor();

    if (remainingTime == 0) {}

    for (int i = 0; i < secondaryTimerCycles; i++) {
      logger.wtf("i: $i     totalCycles: $secondaryTimerCycles");
      timerDivisions.add(secondaryTimerTotalTime);
    }

    if (remainingTime != 0) {
      logger.d("Inserting remaining time");
      timerDivisions.add(remainingTime);
    }

    logger.d(timerDivisions, "\n length: ${timerDivisions.length}");

    print('Remaining time: $remainingTime');
    print('Total cycles: $secondaryTimerCycles');
  }

  void onTimersStart(TimerType timerType) {
    logger.d("TIMER STARTED");
    if (timerType == TimerType.Primary) {
      setState(() {
        isPrimarySet = true;
      });
    } else {
      isSecondarySet = true;
    }
  }

  bool isStopped = false;
  void onTimersComplete(TimerType timerType) {
    if (timerType == TimerType.Primary) {
      setState(() {
        isPrimaryTimerRunning = false;
        isSecondaryTimerRunning = false;
        isPrimarySet = false;
        isSecondarySet = false;
        isPaused = false;
        currentCycle = 0;
        timerDivisions.clear();
      });
    } else {
      if (!isStopped) {
        playAudio();
        if (currentCycle < timerDivisions.length) {
          secondaryCounterController.restart(
              duration: timerDivisions[++currentCycle]);
        }
      } else {
        isStopped = false;
      }
    }
  }

  void timerValueChangeListener(Duration timeElapsed) {}

  void handleTimerOnStart() {
    print("timer has just started");
  }

  void handleTimerOnEnd() {
    print("timer has ended");
    setState(() {
      // callTimer = false;
    });
  }

  void startTimers() {
    if (isPrimarySet && isSecondarySet) {
      createDivisions();

      if (primaryTimerTotalTime < secondaryTimerTotalTime) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                Icons.error_outline_outlined,
                color: Colors.yellow,
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal * 2,
              ),
              Text(
                "Divisions should be less than duration",
                maxLines: 2,
              ),
            ],
          ),
        ));
      } else {
        primaryCounterController.start();
        secondaryCounterController.restart(
            duration: timerDivisions[currentCycle]);
        logger.wtf(currentCycle);
        setState(() {
          isPrimaryTimerRunning = true;
          isSecondaryTimerRunning = true;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(
              Icons.error_outline_outlined,
              color: Colors.yellow,
            ),
            SizedBox(
              width: SizeConfig.blockSizeHorizontal * 2,
            ),
            Text("Please set timers"),
          ],
        ),
      ));
    }
    // secondaryCounterController.start();
  }

  void stopTimers() {
    isStopped = true;
    setState(() {
      isPrimaryTimerRunning = false;
      isSecondaryTimerRunning = false;
      isPrimarySet = false;
      isSecondarySet = false;
      currentCycle = 0;
      timerDivisions.clear();
    });
    primaryCounterController.restart(duration: 0);
    primaryCounterController.pause();
    secondaryCounterController.restart(duration: 0);
    secondaryCounterController.pause();
  }

  void pauseTimers() {
    setState(() {
      isPaused = true;
    });
    primaryCounterController.pause();
    secondaryCounterController.pause();
  }

  void resumeTimers() {
    setState(() {
      isPaused = false;
    });
    primaryCounterController.resume();
    secondaryCounterController.resume();
  }

  void playAudio() {
    // final player = AudioCache();
    // player.play('referee_whistle.mp3');
  }
}

class CountDownTimer extends StatelessWidget {
  final CountDownController timerController;
  final Function onStart;
  final Function onComplete;
  final Color fillColor;
  final Color bcgColor;
  final double fontSize;
  final bool secondsOnly;
  final double strokeWidth;
  const CountDownTimer({
    Key key,
    @required this.timerController,
    @required this.onStart,
    @required this.onComplete,
    @required this.fillColor,
    @required this.bcgColor,
    this.fontSize,
    @required this.secondsOnly,
    this.strokeWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: CircularCountDownTimer(
        duration: 10,
        initialDuration: 0,
        controller: this.timerController,
        width: SizeConfig.blockSizeHorizontal * 40,
        height: SizeConfig.blockSizeVertical * 30,
        ringColor: Colors.grey[300],
        ringGradient: null,
        fillColor: this.fillColor,
        fillGradient: null,
        backgroundColor: this.bcgColor,
        backgroundGradient: null,
        strokeWidth: this.strokeWidth ?? 10.0,
        strokeCap: StrokeCap.round,
        textStyle: kTimerTextStyle.copyWith(fontSize: this.fontSize ?? 33),
        textFormat: CountdownTextFormat.HH_MM_SS,
        isReverse: true,
        isReverseAnimation: false,
        isTimerTextShown: true,
        autoStart: false,
        onStart: this.onStart,
        onComplete: this.onComplete,
      ),
    );
  }
}
