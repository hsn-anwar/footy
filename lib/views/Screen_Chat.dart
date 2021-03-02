import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:footy/const.dart';
import 'package:footy/Utils/functions.dart';
import 'package:logger/logger.dart';

class Chat extends StatefulWidget {
  final String chatId;
  final bool isPrivate;
  static final id = 'chat_screen';
//  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _ChatState createState() => _ChatState();

  Chat({
    Key key,
    this.chatId,
    this.isPrivate,
  }) : super(key: key);
}

class _ChatState extends State<Chat> {
  bool isLoading = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  int current = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChatScreen(
      chatId: widget.chatId,
      isPrivate: widget.isPrivate,
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  final bool isPrivate;

  ChatScreen({Key key, @required this.chatId, this.isPrivate})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(peerID: chatId);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerID});

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String peerID;
  String currentUserID;
  Map<String, DocumentSnapshot> playersMap = Map();

  List listMessage = [];
  String conversationID;

  bool isLoading;
  bool isFirstMessage = false;
  Logger logger = Logger();

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  int lastMessageIndex;
  bool isLastMessageSeen = true;

  Utils utils = Utils();
  bool isGettingMessages = false;
  List messages = [];
  void initializeAndGetChats() async {
    if (isGettingMessages) return;
    setState(() {
      isGettingMessages = true;
    });
    messages = await utils.getMessagesFromFirestore(conversationID);
    if (messages != null) {
      messages.forEach((element) {
        print(element.data());
      });
      setState(() {
        if (listMessage.length == 0) {
          listMessage = messages;
        } else {
          listMessage = listMessage + messages;
        }
      });
    }
    setState(() {
      isGettingMessages = false;
    });
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    currentUserID = FirebaseAuth.instance.currentUser.uid;
    conversationID = widget.chatId;
    isLoading = false;

    setState(() {});
    widget.isPrivate ? createConversationID() : conversationID = widget.chatId;
    initializeAndGetChats();
    listScrollController.addListener(() {
      if (listScrollController.position.atEdge &&
          !(listScrollController.position.pixels == 0)) {
        logger.i("Get more messages");
        initializeAndGetChats();
      }
    });
  }

  @override
  void dispose() {
    utils.lastMessage = null;
    super.dispose();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {}
  }

  createConversationID() async {
    if (currentUserID.hashCode <= peerID.hashCode) {
      conversationID = '$currentUserID-$peerID';
    } else {
      conversationID = '$peerID-$currentUserID';
    }

    setState(() {});
  }

  void onSendMessage(String content, int type) {
    //print('con'+conversationID);
    if (content.trim() != '') {
      textEditingController.clear();

      print(conversationID);
      var documentReference = _firestore
          .collection('conversations')
          .doc(conversationID)
          .collection(conversationID)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      _firestore.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': currentUserID,
            'idTo': peerID,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': 0,
          },
        );

        if (isFirstMessage) {
          print(isFirstMessage);
          transaction
              .set(_firestore.collection('conversations').doc(conversationID), {
            'isPrivate': true,
            'peerIDList': FieldValue.arrayUnion([peerID, currentUserID])
          });
          isFirstMessage = false;
        }

        await transaction.update(
          _firestore.collection('conversations').doc(conversationID),
          {
            'senderID': currentUserID,
            'sentAt': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    int type;
    document.data().containsKey('type')
        ? type = document.get('type')
        : type = 0;

    if (document['idFrom'] == currentUserID) {
      // Right side (my message)
      return type == 0
          ? Column(
              // mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: <Widget>[
                    ChatBubble(
                      clipper: ChatBubbleClipper5(type: BubbleType.sendBubble),
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(top: 10),
                      backGroundColor: Colors.blue,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Text(
                          document.get('content'),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
              ],
            )
          : buildUpdateItem(document.get('content'), document.get('timestamp'));
    } else {
      return type == 0
          ? Container(
              child: Column(
                children: <Widget>[
                  //buildUserItem(document.get('idFrom')),
                  Stack(
                    children: [
                      Row(
                        children: [
                          // buildUserItem(document.get('idFrom')),
                          Container(
                            child: Text(
                              DateFormat('dd MMM kk:mm').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(document['timestamp']))),
                              style: TextStyle(
                                  color: greyColor,
                                  fontSize: 12.0,
                                  fontStyle: FontStyle.italic),
                            ),
                            margin: EdgeInsets.only(
                                left: 5.0, top: 5.0, bottom: 5.0),
                          )
                          //  : Container()
                        ],
                      ),
                      ChatBubble(
                        clipper:
                            ChatBubbleClipper5(type: BubbleType.receiverBubble),
                        backGroundColor: Color(0xffE7E7ED),
                        //padding: EdgeInsets.fromLTRB(0.0, 26.0, 15.0, 0.0),
                        // margin: EdgeInsets.only(top: 26),
                        margin: EdgeInsets.only(left: 42.0, top: 28),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.65,
                          ),
                          child: Text(
                            document.get('content'),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                    ],
                  ),

                  // Time
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              margin: EdgeInsets.only(bottom: 10.0),
            )
          : buildUpdateItem(document.get('content'), document.get('timestamp'));
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == currentUserID) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != currentUserID) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            child: Text(
              'Clear list',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () => listMessage.clear(),
          )
        ],
        title: Text(
          'Chat Screen',
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Column(
                //mainAxisSize: MainAxisSize.min,

                children: <Widget>[
                  // List of messages
                  buildListMessage(),

                  // Flexible(
                  //   child: ListView.builder(
                  //     shrinkWrap: true,
                  //     itemCount:10,
                  //       itemBuilder: (BuildContext context,index){
                  //
                  //     return Container(
                  //       height: 10,
                  //       color: Colors.red,
                  //     );
                  //   }),
                  // ),
                  // Input content
                  buildInput(),
                ],
              ),
            ),

            // Loading
            buildLoading()
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: TextField(
                style: TextStyle(color: Colors.black87, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildUpdateItem(content, timeStamp) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
      margin: EdgeInsets.symmetric(vertical: 5),

      child: Row(
        children: [
          Expanded(
            child: Text(
              content,
              style: Theme.of(context).textTheme.caption,
              //style:TextStyle(color: Colors.black54,fontSize: 1,fontWeight: FontWeight.w100 )
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            DateFormat('dd MMM kk:mm').format(
                DateTime.fromMillisecondsSinceEpoch(int.parse(timeStamp))),
            style: TextStyle(
                color: greyColor, fontSize: 12.0, fontStyle: FontStyle.italic),
          ),
          SizedBox(
            width: 5,
          )
        ],
      ),

      //width: 200.0,
      decoration: BoxDecoration(
        color: Colors.white12,
        border: Border(
          top: BorderSide(width: 0.1, color: Colors.black87),
          bottom: BorderSide(width: 0.1, color: Colors.black87),
        ),
        //borderRadius: BorderRadius.circular(8.0)
      ),
      //margin: EdgeInsets.only(left: 10.0,),
    );
  }

  Widget buildUserItem(id) {
    return FutureBuilder(
      future: Utils().getUserDetails(id),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Container(
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/UserProfileView');
                },
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 0.0),
                    //   child: Material(
                    //     elevation: 2.0,
                    //     shape: CircleBorder(),
                    //     child: CircleAvatar(
                    //       backgroundColor: Colors.white,
                    //       child: snapshot.data.get('photoUrl') != null
                    //           ? CachedNetworkImage(
                    //               imageUrl: snapshot.data.get('photoUrl'),
                    //               imageBuilder: (context, imageProvider) =>
                    //                   Container(
                    //                 height: 30,
                    //                 width: 30,
                    //                 decoration: BoxDecoration(
                    //                   shape: BoxShape.circle,
                    //                   image: DecorationImage(
                    //                       image: imageProvider,
                    //                       fit: BoxFit.cover),
                    //                 ),
                    //               ),
                    //               placeholder: (context, url) =>
                    //                   CircularProgressIndicator(),
                    //               errorWidget: (context, url, error) => Icon(
                    //                 Icons.error,
                    //                 size: 25,
                    //               ),
                    //             )
                    //           : Image.asset(
                    //               'assets/SampleProfileAvatar.png',
                    //               height: 30,
                    //               width: 30,
                    //             ),
                    //       radius: 17.0,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      snapshot.data['name'].toString(),
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),

                    // Expanded(child: SizedBox(),),
                    //Icon(Icons.star,color: Colors.amber,),
                    //SizedBox(width: 5,)
                  ],
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          Text('unable to get Data');
        }
        return Container(
            height: 50,
            width: 50,
            child: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget buildListMessage2() {
    logger.d(conversationID);
    return Flexible(
      child: conversationID == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: _firestore
                  .collection('conversations')
                  .doc(conversationID)
                  .collection(conversationID)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  listMessage = snapshot.data.docs;
                  if (listMessage.isEmpty) {
                    isFirstMessage = true;
                  }
                  // snapshot.data.documents.reversed;

                  lastMessageIndex = snapshot.data.docs.length - 1;
                  return ListView.builder(
                    // shrinkWrap: true,
                    // physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.docs[index]),
                    itemCount: snapshot.data.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  Widget buildListMessage() {
    logger.d(conversationID);
    return Flexible(
      child: listMessage == null
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : messagesListView(),
    );
  }

  Widget messagesListView() {
    // logger.wtf(listMessage.length);
    return ListView.builder(
      padding: EdgeInsets.all(10.0),
      reverse: true,
      itemCount: listMessage.length,
      controller: listScrollController,
      itemBuilder: (BuildContext context, int index) {
        SizeConfig().init(context);
        if (index == listMessage.length - 1) {
          return Column(
            children: [
              EndCard(isGettingMore: isGettingMessages),
              buildItem(index, listMessage[index]),
            ],
          );
        } else {
          return buildItem(index, listMessage[index]);
        }
      },
    );
  }
}

class EndCard extends StatelessWidget {
  final bool isGettingMore;
  EndCard({@required this.isGettingMore});
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Stack(
      children: [
        Container(
          height: isGettingMore
              ? SizeConfig.blockSizeVertical * 7
              : SizeConfig.blockSizeVertical * 0,
        ),
        isGettingMore
            ? Column(
                children: [
                  Container(
                    height: SizeConfig.blockSizeVertical * 2,
                  ),
                  Center(child: CircularProgressIndicator()),
                  Container(
                    height: SizeConfig.blockSizeVertical * 7,
                  ),
                ],
              )
            : Container(),
      ],
    );
  }
}
