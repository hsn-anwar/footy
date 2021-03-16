import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:footy/const.dart';
import 'package:footy/views/game_records.dart';

class UsersScreen extends StatefulWidget {
  static final String id = '/users_screen';
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
        centerTitle: true,
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.userAstronaut,
                color: Color.fromARGB(255, 58, 187, 137),
                size: 70,
              ),
              onPressed: () => Navigator.pushNamed(context, GameRecords.id,
                  arguments: "L0yZLcvTWUPJTFjR7Y8p9OOsrnB2"),
            ),
            SizedBox(
              height: 100.0,
            ),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.userGraduate,
                color: Color.fromARGB(255, 116, 106, 90),
                size: 70,
              ),
              onPressed: () => Navigator.pushNamed(context, GameRecords.id,
                  arguments: "AZYmA7PXdlbJceRFFPT3ufiUDIQ2"),
            ),
            SizedBox(
              height: 100.0,
            ),
            IconButton(
              icon: Icon(
                FontAwesomeIcons.userNinja,
                color: Color.fromARGB(255, 206, 85, 57),
                size: 70,
              ),
              onPressed: () => Navigator.pushNamed(context, GameRecords.id,
                  arguments: "2dPRIeIss7Z2SpmpY4p4V8BdPDS2"),
            )
          ],
        ),
      ),
    );
  }
}
