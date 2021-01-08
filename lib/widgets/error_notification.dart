import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';

class ErrorNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: SizeConfig.blockSizeHorizontal * 65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red[900],
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 3,
          ),
          Text(
            'Please Set Timers',
            style: TextStyle(color: Colors.red[900]),
          ),
        ],
      ),
    );
  }
}
