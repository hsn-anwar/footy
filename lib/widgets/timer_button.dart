import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';

class TimerButton extends StatelessWidget {
  final String buttonLabel;
  final Color buttonColor;
  final Function buttonFunction;
  final int minWidth;

  TimerButton({
    @required this.buttonLabel,
    @required this.buttonColor,
    @required this.buttonFunction,
    this.minWidth = 30,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: SizeConfig.blockSizeHorizontal * this.minWidth,
      child: RaisedButton(
        onPressed: this.buttonFunction,
        color: this.buttonColor,
        child: Text(
          this.buttonLabel,
          style: kButtonTextStyle,
        ),
      ),
    );
  }
}
