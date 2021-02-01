import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';

class ResultScreen extends StatelessWidget {
  static String id = 'result_screen';

  @override
  Widget build(BuildContext context) {
    final String uid = ModalRoute.of(context).settings.arguments;
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Text'),
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        child: Center(
          child: Text(
            uid,
            style: TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }
}
