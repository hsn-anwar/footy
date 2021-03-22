import 'package:flutter/material.dart';
import 'package:footy/database/database.dart';
import 'package:logger/logger.dart';

Logger logger = Logger();

class NotificationHistoryScreen extends StatefulWidget {
  static final String id = '/notification_screen_history';
  @override
  _NotificationHistoryScreenState createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    List<Map<String, dynamic>> notifications =
        await DatabaseHelper.instance.queryAll();
    print(notifications);
    setState(() {});
    return notifications;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: getNotificationHistory,
      ),
      appBar: AppBar(
        title: Text('Notification History'),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder(
          future: getNotificationHistory(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return NotificationsList(
                notifications: snapshot.data,
              );
            } else if (!snapshot.hasData) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error');
            } else {
              return Text('Something went wrong');
            }
          },
        ),
      ),
    );
  }
}

class NotificationsList extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  const NotificationsList({Key key, @required this.notifications})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: this.notifications.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 5,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      height: 50,
                      width: 50,
                    ),

                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          this.notifications[index]
                              [DatabaseHelper.columnNotificationTitle],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          this.notifications[index]
                              [DatabaseHelper.columnNotificationBody],
                        ),
                        Row(
                          children: [
                            Text(this.notifications[index]
                                [DatabaseHelper.columnDateTimeReceived]),
                          ],
                        ),
                      ],
                    ),

                    Expanded(
                      child: SizedBox(),
                    ),

                    //SizedBox(width:5 ,)
                  ],
                ),
              ],
            ),
          );
        });
  }
}
