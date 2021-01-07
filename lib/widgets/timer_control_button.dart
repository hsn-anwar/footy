import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';

class TimerControlButton extends StatelessWidget {
  final String buttonLabel;
  final Color buttonColor;
  final Function buttonFunction;

  TimerControlButton({
    @required this.buttonLabel,
    @required this.buttonColor,
    @required this.buttonFunction,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: this.buttonColor,
      child: Center(
        child: Text(
          this.buttonLabel,
          style: kButtonTextStyle,
        ),
      ),
      onPressed: this.buttonFunction,
    );
  }
}
