import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:footy/Utils/functions.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:logger/logger.dart';
import 'dart:async';
// import 'package:footy_app/Widgets/ProfileAvatarWithoutGlow.dart';
import 'package:footy/const.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
// import 'Utils/functions.dart';
// import 'const.dart';

enum MessageStatus {
  Sent,
  Sending,
}

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

  List<DocumentSnapshot> listMessage = [];
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
  List<DocumentSnapshot> _streamMessages = [];
  int messagesPerRequest = 30;
  int totalMessages = 20;
  StreamController<List> _streamController = StreamController<List>();

  Utils utils = Utils();
  bool isGettingMessages = false;
  List<DocumentSnapshot> messages = [];
  bool isFirst = true;

  Map<String, Object> messageData = HashMap();

  void initializeAndGetChats() async {
    if (_isDispose) return;
    if (isGettingMessages) return;
    //logger.wtf('Method called - initializeAndGetChats');
    setState(() {
      isGettingMessages = true;
    });
    //totalMessages+=messagesPerRequest;
    messages = await utils.getMessagesFromFirestore(conversationID);

    if (messages != null) {
      // messages.forEach((element) {
      //   print(element.data());
      // });

      if (listMessage.length == 0) {
        listMessage = messages;
      } else {
        listMessage.addAll(messages);
        _streamMessages.addAll(messages);
        _streamController.sink.add(listMessage);
      }

      setState(() {});
    }
    setState(() {
      isGettingMessages = false;
    });
  }

  bool isMessageSent = false;
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
    // utils.initializeMessaging(conversationID);

    _firestore
        .collection('conversations')
        .doc(conversationID)
        .collection(conversationID)
        .limit(messagesPerRequest)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((data) async {
      // print('doc changes 1'+data.docChanges.toString());

      // _streamMessages = await utils.initializeMessaging(data.docChanges, _streamController);
      //+
      // logger.wtf(_streamMessages.length);

      //listMessage.addAll(data.docs);
      //_streamMessages.addAll(data.docs);
      //_streamController.sink.add(listMessage);

      print('list message bf' + listMessage.length.toString());
      print('stream message bf' + _streamMessages.length.toString());

      if (listMessage.length > 0) {
        _streamMessages =
            await utils.initializeMessaging(data.docChanges, _streamController);

        _streamMessages.addAll(listMessage);

        // print('Stram messages length'+_streamMessages.length.toString());
        //
        //
        // //listMessage.clear();
        await _streamController.sink.add(_streamMessages);
        // _listKey.currentState.insertItem(listMessage.length - 1);
        // setState(() {
        //   isMessageSent = true;
        //   logger.i("Message sent \n"
        //       "Message: ${_streamMessages[_streamMessages.length - 1].data()}");
        // });
      } else {
        if (!_isDispose) await _streamController.sink.add(data.docs);
      }

      // print('list message af'+listMessage.length.toString());
      // print('stream message af'+_streamMessages.length.toString());
      // utils.updateLastMessage()
    }).onDone(() {
      logger.wtf("Stream closed");
    });

    listScrollController.addListener(() {
      double maxScroll = listScrollController.position.maxScrollExtent;
      double currentScroll = listScrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        initializeAndGetChats();
      }
    });
  }

  bool _isDispose = false;
  @override
  void dispose() {
    _isDispose = true;
    utils.lastMessage = null;
    utils.timesRan = 0;
    utils.isMoreMessages = true;
    _streamMessages.clear();
    _streamController.close();

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

  List<bool> sendingMessages = [];
  void onSendMessage(String content, int type) async {
    //print('con'+conversationID);
    if (content.trim() != '') {
      setState(() {
        sendingMessages.add(true);
        isMessageSent = false;
      });
      messageData['idFrom'] = currentUserID;
      messageData['idTo'] = peerID;
      messageData['timestamp'] =
          DateTime.now().millisecondsSinceEpoch.toString();
      messageData['content'] = content;
      messageData['type'] = 0;
      textEditingController.clear();
      print(conversationID);
      var documentReference = _firestore
          .collection('conversations')
          .doc(conversationID)
          .collection(conversationID)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      _firestore.runTransaction((transaction) async {
        await transaction.set(documentReference, messageData);
        totalMessages += 1;

        if (isFirstMessage) {
          print(isFirstMessage);
          await transaction
              .set(_firestore.collection('conversations').doc(conversationID), {
            'isPrivate': true,
            'peerIDList': FieldValue.arrayUnion([peerID, currentUserID])
          });
          isFirstMessage = false;
        }

        // await transaction.update(
        //   _firestore.collection('conversations').doc(conversationID),
        //   {
        //     'senderID': currentUserID,
        //     'sentAt': DateTime.now().millisecondsSinceEpoch.toString(),
        //     'content': content,
        //   },
        // );
      }).then((value) {
        logger.d(value.runtimeType);
        setState(() {
          sendingMessages.removeAt(0);
        });
        print('Success');
      }).onError((error, stackTrace) {
        setState(() {
          sendingMessages.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Could not send message due to network in-availability")));
        setState(() {
          isMessageSent = true;
        });
        logger.i(error);
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
                      // Row(
                      //   children: [
                      //     buildUserItem(document.get('idFrom')),
                      //     Container(
                      //       child: Text(
                      //         DateFormat('dd MMM kk:mm').format(
                      //             DateTime.fromMillisecondsSinceEpoch(
                      //                 int.parse(document['timestamp']))),
                      //         style: TextStyle(
                      //             color: greyColor,
                      //             fontSize: 12.0,
                      //             fontStyle: FontStyle.italic),
                      //       ),
                      //       margin: EdgeInsets.only(
                      //           left: 5.0, top: 5.0, bottom: 5.0),
                      //     )
                      //     //  : Container()
                      //   ],
                      // ),
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

                  // messageData['content'] != null
                  //     ? !isMessageSent
                  //         ? Padding(
                  //             padding:
                  //                 EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                  //             child: SendingChatBubble(
                  //                 content: messageData['content']),
                  //           )
                  //         : Container()
                  //     : Container(),
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
                    // SimpleProfileAvatar(photoUrl: snapshot.data['photoUrl'],height: 30,width: 30,radius: 15,),
                    Container(),
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

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  Tween<Offset> _offset = Tween(begin: Offset(0, -1), end: Offset(0, 0));

  Widget buildListMessage() {
    return Flexible(
      child: conversationID == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              // _streamController.stream
              stream: _streamController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  listMessage = snapshot.data;
                  if (listMessage.isEmpty) {
                    isFirstMessage = true;
                  }
                  // snapshot.data.documents.reversed;
                  lastMessageIndex = snapshot.data.length - 1;

                  if (listMessage.isNotEmpty) {
                    utils.lastMessage = listMessage.last;
                  }
                  return ListView.builder(
                    // shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      print('snapshot data length' +
                          snapshot.data.length.toString());
                      if (index == listMessage.length - 1) {
                        return Column(
                          children: [
                            EndCard(isGettingMore: isGettingMessages),
                            buildItem(index, snapshot.data[index]),
                          ],
                        );
                      } else if (index == 0) {
                        return Column(
                          children: [
                            buildItem(index, snapshot.data[index]),
                            sendingMessages.contains(true)
                                ? Row(
                                    children: [
                                      Spacer(),
                                      SizedBox(
                                        width: 250.0,
                                        child: SizedBox(
                                          width: 250.0,
                                          child: ColorizeAnimatedTextKit(
                                            onTap: () {},
                                            text: [
                                              "Sending message",
                                            ],
                                            textStyle: TextStyle(
                                                fontSize: 12.0,
                                                fontFamily: "Horizon"),
                                            colors: [
                                              Colors.grey,
                                              Colors.blueGrey,
                                              Colors.green,
                                              Colors.greenAccent,
                                            ],
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container()
                          ],
                        );
                      } else {
                        return buildItem(index, snapshot.data[index]);
                      }
                    },
                    itemCount: listMessage.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
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

class SendingChatBubble extends StatelessWidget {
  final String content;
  SendingChatBubble({@required this.content});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: <Widget>[
            ChatBubble(
              clipper: ChatBubbleClipper5(type: BubbleType.sendBubble),
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(top: 10),
              backGroundColor: Colors.red,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Text(
                  this.content,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ],
    );
  }
}
