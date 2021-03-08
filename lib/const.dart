import 'package:flutter/material.dart';

Color primaryColor = Colors.green[800];
Color arrivedPlayerWidgetsColor = Colors.orange;
final themeColor = Colors.white;
//final primaryColor = Color(0xffaeaeae);
final greyColor = Color(0xffaeaeae);
final greyColor2 = Color(0xffE8E8E8);

Color kRunningFillColor = Colors.green[300];
Color kRunningBackgroundColor = Colors.green[500];

Color kStoppedFillColor = Colors.redAccent[100];
Color kStoppedBackgroundColor = Colors.red[500];

//todo:profileView actions
//todo:conversations- add name,details when created, add peer id when user added
//todo:gameListOnContinueReg&filter
//todo:

List<String> gameTypeList = <String>[
  'Football',
  'Basketball',
  'Volleyball',
  'Tennis',
  'Badminton',
  'Water Polo',
  'Ping Pong',
  'Running',
  'Squash',
  'Field Hockey',
  'Ice Hockey',
  'Touch Rugby',
  'Rugby',
  'Cricket',
  'American football',
  'Baseball',
  'Dodge Ball',
  'Other (details in description)'
];
List<String> recurrentTypeList = <String>[
  'Never',
  'Daily',
  'Weekly',
  'Monthly',
];

List<String> cancellationOpList = <String>[
  'Never automatically cancel the game ',
  'Cancel the game automatically 1 hour before kick-off if game not full',
  'Cancel the game automatically 4 hour before kick-off if game not full',
  'Cancel the game automatically 8 hour before kick-off if game not full',
  'Cancel the game automatically 24 hour before kick-off if game not full',
];
List<String> substitutesList = <String>[
  'No substitutes',
  '1 substitutes',
  '2 substitutes',
  '3 substitutes',
  '4 substitutes',
  '5 substitutes',
];
List<String> paymentList = <String>[
  'Free',
  'Payment at the pitch',
];
List<String> gamePlayerList = <String>[
  '1-a-side',
  '2-a-side',
  '3-a-side',
  '4-a-side',
  '5-a-side',
  '6-a-side',
  '7-a-side',
  '8-a-side',
  '9-a-side',
  '10-a-side',
  '11-a-side',
  '12-a-side',
  '13-a-side',
  '14-a-side',
  '15-a-side',
];
List<String> matchRegOpList = <String>[
  'Always open',
  '2 weeks before kick off',
  '1 week before kick off',
  '5 days before kick off',
  '3 days before kick off',
  '1 day before kick off',
];
List<String> groundTypeList = <String>[
  'Natural grass',
  'Synthetic turf',
  '3rd generation synthetic turf',
  'Parquet',
  'Rubber',
  'Terrain',
  'Cement',
  'Red clay',
  'Sand',
  'Other (Please specify in the description)'
];

List<String> gamePlayerRole = <String>['GoalKeeper', 'Normal Player'];
//const String kTimeOutSound = 'assets/sounds/referee_whistle.mp3';

const kLabelStyle = TextStyle(fontSize: 17);
const kButtonTextStyle = TextStyle(color: Colors.white, fontSize: 17);
const kResendLabelStyle = TextStyle(color: Colors.black, fontSize: 17);
const kTimerTextStyle = TextStyle(
  fontSize: 33.0,
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

InputDecoration kInputDecoration = InputDecoration(
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: BorderSide(),
  ),
);

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;
  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}
