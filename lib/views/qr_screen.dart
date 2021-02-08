import 'package:flutter/material.dart';
import 'package:footy/shared/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScreen extends StatelessWidget {
  static String id = 'qr_screen';
  final String userId = 'FX2sNpNJ3meRmib2QmO0jyM9K542';
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              child: QrImage(
                data: userId,
                version: QrVersions.auto,
                size: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
