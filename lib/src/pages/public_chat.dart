import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as pathh;
import '../repository/user_repository.dart' as repository;

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:locals/src/controllers/public_chat_controller.dart';
import 'package:locals/src/elements/DetailScreen.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:images_picker/images_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../generated/l10n.dart';
import '../controllers/public_chat_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import 'dart:async';
import 'dart:convert' as convert;
import '../models/message_model.dart';
import 'package:file/local.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../utils/constants.dart';
import 'package:uuid/uuid.dart' as UID;
import 'package:easy_localization/src/public_ext.dart';

class PublicChatWidget extends StatefulWidget {
  @override
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  PublicChatWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _PublicChatWidgetState createState() => _PublicChatWidgetState();
}

class _PublicChatWidgetState extends StateMVC<PublicChatWidget> {
  PublicChatController _con;
  TextEditingController chatcontroller = TextEditingController();
  int numberOfUsersConnectedToThisRoom = 1;

  io.Socket socket;
  FocusNode _focusNode;
  String message = '';
  bool isCurrentUserTyping = false;
  final List<MessageModel> _listMessages = [];
  final List<MessageModel> checklisttop = [];
  String oldtop="";
  final double minValue = 8.0;
  final double iconSize = 28.0;
  ScrollController _scrollController;
  bool isMicrophone = false;
  bool isMessageSent = false;

  final _refreshController = RefreshController(initialRefresh: false);
  final _url = '${Constants.SERVER_URL}message/upload_img_message';

  double maxDuration = 1.0;

  String localFilePath;
  String maxRecordDuration;
  final LocalFileSystem localFileSystem = LocalFileSystem();
  String path;
  final ImagePicker _picker = ImagePicker();

  List<Media> publicChatImageRes = [];
  var publicImagePaths = [];
  var publicImagePathsthumbnail = [];
  var uploadingImageUrls = [];

  _PublicChatWidgetState() : super(PublicChatController()) {
    _con = controller;
  }

  Color senderFontColor = Colors.black;
  Color receiverFontColor = Colors.white;

  int page;
  final uuid = UID.Uuid();
  Timer timer;
  int counter = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.getSettings();
    // if !isExistAdmin) {
    //   _con.createRoom(adminID);
    // }
    page = 1;

    getLastMessages();
     timer = Timer.periodic(Duration(minutes: _con.refresh_location_time_interval??3), (Timer t) => _onLoadMore());

    getTopMessages();
    initializeDateFormatting();


    _con.init();
    initSocket();
    _scrollController = ScrollController(initialScrollOffset: 0);
  }

  _unSubscribes() {
    if (socket != null) {
      socket.disconnect();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _unSubscribes();
    chatcontroller.dispose();
    super.dispose();
  }

  void sendJoinChat() {
    final map = {};
    map['roomId'] = "61946f1e3e9419cb1103ed1a";
    map['user_name'] = Constants.userresponse['user']['name'];
    final myJson = convert.jsonEncode(map);
    socket.emit("joinPublicRoom", myJson);
  }

  void initSocket() async {
    final url = "${Constants.SOCKET_URL}/api/joinPublicRoom";
    socket = io.io('$url', <String, dynamic>{
      'transports': ['websocket']
    });
    socket.on('connect', (_) {
      sendJoinChat();
    });

    socket.on('RoomMsgReceive', _onReceiveMessage);
  }
  setCurrentLocation() async {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      var _currentPosition;
      setState(() {
        _currentPosition = position;
      });
      print(_currentPosition);
      var myLocation = _currentPosition.latitude.toString() + "," + _currentPosition.longitude.toString();
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('access_token');
      final userId = sharedPreferences.getString('_id');
      await repository.updateLocation(token,userId, myLocation.toString());

    }).catchError((e) {
      print(e);
    });
  }
  void _onReceiveMessage(msg) {
    // final messageType = int.parse(data['message_type']);
    // print('type isssssssss $messageType');
    // final img = data['img'];
    if (msg['receiver_ids'].contains(Constants.userresponse['user']['_id'])) {
      setState(() {
        _listMessages.insert(
            0,
            MessageModel(
              messageId: msg['messageId'],
              message: msg['message'],
              img: msg['img'],
              imgs: msg['imgs'],
              senderId: msg['sender_id'],
              senderName: msg['sender_name'],
              nickname: msg['nickname'],
              gender: msg['gender'].toString(),
              like: int.parse(msg['like'].toString()),
              dislike: int.parse(msg['dislike'].toString()),
              online: msg['online'],
              avatarUrl: msg['avatarUrl'],
              timeDiff: msg['timeDiff'],
              createdAt: int.parse(msg['createdAt'].toString()),
              roomId: msg['roomId'],
            ));
      });
    }
  }

  void getLastMessages() async {
    log("hello");
    var jsonResponse = await _con.getAllMessages();
    if (jsonResponse['error'] == false) {
      final data = jsonResponse['data'] as List;

       setState(() {
         _listMessages.addAll(data.map((e) => MessageModel.fromMap(e)).toList());

       });

    }
  }

  _sendMessage({String img = ''}) async {
    if (chatcontroller.text.length > _con.limit_letters) {
      Fluttertoast.showToast(
          msg: "Letters can not over than " + _con.limit_letters.toString());
    } else {
      final messageId = uuid.v1();
      setState(() {
        isMessageSent = true;
      });
      final mainMap = <String, Object>{};
      log(messageId);
      mainMap['room_id'] = "61946f1e3e9419cb1103ed1a";
      mainMap['messageId'] = messageId;
      mainMap['sender_id'] = Constants.userresponse['user']['_id'];
      mainMap['sender_name'] = Constants.userresponse['user']['name'];
      mainMap['message'] = chatcontroller.text.trim();
      mainMap['distance'] = 0;
      mainMap['img'] = "";
      mainMap['imgs'] = [];

      final jsonString = convert.jsonEncode(mainMap);
      if (publicImagePathsthumbnail.length > 0) {
        await uploadMultiImages();
      } else {
        socket.emit('new_comment', jsonString);
        setState(() {
          isMessageSent = false;
          _listMessages.insert(
              0,
              (MessageModel(
                  messageId: messageId,
                  message: chatcontroller.text.trim(),
                  img: '',
                  imgs: [],
                  senderId: Constants.userresponse['user']['_id'],
                  senderName: Constants.userresponse['user']['name'],
                  nickname: Constants.userresponse['user']['name'],
                  gender: Constants.userresponse['user']['gender'].toString(),
                  like: Constants.userresponse['user']['like'],
                  dislike: Constants.userresponse['user']['dislike'],
                  online: Constants.userresponse['user']['online'],
                  avatarUrl: Constants.userresponse['user']['avatarUrl'],
                  timeDiff: '1',
                  timeUnit:'min'.tr(),
                  distance: "0",
                  distanceUnit: "Km".tr(),
                  createdAt: 0,
                  roomId: '61946f1e3e9419cb1103ed1a')));
          message = '';
          chatcontroller.text = '';
        });
        _scrollToLast();
      }
    }
  }

  void _scrollToLast() {
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    } catch (err) {}
  }

  void _onLoadMore() {
    setCurrentLocation();
    startLoadMore();
  }

  void startLoadMore() async {
    setState(() {
      _listMessages.clear();
    });
    var jsonResponse = await _con.getAllMessages();

    if (jsonResponse['error'] == false) {
      final data = jsonResponse['data'] as List;
      _listMessages.addAll(data.map((e) => MessageModel.fromMap(e)).toList());
      setState(() {});
    }

    if (_listMessages.length > 0) {
      setState(_refreshController.loadComplete);
    } else {
      _refreshController.loadNoData();
    }
  }
  void getTopMessages() async {
    checklisttop.clear();
    var jsonResponse = await _con.getTopChats();
    print(jsonResponse);
    if (jsonResponse['error'] == false) {
      final data = jsonResponse['data'] as List;
      List<MessageModel>templist=[];
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('access_token');
      final userId = sharedPreferences.getString('_id');
      for( int i=0;i<data.length;i++)
        {
          if(userId==data[i]['sender_id'])
            {
              setState(() {
                checklisttop.add(MessageModel.fromMap(data[i]));
              });

            }


        }

      if(checklisttop.length!=0)
        {
          MessageModel m=checklisttop.reduce((a, b) {
            if (a.createdAt< b.createdAt)
              return a;
            else
              return b;
          });

          setState(() {
            oldtop=m.id;
            log("$oldtop");
          });
        }


      // checklisttop.addAll(data.map((e) => MessageModel.fromMap(e)).toList());

    }
    //
    // for(int i=0;i<checklisttop.length;i++)
    //   {
    //
    //     _con.cancelTopMessage(checklisttop[i].id);
    //
    //   }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
          backgroundColor: Colors.white,
          key: _con.scaffoldKey,
          // resizeToAvoidBottomPadding: false,
          body: Column(
            children: [
              headBox(),
              Expanded(
                child: mainContent(),
              ),
              chatBox()
            ],
          )),
    );
  }

  Widget headBox() {
    return Padding(
        padding: EdgeInsets.only(
            top: config.App(context).appWidth(12),
            left: config.App(context).appWidth(7),
            right: config.App(context).appWidth(7)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("public_chat_room",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black))
                .tr(),
            InkWell(
              onTap: () async {
                Navigator.of(context).pushNamed('/LocalUsers');
              },
              child: Image.asset(
                'assets/img/img.jpg',
                height: 30,
                fit: BoxFit.fitHeight,
              ),
            )
          ],
        ));
  }

  Widget mainContent() {
    return Container(
        width: config.App(context).appWidth(100),
        // margin: EdgeInsets.only(top: config.App(context).appWidth(19)),
        padding: EdgeInsets.symmetric(
            horizontal: config.App(context).appWidth(5), vertical: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: Colors.white),
        child: Column(
          children: [
            Expanded(
                child: Container(
              child: SmartRefresher(
                controller: _refreshController,
                header: WaterDropHeader(),
                onLoading: _onLoadMore,
                enablePullUp:false,
                enablePullDown:false,
                child: ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  itemBuilder: (context, i) {
                    return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                        margin: EdgeInsets.only(bottom: 5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //headingtop
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (_con.myId !=
                                            _listMessages[i]
                                                .senderId
                                                .toString()) {
                                          showbottom(i, context);
                                        }
                                      },
                                      child: Container(
                                        width: config.App(context).appWidth(12),
                                        height:
                                            config.App(context).appWidth(12),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 0),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xffC4C4C4)
                                                  .withOpacity(0.55),
                                              image: DecorationImage(
                                                  image: Image.network(Constants
                                                              .SERVER_URL +
                                                          "v1/user/img-src/" +
                                                          _listMessages[i]
                                                              .avatarUrl
                                                              .toString())
                                                      .image,
                                                  fit: BoxFit.fill)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 130,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _listMessages[i]
                                                      .senderId
                                                      .toString() ==
                                                  _con.myId.toString()
                                              ? SizedBox(
                                                  height: 18,
                                                )
                                              : SizedBox(
                                                  height: 0,
                                                ),
                                          Text(
                                            _listMessages[i].senderName,
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // SizedBox(width: 20,),
                                    // Text(_listMessages[i].credit.toString() + "%", textAlign: TextAlign.center,
                                    //     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black)),
                                    // SizedBox(width: 10,),
                                    // Icon(CupertinoIcons.hand_thumbsup, size: 13, color: Color(0xffD7443E),)
                                  ]),
                                  Row(
                                    children: [
                                      Image.asset(
                                        _listMessages[i].gender.toString() ==
                                                '0'
                                            ? 'assets/img/man.png'
                                            : (_listMessages[i]
                                                        .gender
                                                        .toString() ==
                                                    '1'
                                                ? 'assets/img/woman.png'
                                                : 'assets/img/shop_icon.png'),
                                        height: 16,
                                        fit: BoxFit.fitHeight,
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Color(0xff50529A)),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_pin,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                                _listMessages[i].distance ==
                                                        null
                                                    ? "0 "
                                                    : "${double.parse(_listMessages[i].distance).toStringAsFixed(0).toString()} ${_listMessages[i].distanceUnit.tr()}",
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(_listMessages[i].timeDiff.toString(),
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)),
                                      SizedBox(
                                        width: 1,
                                      ),
                                      Text(_listMessages[i].timeUnit.toString().replaceAll(" ", "").tr(),
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)),
                                      SizedBox(
                                        width: 1,
                                      ),
                                      Text("ago".tr(),
                                          style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)),
                                    ],
                                  )
                                ],
                              ),

                              //messagebody
                              GestureDetector(
                                onLongPress: () {
                                  if (_listMessages[i].senderId.toString() ==
                                      _con.myId.toString()) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("like".tr()),
                                            actions: <Widget>[
                                              GestureDetector(
                                                onTap: () {

                                                  if(checklisttop.length<_con.top_message_num)
                                                    {
                                                      _con.topItUp(_listMessages[i]
                                                          .messageId);

                                                      Navigator.pop(context);

                                                    }
                                                  else{
                                                    _con.cancelTopMessage2(oldtop,_listMessages[i]
                                                        .messageId);
                                                  }


                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 13),
                                                  decoration: BoxDecoration(
                                                      color:  Color(0xff7452A8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    "top".tr(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(
                                                          new ClipboardData(
                                                              text:
                                                                  _listMessages[
                                                                          i]
                                                                      .message))
                                                      .then((_) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Copied to your clipboard !')));
                                                  });
                                                  // _con.topItUp(_listMessages[i].messageId);
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 13),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xff7452A8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    "copy".tr(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  _con.deletemessage(
                                                      _listMessages[i]
                                                          .messageId);

                                                  setState(() {
                                                    _listMessages.removeAt(i);
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 13),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xff7452A8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    "delete".tr(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("like".tr()),
                                            actions: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(
                                                          new ClipboardData(
                                                              text:
                                                                  _listMessages[
                                                                          i]
                                                                      .message))
                                                      .then((_) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Copied to your clipboard !')));
                                                  });
                                                  Navigator.pop(context);
                                                  // _con.topItUp(_listMessages[i].messageId);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 13),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xff7452A8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    "copy".tr(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 46),
                                  padding: EdgeInsets.all(10),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5)),
                                      color: Color(0xfff1f0ef)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Linkify(
                                        onOpen: (link) async {
                                          if (await canLaunch(link.url)) {
                                            await launch(link.url);
                                          } else {
                                            throw 'Could not launch $link';
                                          }
                                        },
                                        text: _listMessages[i].message,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black87),
                                        linkStyle: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.deepPurpleAccent),
                                      ),
SizedBox(height:00,),

                                      if (json.decode(json.encode(_listMessages[i].imgs)).length!=0)
                                        GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5,
                                          crossAxisSpacing: 5.0,
                                          mainAxisSpacing: 5.0,
                                        ),
                                        itemCount: json.decode(json.encode(_listMessages[i].imgs)).length,
                                        itemBuilder: (context, index) {

                                          String normal=json.decode(json.encode(_listMessages[i].imgs))[index].toString();
                                          if(json.decode(json.encode(_listMessages[i].imgs))[index].toString().contains("min"))
                                          return  GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder:
                                                            (_) {
                                                          return DetailScreen(
                                                              url: Constants
                                                                  .SERVER_URL +
                                                                  "v1/roomMessages/img-src/" +normal);
                                                        }));
                                              },
                                              child: Container(
                                                  height: config.App(
                                                      context)
                                                      .appWidth(
                                                      18),
                                                  width: config.App(
                                                      context)
                                                      .appWidth(
                                                      13),
                                                  margin: EdgeInsets
                                                      .only(
                                                      right:
                                                      10),
                                                  decoration:
                                                       BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                  5),
                                              image:
                                              DecorationImage(
                                                image:Image.network(Constants.SERVER_URL + "v1/roomMessages/img-src/"+json.decode(json.encode(_listMessages[i].imgs))[index].toString()).image,
                                                fit: BoxFit
                                                    .fill,
                                              )),
                                          ),
                                           );
                                        },
                                      ) else Container()
                                      // json.decode(json.encode(
                                      //                 _listMessages[i].imgs))
                                      //             .length !=
                                      //         0
                                      //     ? SizedBox(
                                      //
                                      //         child: GridView.builder(
                                      //           scrollDirection: Axis.vertical,
                                      //           shrinkWrap: true,
                                      //           physics:
                                      //               NeverScrollableScrollPhysics(),
                                      //           itemCount: (json
                                      //                       .decode(json.encode(
                                      //                           _listMessages[i]
                                      //                               .imgs))
                                      //                       .length),
                                      //           itemBuilder: (context, index) {
                                      //             // var totalCount = json
                                      //             //     .decode(json.encode(
                                      //             //         _listMessages[i]
                                      //             //             .imgs))
                                      //             //     .length;
                                      //             // var itemCount = 0;
                                      //             // if (totalCount >=
                                      //             //     (index + 1) * 3) {
                                      //             //   itemCount = 0;
                                      //             // } else {
                                      //             //   itemCount = totalCount % 3;
                                      //             // }
                                      //             // if (index == 3) {
                                      //             //   itemCount = 3;
                                      //             // }
                                      //             //
                                      //             // if (totalCount == 3 &&
                                      //             //     index == 1) {
                                      //             //   itemCount = 3;
                                      //             // }
                                      //             // if (totalCount == 6 &&
                                      //             //     index == 2) {
                                      //             //   itemCount = 3;
                                      //             // }
                                      //             return Padding(
                                      //                 padding: EdgeInsets.only(
                                      //                     bottom: 5),
                                      //                 child: Row(
                                      //                   children: [
                                      //                     // if (itemCount ==
                                      //                     //     0) ...[
                                      //                     //   GestureDetector(
                                      //                     //     onTap: () {
                                      //                     //       Navigator.push(
                                      //                     //           context,
                                      //                     //           MaterialPageRoute(
                                      //                     //               builder:
                                      //                     //                   (_) {
                                      //                     //         return DetailScreen(
                                      //                     //             url: Constants
                                      //                     //                     .SERVER_URL +
                                      //                     //                 "v1/roomMessages/img-src/" +
                                      //                     //                 json
                                      //                     //                     .decode(json.encode(_listMessages[i].imgs))[3 * index]
                                      //                     //                     .toString());
                                      //                     //       }));
                                      //                     //     },
                                      //                     //     child: Container(
                                      //                     //       height: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               18),
                                      //                     //       width: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               13),
                                      //                     //       margin: EdgeInsets
                                      //                     //           .only(
                                      //                     //               right:
                                      //                     //                   10),
                                      //                     //       decoration:
                                      //                     //           BoxDecoration(
                                      //                     //               borderRadius:
                                      //                     //                   BorderRadius.circular(
                                      //                     //                       5),
                                      //                     //               image:
                                      //                     //                   DecorationImage(
                                      //                     //                 image:
                                      //                     //                     Image.network(Constants.SERVER_URL + "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index].toString()).image,
                                      //                     //                 fit: BoxFit
                                      //                     //                     .fill,
                                      //                     //               )),
                                      //                     //     ),
                                      //                     //   ),
                                      //                     //   GestureDetector(
                                      //                     //     onTap: () {
                                      //                     //       Navigator.push(
                                      //                     //           context,
                                      //                     //           MaterialPageRoute(
                                      //                     //               builder:
                                      //                     //                   (_) {
                                      //                     //         return DetailScreen(
                                      //                     //             url: Constants
                                      //                     //                     .SERVER_URL +
                                      //                     //                 "v1/roomMessages/img-src/" +
                                      //                     //                 json
                                      //                     //                     .decode(json.encode(_listMessages[i].imgs))[3 * index + 1]
                                      //                     //                     .toString());
                                      //                     //       }));
                                      //                     //     },
                                      //                     //     child: Container(
                                      //                     //       height: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               18),
                                      //                     //       width: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               13),
                                      //                     //       margin: EdgeInsets
                                      //                     //           .only(
                                      //                     //               right:
                                      //                     //                   10),
                                      //                     //       decoration:
                                      //                     //           BoxDecoration(
                                      //                     //               borderRadius:
                                      //                     //                   BorderRadius.circular(
                                      //                     //                       5),
                                      //                     //               image:
                                      //                     //                   DecorationImage(
                                      //                     //                 image:
                                      //                     //                     Image.network(Constants.SERVER_URL + "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index + 1].toString()).image,
                                      //                     //                 fit: BoxFit
                                      //                     //                     .fill,
                                      //                     //               )),
                                      //                     //     ),
                                      //                     //   ),
                                      //                     //   GestureDetector(
                                      //                     //     onTap: () {
                                      //                     //       Navigator.push(
                                      //                     //           context,
                                      //                     //           MaterialPageRoute(
                                      //                     //               builder:
                                      //                     //                   (_) {
                                      //                     //         return DetailScreen(
                                      //                     //             url: Constants
                                      //                     //                     .SERVER_URL +
                                      //                     //                 "v1/roomMessages/img-src/" +
                                      //                     //                 json
                                      //                     //                     .decode(json.encode(_listMessages[i].imgs))[3 * index + 2]
                                      //                     //                     .toString());
                                      //                     //       }));
                                      //                     //     },
                                      //                     //     child: Container(
                                      //                     //       height: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               18),
                                      //                     //       width: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               13),
                                      //                     //       margin: EdgeInsets
                                      //                     //           .only(
                                      //                     //               right:
                                      //                     //                   10),
                                      //                     //       decoration:
                                      //                     //           BoxDecoration(
                                      //                     //               borderRadius:
                                      //                     //                   BorderRadius.circular(
                                      //                     //                       5),
                                      //                     //               image:
                                      //                     //                   DecorationImage(
                                      //                     //                 image:
                                      //                     //                     Image.network(Constants.SERVER_URL + "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index + 2].toString()).image,
                                      //                     //                 fit: BoxFit
                                      //                     //                     .fill,
                                      //                     //               )),
                                      //                     //     ),
                                      //                     //   ),
                                      //                     // ] else if (itemCount ==
                                      //                     //     1) ...[
                                      //                     //   GestureDetector(
                                      //                     //     onTap: () {
                                      //                     //       Navigator.push(
                                      //                     //           context,
                                      //                     //           MaterialPageRoute(
                                      //                     //               builder:
                                      //                     //                   (_) {
                                      //                     //         return DetailScreen(
                                      //                     //             url: Constants
                                      //                     //                     .SERVER_URL +
                                      //                     //                 "v1/roomMessages/img-src/" +
                                      //                     //                 json
                                      //                     //                     .decode(json.encode(_listMessages[i].imgs))[3 * index]
                                      //                     //                     .toString());
                                      //                     //       }));
                                      //                     //     },
                                      //                     //     child: Container(
                                      //                     //       height: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               18),
                                      //                     //       width: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               13),
                                      //                     //       margin: EdgeInsets
                                      //                     //           .only(
                                      //                     //               right:
                                      //                     //                   10),
                                      //                     //       decoration:
                                      //                     //           BoxDecoration(
                                      //                     //               borderRadius:
                                      //                     //                   BorderRadius.circular(
                                      //                     //                       5),
                                      //                     //               image:
                                      //                     //                   DecorationImage(
                                      //                     //                 image:
                                      //                     //                     Image.network(Constants.SERVER_URL + "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index].toString()).image,
                                      //                     //                 fit: BoxFit
                                      //                     //                     .fill,
                                      //                     //               )),
                                      //                     //     ),
                                      //                     //   ),
                                      //                     // ] else if (itemCount ==
                                      //                     //     2) ...[
                                      //                     //   GestureDetector(
                                      //                     //     onTap: () {
                                      //                     //       Navigator.push(
                                      //                     //           context,
                                      //                     //           MaterialPageRoute(
                                      //                     //               builder:
                                      //                     //                   (_) {
                                      //                     //         return DetailScreen(
                                      //                     //             url: Constants
                                      //                     //                     .SERVER_URL +
                                      //                     //                 "v1/roomMessages/img-src/" +
                                      //                     //                 json
                                      //                     //                     .decode(json.encode(_listMessages[i].imgs))[3 * index]
                                      //                     //                     .toString());
                                      //                     //       }));
                                      //                     //     },
                                      //                     //     child: Container(
                                      //                     //       height: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               18),
                                      //                     //       width: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               13),
                                      //                     //       margin: EdgeInsets
                                      //                     //           .only(
                                      //                     //               right:
                                      //                     //                   10),
                                      //                     //       decoration:
                                      //                     //           BoxDecoration(
                                      //                     //               borderRadius:
                                      //                     //                   BorderRadius.circular(
                                      //                     //                       5),
                                      //                     //               image:
                                      //                     //                   DecorationImage(
                                      //                     //                 image:
                                      //                     //                     Image.network(Constants.SERVER_URL + "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index].toString()).image,
                                      //                     //                 fit: BoxFit
                                      //                     //                     .fill,
                                      //                     //               )),
                                      //                     //     ),
                                      //                     //   ),
                                      //                     //   GestureDetector(
                                      //                     //     onTap: () {
                                      //                     //       Navigator.push(
                                      //                     //           context,
                                      //                     //           MaterialPageRoute(
                                      //                     //               builder:
                                      //                     //                   (_) {
                                      //                     //         return DetailScreen(
                                      //                     //             url: Constants
                                      //                     //                     .SERVER_URL +
                                      //                     //                 "v1/roomMessages/img-src/" +
                                      //                     //                 json
                                      //                     //                     .decode(json.encode(_listMessages[i].imgs))[3 * index + 1]
                                      //                     //                     .toString());
                                      //                     //       }));
                                      //                     //     },
                                      //                     //     child: Container(
                                      //                     //       height: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               18),
                                      //                     //       width: config.App(
                                      //                     //               context)
                                      //                     //           .appWidth(
                                      //                     //               13),
                                      //                     //       margin: EdgeInsets
                                      //                     //           .only(
                                      //                     //               right:
                                      //                     //                   10),
                                      //                     //       decoration:
                                      //                     //           BoxDecoration(
                                      //                     //               borderRadius:
                                      //                     //                   BorderRadius.circular(
                                      //                     //                       5),
                                      //                     //               image:
                                      //                     //                   DecorationImage(
                                      //                     //                 image:
                                      //                     //                     Image.network(Constants.SERVER_URL + "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index + 1].toString()).image,
                                      //                     //                 fit: BoxFit
                                      //                     //                     .fill,
                                      //                     //               )),
                                      //                     //     ),
                                      //                     //   ),
                                      //                     ]
                                      //
                                      //                 ));
                                      //           },
                                      //         ),
                                      //       )
                                      //     : Container()
                                    ],
                                  ),
                                ),
                              )
                            ]));
                  },


                  itemCount: _listMessages.length,
                ),
              ),
            )),
          ],
        ));
  }

  Widget chatBox() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
          margin: EdgeInsets.only(bottom: config.App(context).appWidth(15)),
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
          width: double.infinity,
          color: Color(0xfff3f2f2),
          child: Column(
            children: [
              if (publicImagePaths.isNotEmpty) ...[
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: publicImagePaths.length,
                    itemBuilder: (context, index) {
                      var item = publicImagePaths[index];

                      return new Container(
                        margin: EdgeInsets.only(
                            right: config.App(context).appWidth(3)),
                        child: Image.file(new File(item),
                            width: config.App(context).appWidth(7),
                            fit: BoxFit.fill),
                      );
                    },
                  ),
                )
              ],
              SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                      onTap: () async {
                        publicChatImageRes = await ImagesPicker.pick(
                          count: 9,
                          pickType: PickType.all,
                          language: Language.System,
                          // maxSize: 500,

                        );
                        setState(() {
                          if (publicImagePaths.length < 9) {
                            publicChatImageRes
                                .map((e) => publicImagePaths.add(e.path))
                                .toList();

                          convertthubnail(publicImagePaths);
                          }
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Image.asset(
                          'assets/img/image_icon.png',
                          height: config.App(context).appWidth(4),
                          fit: BoxFit.fitHeight,
                        ),
                      )),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextFormField(
                      minLines: 1,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        // suffixIcon: Padding(
                        //   padding: EdgeInsets.only(right: 10),
                        //   child: Icon(Icons.emoji_emotions,size: 24, color: Color(0xff9496DE)),
                        // ),
                        suffixIconConstraints: BoxConstraints(maxHeight: 50),
                        hintText: "Aa",
                        hintStyle:
                            TextStyle(color: Colors.black54, fontSize: 16),
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(20)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      controller: chatcontroller,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                      onTap: () {
                        if (chatcontroller.text.trim().length == 0) {
                          Fluttertoast.showToast(
                              msg: 'input'.tr());
                        } else {
                          if (!isMessageSent) {
                            _sendMessage();
                            FocusManager.instance.primaryFocus?.unfocus();

                          }
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: isMessageSent
                            ? Image.asset(
                                'assets/img/send_icon.png',
                                height: config.App(context).appWidth(4),
                                fit: BoxFit.fitHeight,
                              )
                            : Image.asset(
                                'assets/img/send_icon.png',
                                color: Color(0xff9496DE),
                                height: config.App(context).appWidth(4),
                                fit: BoxFit.fitHeight,
                              ),
                      ))
                ],
              ),
            ],
          )),
    );
  }

  Future<void> uploadMultiImages() async {
    var formData = FormData();
    for (var file in publicImagePathsthumbnail) {
      formData.files.addAll([
        MapEntry(
            "img",
            await MultipartFile.fromFile(
              file,
              filename: file.split('/').last,
            )),
      ]);
    }
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');
    Dio dio = new Dio();

    dio
        .post(
      Constants.SERVER_URL + 'v1/roomMessages/upload_multi_imgs',
      data: formData,
      options: Options(
        headers: {HttpHeaders.AUTHORIZATION: 'Bearer ' + token},
      ),
    )
        .then((response) {
      var result = jsonDecode(response.toString());
      if (result['error'] == false) {
        print('data');

        setState(() {
          uploadingImageUrls = result['data'];
        });
        final messageId = uuid.v1();
        final mainMap = <String, Object>{};
        mainMap['room_id'] = "61946f1e3e9419cb1103ed1a";
        mainMap['sender_id'] = Constants.userresponse['user']['_id'];
        mainMap['sender_name'] = Constants.userresponse['user']['name'];
        mainMap['message'] = chatcontroller.text.trim();
        mainMap['messageId'] = messageId;
        mainMap['img'] = "";
        mainMap['imgs'] = uploadingImageUrls;
        final jsonString = convert.jsonEncode(mainMap);
        socket.emit('new_comment', jsonString);

        setState(() {
          isMessageSent = false;
          _listMessages.insert(
              0,
              (MessageModel(
                  messageId: messageId,
                  message: chatcontroller.text.trim(),
                  img: '',
                  imgs: uploadingImageUrls,
                  senderId: Constants.userresponse['user']['_id'],
                  senderName: Constants.userresponse['user']['name'],
                  nickname: Constants.userresponse['user']['name'],
                  gender: Constants.userresponse['user']['gender'].toString(),
                  like: Constants.userresponse['user']['like'],
                  dislike: Constants.userresponse['user']['dislike'],
                  online: Constants.userresponse['user']['online'],
                  avatarUrl: Constants.userresponse['user']['avatarUrl'],
                  timeDiff: '1min ago',
                  distanceUnit: 'km',
                  distance: "0",
                  createdAt: 0,
                  roomId: '61946f1e3e9419cb1103ed1a')));
          message = '';
          chatcontroller.text = '';
        });

        _scrollToLast();

        publicImagePaths = [];
        publicChatImageRes = [];
      }
    }).catchError((error) => print(error));
  }

  showbottom(int i, context) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Color(0xff9496DE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Container(
                    color: Colors.white,
                    width: 40,
                    height: 4,
                  ),
                ),
                SizedBox(
                  height: 50,
                ), Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: config.App(context).appWidth(12),
                          height: config.App(context).appWidth(12),
                          child: Container(
                            margin:
                                EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffC4C4C4).withOpacity(0.55),
                                image: DecorationImage(
                                    image: Image.network(Constants.SERVER_URL +
                                            "v1/user/img-src/" +
                                            _listMessages[i].avatarUrl.toString())
                                        .image,
                                    fit: BoxFit.fill)),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _listMessages[i].senderName,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Container(
                              width:90,
                              child: Text(
                                _listMessages[i].email.toUpperCase(),
                                maxLines:2,
                                style: TextStyle(color: Colors.white,fontSize:12),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              _listMessages[i].gender.toString() == '0'
                                  ? 'assets/img/man.png'
                                  : (_listMessages[i].gender.toString() == '1'
                                      ? 'assets/img/woman.png'
                                      : 'assets/img/shop_icon.png'),
                              height: 16,
                              fit: BoxFit.fitHeight,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xff4089D3)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_pin,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      double.parse(
                                               _listMessages[i].distance)
                                               .toStringAsFixed(0)
                                               .toString() +
                                               _listMessages[i].distanceUnit.tr(),

                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(_listMessages[i].credit + "%",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                            SizedBox(
                              width: 6,
                            ),
                            Icon(
                              CupertinoIcons.hand_thumbsup,
                              size: 13,
                              color: Color(0xffD7443E),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // Image.asset(_listMessages[i].gender.toString() == '0' ? 'assets/img/man.png': (_listMessages[i].gender.toString() == '1'? 'assets/img/woman.png': 'assets/img/shop_icon.png'), height: 16, fit: BoxFit.fitHeight,),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width ,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [


                      Column(
                        children: [
                          GestureDetector(
                            onTap:(){

                              _con.setLike(_listMessages[i].senderId.toString());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5),

                              width: config.App(context).appWidth(30),
                              height: config.App(context).appWidth(7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10)),
                                  color: Color(0xffB3B5E7)),
                              child: Icon(
                                CupertinoIcons.hand_thumbsup_fill,
                                size: 20,
                                color: Color(0xffD7443E),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            onTap: (){
                              _con.setDislike(_listMessages[i].senderId.toString());
                            },
                            child: Container(
                              width: config.App(context).appWidth(30),
                                                            height: config.App(context).appWidth(7),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                   bottomLeft: Radius.circular(10)),
                                                                color: Color(0xffB3B5E7)),
                                                            padding: EdgeInsets.symmetric(vertical: 5),
                              child: Icon(
                                CupertinoIcons.hand_thumbsdown,
                                size: 20,
                                color: Color(0xffD7443E),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          _con.createRoom(
                              _listMessages[i].senderId.toString(),_listMessages[i].credit,_listMessages[i].distance,_listMessages[i].distanceUnit);

                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                            width: config.App(context).appWidth(30),
                                                        height: config.App(context).appWidth(15),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(10),
                                                                bottomRight: Radius.circular(10)),
                                                            color: Color(0xffB3B5E7)),

                          child: Center(
                              child: Text(
                            "private_chat".tr(),
                            style: TextStyle(color: Colors.white),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        });
  }
  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 38,

    );


    return result;
  }
  convertthubnail(List listofimages)
  async {
    publicImagePathsthumbnail.clear();
    for(var filee in listofimages)
      {

        
        String extension=filee.toString().split('.').last;
        String fileName = filee.split('/').last;
        log(pathh.basenameWithoutExtension(fileName));

        String dir = pathh.dirname(filee); //get directory
        String targetfile=dir+"/"+pathh.basenameWithoutExtension(fileName)+"."+"min"+"."+extension;

        var file=await testCompressAndGetFile(File(filee) ,targetfile);
        publicImagePathsthumbnail.add(file.path);


      }

    for(var filname in publicImagePaths)
      {
        publicImagePathsthumbnail.add(filname);
      }

for(var fill in publicImagePathsthumbnail)
  {
    log(fill.toString());
  }


  }
  // void openChattingModal(context, int i) async {
  //   showCupertinoModalPopup(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setStater) {
  //           return Card(
  //             elevation: 4,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(28)),
  //             child: Container(
  //               width: config.App(context).appWidth(100),
  //               height: config.App(context).appWidth(70),
  //               padding: EdgeInsets.only(top: 15),
  //               decoration: BoxDecoration(
  //                   color: Color(0xff9496DE),
  //                   borderRadius: BorderRadius.only(
  //                       topLeft: Radius.circular(25),
  //                       topRight: Radius.circular(25))),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     height: 4.0,
  //                     width: 35,
  //                     decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         borderRadius: BorderRadius.circular(20)),
  //                   ),
  //                   SizedBox(
  //                     height: 50,
  //                   ),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Container(
  //                         width: config.App(context).appWidth(12),
  //                         height: config.App(context).appWidth(12),
  //                         decoration: BoxDecoration(
  //                             shape: BoxShape.circle,
  //                             color: Color(0xffC4C4C4).withOpacity(0.55),
  //                             image: DecorationImage(
  //                                 image: Image.network(Constants.SERVER_URL +
  //                                         "v1/user/img-src/" +
  //                                         _listMessages[i].avatarUrl.toString())
  //                                     .image,
  //                                 fit: BoxFit.fill)),
  //                       ),
  //                       SizedBox(
  //                         width: 40,
  //                       ),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Row(
  //                             children: [
  //                               SizedBox(
  //                                 width: 50,
  //                                 child: Text(
  //                                   _listMessages[i].senderName,
  //                                   textAlign: TextAlign.left,
  //                                   overflow: TextOverflow.ellipsis,
  //                                   maxLines: 1,
  //                                   style: TextStyle(
  //                                       fontSize: 13,
  //                                       fontWeight: FontWeight.w500,
  //                                       color: Colors.black),
  //                                 ),
  //                               ),
  //                               SizedBox(
  //                                 width: 10,
  //                               ),
  //                               Image.asset(
  //                                 _listMessages[i].gender.toString() == '0'
  //                                     ? 'assets/img/man.png'
  //                                     : (_listMessages[i].gender.toString() ==
  //                                             '1'
  //                                         ? 'assets/img/woman.png'
  //                                         : 'assets/img/shop_icon.png'),
  //                                 height: 16,
  //                                 fit: BoxFit.fitHeight,
  //                               ),
  //                             ],
  //                           ),
  //                           SizedBox(
  //                             height: 10,
  //                           ),
  //                           Row(
  //                             children: [
  //                               Text(_listMessages[i].email,
  //                                   style: TextStyle(
  //                                       fontSize: 13,
  //                                       fontWeight: FontWeight.w500,
  //                                       color: Colors.white)),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(
  //                         width: 40,
  //                       ),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Container(
  //                             padding: EdgeInsets.symmetric(
  //                                 horizontal: 20, vertical: 5),
  //                             decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.circular(20),
  //                                 color: Color(0xff4089D3)),
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.location_on_rounded,
  //                                   size: 12,
  //                                   color: Colors.white,
  //                                 ),
  //                                 SizedBox(
  //                                   width: 5,
  //                                 ),
  //                                 Text(
  //                                     _listMessages[i].distance == null
  //                                         ? "0"
  //                                         : double.parse(
  //                                                     _listMessages[i].distance)
  //                                                 .toStringAsFixed(0)
  //                                                 .toString() +
  //                                             _listMessages[i].distanceUnit,
  //                                     style: TextStyle(
  //                                         fontSize: 13,
  //                                         fontWeight: FontWeight.w500,
  //                                         color: Colors.white))
  //                               ],
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             height: 10,
  //                           ),
  //                           Row(
  //                             children: [
  //                               Text(_listMessages[i].credit + "%",
  //                                   style: TextStyle(
  //                                       fontSize: 13,
  //                                       fontWeight: FontWeight.w500,
  //                                       color: Colors.white)),
  //                               SizedBox(
  //                                 width: 5,
  //                               ),
  //                               Icon(
  //                                 CupertinoIcons.hand_thumbsup,
  //                                 size: 13,
  //                                 color: Colors.red,
  //                               )
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     height: 50,
  //                   ),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           GestureDetector(
  //                             onTap: () {
  //                               _con.setLike(
  //                                   _listMessages[i].senderId.toString());
  //                             },
  //                             child: Container(
  //                               width: config.App(context).appWidth(30),
  //                               height: config.App(context).appWidth(7),
  //                               decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.only(
  //                                       topLeft: Radius.circular(10)),
  //                                   color: Color(0xffB3B5E7)),
  //                               padding: EdgeInsets.symmetric(vertical: 5),
  //                               child: Icon(
  //                                 CupertinoIcons.hand_thumbsup_fill,
  //                                 size: 22,
  //                                 color: Colors.red,
  //                               ),
  //                             ),
  //                           ),
  //                           SizedBox(
  //                             height: config.App(context).appWidth(1),
  //                           ),
  //                           GestureDetector(
  //                             onTap: () {
  //                               _con.setDislike(
  //                                   _listMessages[i].senderId.toString());
  //                             },
  //                             child: Container(
  //                               width: config.App(context).appWidth(30),
  //                               height: config.App(context).appWidth(7),
  //                               decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.only(
  //                                       bottomLeft: Radius.circular(10)),
  //                                   color: Color(0xffB3B5E7)),
  //                               padding: EdgeInsets.symmetric(vertical: 5),
  //                               child: Icon(
  //                                 CupertinoIcons.hand_thumbsdown,
  //                                 size: 22,
  //                                 color: Colors.red,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(
  //                         width: 5,
  //                       ),
  //                       GestureDetector(
  //                         onTap: () async {
  //                           _con.createRoom(
  //                               _listMessages[i].senderId.toString());
  //
  //                           final sharedPreferences = await SharedPreferences.getInstance();
  //                           final meId = sharedPreferences.getString('_id');
  //                           // Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: _con.rooms[i]['_id'].toString()));
  //                           // Navigator.of(context).pushNamed('/ChatScreen', arguments: RouteArgument(subData: _con.rooms[i]['_id'].toString(), heroTag: userInfo['_id'].toString(), id: meId.toString(), param: {"distance": double.parse(_con.rooms[i]['friend']["distance"]).toStringAsFixed(0).toString()+ _con.rooms[i]['friend']["distance_unit"], "credit": _con.rooms[i]['friend']["credit"] } ) );
  //
  //                         },
  //                         child: Container(
  //                             width: config.App(context).appWidth(30),
  //                             height: config.App(context).appWidth(15),
  //                             decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.only(
  //                                     topRight: Radius.circular(10),
  //                                     bottomRight: Radius.circular(10)),
  //                                 color: Color(0xffB3B5E7)),
  //                             child: Center(
  //                               child: Text(S.of(context).private_chat,
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                       fontSize: 13,
  //                                       fontWeight: FontWeight.w500,
  //                                       color: Colors.white)),
  //                             )),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     width: 10,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
