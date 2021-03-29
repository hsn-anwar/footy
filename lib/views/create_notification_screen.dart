import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:footy/ads/ads.dart';

class CreateNotificationScreen extends StatefulWidget {
  static final String id = '/create_notification_screen';
  @override
  _CreateNotificationScreenState createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final String collectionName = 'alerts';

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final titleKey = GlobalKey<FormState>();
  final contentKey = GlobalKey<FormState>();

  void _createNotification() async {
    if (titleKey.currentState.validate() &&
        contentKey.currentState.validate()) {
      try {
        await firebaseFirestore.collection(collectionName).doc().set({
          "title": titleController.value.text,
          "content": contentController.value.text,
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Notification created")));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('error: $e')));
      }
    }
  }

  @override
  void initState() {
    myInterstitial.load();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Notification'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 64,
          ),
          Container(
            child: Text(
              'Alerts',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                shadows: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Form(
              key: titleKey,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: "Title",
                  fillColor: Colors.white,
                  focusColor: Colors.green,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    borderSide: BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (value) {
                  if (value.isEmpty)
                    return "Field cannot be empty";
                  else
                    return null;
                },
                controller: titleController,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Form(
              key: contentKey,
              child: TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Content",
                  fillColor: Colors.white,
                  focusColor: Colors.green,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                    borderSide: BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (value) {
                  if (value.isEmpty)
                    return "Field cannot be empty";
                  else
                    return null;
                },
                controller: contentController,
              ),
            ),
          ),
          SizedBox(
            height: 32,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: _createNotification, child: Text('Create')),
          )
        ],
      ),
    );
  }
}
