import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:footy/const.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Logger logger = Logger();

class RatingScreen extends StatefulWidget {
  static final String id = 'rating_screen';
  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    String documentID = "CxCC3wf6jLuiGa6OHZ1c";
    DocumentReference centerReference =
        FirebaseFirestore.instance.collection("sportCenters").doc(documentID);

    Future updateRatings(int currentRating) async {
      return FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot ds = await transaction.get(centerReference);

        if (!ds.exists) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [Text('Center does not exist buddy')],
            ),
          ));

          throw Exception("Center does not exist!");
        }

        try {
          Map<String, Object> data = HashMap();

          int totalRated = ds.data()['totalRated'];
          int totalRatings = ds.data()['totalRatings'];

          totalRated += 1;
          totalRatings += currentRating;
          double avgRating = totalRatings / totalRated;

          data["totalRated"] = totalRated;
          data["totalRatings"] = totalRatings;
          data["averageRating"] = avgRating;
          transaction.update(centerReference, data);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [Text("Updat")],
            ),
          ));
        } on FirebaseException catch (e) {
          logger.wtf(e.message);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: [Text(e.message)],
            ),
          ));
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Rating'),
      ),
      body: Container(
        width: SizeConfig.screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RatingStars(
              onRated: updateRatings,
            ),
          ],
        ),
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  final double rating = 0;
  final Function onRated;

  const RatingStars({Key key, @required this.onRated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmoothStarRating(
      allowHalfRating: false,
      onRated: (currentRating) {
        logger.d(currentRating);
        this.onRated(currentRating.toInt());
      },
      starCount: 5,
      defaultIconData: Icons.star_border,
      rating: rating,
      size: 40.0,
      isReadOnly: false,
      color: Color(0xFFFFFD700),
      borderColor: Color(0xFFFFFD700),
      spacing: 0.0,
    );
  }
}
