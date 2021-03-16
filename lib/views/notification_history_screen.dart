import 'package:flutter/material.dart';

class NotificationHistoryScreen extends StatefulWidget {
  static final String id = '/notification_screen_history';
  @override
  _NotificationHistoryScreenState createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification History'),
        centerTitle: true,
      ),
      body: Column(),
    );
  }
}
