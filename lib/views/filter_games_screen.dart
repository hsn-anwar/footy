import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum FilterMode { lastWeek, dateRange, year }

class FilterGamesScreen extends StatefulWidget {
  static final String id = '/filter_games_screen';
  @override
  _FilterGamesScreenState createState() => _FilterGamesScreenState();
}

class _FilterGamesScreenState extends State<FilterGamesScreen> {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Color deactivatedButtonColor = Colors.grey;
  Color activatedButtonColor = Colors.green;

  DateTimePicked startDate = DateTimePicked();
  DateTimePicked endDate = DateTimePicked();
  DateTime selectedDate = DateTime.now();

  void clearData() {
    setState(() {
      games = List.empty();
      startDate.dateTime = null;
      endDate.dateTime = null;
      startDate.date = null;
      endDate.date = null;
      startDate.isSelected = false;
      endDate.isSelected = false;
    });
  }

  Future<DateTimePicked> datePicker(
      BuildContext context, DateTimePicked dateTimePicked) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // Required
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        dateTimePicked.dateTime = picked;
        dateTimePicked.date = DateFormat('dd-MM-yyyy').format(picked);
        dateTimePicked.isSelected = true;
        print(dateTimePicked.dateTime);
      });
    }
    return dateTimePicked;
  }

  void pickDate(DateTimePicked dateTimePicked) async {
    DateTimePicked picked = await datePicker(context, dateTimePicked);
    setState(() {
      dateTimePicked = picked;
    });

    if (endDate.isSelected == true &&
        startDate.dateTime.isAfter(endDate.dateTime)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Incorrect range entered')));
      setState(() {
        dateTimePicked.isSelected = false;
        dateTimePicked.dateTime = null;
        dateTimePicked.dateTime = null;
      });
    } else if (startDate.isSelected && endDate.isSelected) {
      getGames();
    }
  }

  void filterGameData(FilterMode mode) async {
    if (mode == FilterMode.lastWeek) {
    } else if (mode == FilterMode.dateRange) {
    } else if (mode == FilterMode.year) {}
  }

  void getGamesFromFirestore() async {
    setState(() {
      isLoading = true;
    });
    Query query;

    if (filterMode == FilterMode.lastWeek) {
      query = firebaseFirestore
          .collection("games")
          .where("playedAt", isGreaterThanOrEqualTo: startDate.dateTime)
          .where("playedAt", isLessThanOrEqualTo: DateTime.now());
    } else if (filterMode == FilterMode.dateRange) {
      query = firebaseFirestore
          .collection("games")
          .where("playedAt", isGreaterThanOrEqualTo: startDate.dateTime)
          .where("playedAt", isLessThanOrEqualTo: endDate.dateTime);
    } else if (filterMode == FilterMode.year) {}

    QuerySnapshot querySnapshot = await query.get();

    setState(() {
      games = querySnapshot.docs;
    });
    games.forEach((element) {
      print(element.id);
    });

    setState(() {
      isLoading = true;
    });
  }

  Future<List<DocumentSnapshot>> getInitialGames() async {
    List<DocumentSnapshot> games = [];
    Query query;

    if (filterMode == FilterMode.lastWeek) {
      DateTime date = DateTime.now();
      DateTime lastWeek = DateTime(date.year, date.month, date.day - 7);
      print(lastWeek);
      query = firebaseFirestore
          .collection("games")
          .orderBy("playedAt")
          .where("playedAt", isGreaterThanOrEqualTo: lastWeek)
          .where("playedAt", isLessThanOrEqualTo: DateTime.now())
          .limit(perRequest);
    } else if (filterMode == FilterMode.dateRange) {
      query = firebaseFirestore
          .collection("games")
          .orderBy("playedAt")
          .where("playedAt", isGreaterThanOrEqualTo: startDate.dateTime)
          .where("playedAt", isLessThanOrEqualTo: endDate.dateTime)
          .limit(perRequest);
    } else if (filterMode == FilterMode.year) {
      print("s: ${startDate.dateTime}");
      print("p: ${endDate.dateTime}");

      query = firebaseFirestore
          .collection("games")
          .orderBy("playedAt")
          .where("playedAt", isGreaterThanOrEqualTo: startDate.dateTime)
          .where("playedAt", isLessThan: endDate.dateTime)
          .limit(perRequest);
    }

    QuerySnapshot querySnapshot = await query.get();
    games = querySnapshot.docs;
    print(querySnapshot.size);

    if (querySnapshot.docs.length < perRequest) {
      isMoreGamesAvailable = false;
    } else {
      isMoreGamesAvailable = true;
    }
    if (games.isNotEmpty) lastDocument = querySnapshot.docs.last;

    return games;
  }

  int perRequest = 20;
  bool isMoreGamesAvailable = true;
  DocumentSnapshot lastDocument;
  bool isGettingMoreGames = false;

  void getMoreGames() async {
    print("get more games");
    print(isMoreGamesAvailable);

    if (isMoreGamesAvailable == false) {
      return;
    }

    if (isGettingMoreGames == true) {
      return;
    }
    setState(() {
      isGettingMoreGames = true;
    });
    Query query;
    if (filterMode == FilterMode.lastWeek) {
      DateTime date = DateTime.now();
      DateTime lastWeek = DateTime(date.year, date.month, date.day - 7);
      print(lastWeek);
      query = firebaseFirestore
          .collection("games")
          .orderBy("playedAt")
          .where("playedAt", isGreaterThanOrEqualTo: lastWeek)
          .where("playedAt", isLessThanOrEqualTo: DateTime.now())
          .startAfterDocument(lastDocument)
          .limit(perRequest);
    } else if (filterMode == FilterMode.dateRange) {
      query = firebaseFirestore
          .collection("games")
          .orderBy("playedAt")
          .where("playedAt", isGreaterThanOrEqualTo: startDate.dateTime)
          .where("playedAt", isLessThanOrEqualTo: endDate.dateTime)
          .startAfterDocument(lastDocument)
          .limit(perRequest);
    } else if (filterMode == FilterMode.year) {
      query = firebaseFirestore
          .collection("games")
          .orderBy("playedAt")
          .where("playedAt", isGreaterThanOrEqualTo: startDate.dateTime)
          .where("playedAt", isLessThan: endDate.dateTime)
          .startAfterDocument(lastDocument)
          .limit(perRequest);
    }
    QuerySnapshot querySnapshot = await query.get();
    List<DocumentSnapshot> documents = querySnapshot.docs;
    print("more: ${querySnapshot.size}");
    print(games.length);
    setState(() {
      games.addAll(documents);
    });
    if (querySnapshot.docs.length < perRequest) {
      isMoreGamesAvailable = false;
    } else {
      isMoreGamesAvailable = true;
    }
    lastDocument = querySnapshot.docs.last;
    setState(() {
      isGettingMoreGames = false;
    });
  }

  void getGames() async {
    setState(() {
      isLoading = true;
    });

    if (games.length > 0) {
      setState(() {
        games.clear();
      });
    }

    games = await getInitialGames();

    print(games.length);
    setState(() {
      isLoading = false;
    });
  }

  void createDocuments() async {
    for (int i = 0; i <= 30; i++) {
      await firebaseFirestore.collection("games").doc().set({
        "playedAt": DateTime.now(),
        "status": "completed",
      });
    }
  }

  List<DocumentSnapshot> games = [];
  FilterMode filterMode;
  bool isLoading = false;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    filterMode = FilterMode.lastWeek;
    getGames();

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if (maxScroll - currentScroll <= delta) {
        getMoreGames();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: getGames,
      //   child: Text('Debug'),
      // ),
      appBar: AppBar(
        title: Text('Filter Games'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all_rounded),
            onPressed: () {
              setState(() {
                clearData();
                filterMode = FilterMode.lastWeek;
                getGames();
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    filterGameData(FilterMode.lastWeek);
                    clearData();
                    setState(() {
                      filterMode = FilterMode.lastWeek;
                    });
                    getGames();
                  },
                  child: Text(
                    'by Last Week',
                    style: TextStyle(
                      color: filterMode == FilterMode.lastWeek
                          ? Colors.green
                          : Colors.grey,
                    ),
                  )),
              TextButton(
                onPressed: () {
                  filterGameData(FilterMode.dateRange);
                  clearData();
                  setState(() {
                    filterMode = FilterMode.dateRange;
                  });
                },
                child: Text(
                  'by Date Range',
                  style: TextStyle(
                    color: filterMode == FilterMode.dateRange
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    filterGameData(FilterMode.year);
                    clearData();
                    setState(() {
                      filterMode = FilterMode.year;
                    });
                  },
                  child: Text(
                    'by Year',
                    style: TextStyle(
                      color: filterMode == FilterMode.year
                          ? Colors.green
                          : Colors.grey,
                    ),
                  )),
            ],
          ),
          filterMode == FilterMode.dateRange ? getDateRange() : Container(),
          filterMode == FilterMode.year
              ? YearPicker(
                  onConfirmCallback: onYearSelected,
                )
              : Container(),
          getGamesList(),
        ],
      ),
    );
  }

  getGamesList() {
    return !isLoading
        ? Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: games.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Card(
                        child: Row(
                          children: [
                            Text('${index + 1}.   '),
                            Text(games[index].id),
                          ],
                        ),
                      ),
                      index == games.length - 1
                          ? isGettingMoreGames
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                )
                              : Container()
                          : Container()
                    ],
                  ),
                );
              },
            ),
          )
        : CircularProgressIndicator();
  }

  void onYearSelected(DateTime dateTime) {
    print(dateTime);
    startDate.dateTime = dateTime;
    startDate.date = DateFormat('dd-MM-yyyy').format(dateTime);
    endDate.dateTime = DateTime(dateTime.year + 1, 1, 1);
    endDate.date = DateTime(dateTime.year + 1, 1, 1).toString();
    getGames();
  }

  DateTime yearSelected = DateTime.now();

  getLastWeek() {
    return Column(
      children: [
        Text('Select Date'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 100,
                child: TextButton(
                  onPressed: () async {
                    pickDate(startDate);
                  },
                  child: Text(startDate.isSelected ? startDate.date : 'Date'),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  getDateRange() {
    return Column(
      children: [
        Text('Select Date Range'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 100,
                child: TextButton(
                  onPressed: () async {
                    pickDate(startDate);
                  },
                  child: Text(
                      startDate.isSelected ? startDate.date : 'Start Date'),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 100,
                child: TextButton(
                  onPressed: () async {
                    pickDate(endDate);
                  },
                  child: Text(endDate.isSelected ? endDate.date : 'End Date'),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class YearPicker extends StatefulWidget {
  final Function onConfirmCallback;

  const YearPicker({Key key, @required this.onConfirmCallback})
      : super(key: key);
  @override
  _YearPickerState createState() => _YearPickerState();
}

class _YearPickerState extends State<YearPicker> {
  List<DateTime> years = [];

  getYears() {
    DateTime now = DateTime.now();

    for (int year = now.year; year >= 2015; year--) {
      years.add(DateTime(year, 1, 1));
    }
    print(years);
  }

  @override
  void initState() {
    getYears();
    super.initState();
  }

  int selectedIndex = -1;
  bool isPickerSelected = false;
  bool valueSelected = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 9;
    final double itemWidth = size.width / 3;
    return Column(
      children: [
        Visibility(
          visible: !isPickerSelected,
          child: Container(
            width: 100,
            child: TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    isPickerSelected = true;
                  });
                },
                child: Text(valueSelected
                    ? "${years[selectedIndex].year}"
                    : "Select Year")),
          ),
        ),
        Visibility(
          visible: isPickerSelected,
          child: Column(
            children: [
              Container(
                height: 200,
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: (itemWidth / itemHeight),
                  children: List.generate(years.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          valueSelected = true;
                          selectedIndex = index;
                          isPickerSelected = false;
                        });
                        setState(() {});
                        widget.onConfirmCallback(years[selectedIndex]);
                        print(selectedIndex);
                      },
                      child: Card(
                        elevation: index == selectedIndex ? 15 : 0,
                        color: index == selectedIndex
                            ? Colors.green
                            : Colors.white,
                        child: Center(
                            child: Text(
                          '${years[index].year}',
                          style: TextStyle(
                              color: index == selectedIndex
                                  ? Colors.white
                                  : Colors.green),
                        )),
                      ),
                    );
                  }),
                ),
              ),
              // Row(
              //   children: [
              //     Spacer(),
              //     TextButton(
              //         onPressed: () {
              //           setState(() {
              //             isPickerSelected = false;
              //           });
              //           print(years[selectedIndex]);
              //           widget.onConfirmCallback(years[selectedIndex]);
              //         },
              //         child: Text(
              //           "Confirm",
              //           style: TextStyle(color: Colors.green),
              //         )),
              //   ],
              // )
            ],
          ),
        ),
      ],
    );
  }
}

class Year {
  DateTime dateTime;
  bool isSelected = false;
}

class DateTimePicked {
  DateTime dateTime;
  String date;
  bool isSelected = false;
}
