import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as pathh;

import 'package:image_picker/image_picker.dart';
import 'package:images_picker/images_picker.dart';
import 'package:locals/src/controllers/private_chat_controller.dart';
import 'package:locals/src/elements/DetailScreen.dart';
import 'package:locals/src/models/message_model.dart';
import 'package:locals/src/models/private_message_model.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:locals/src/utils/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:file/local.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import 'package:uuid/uuid.dart' as UID;
import 'package:easy_localization/src/public_ext.dart';

// private chat screen

class ChatScreenWidget extends StatefulWidget {
  @override
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final RouteArgument routeArgument;

  ChatScreenWidget({Key key, this.parentScaffoldKey, this.routeArgument}) : super(key: key);
  @override
  _ChatScreenWidgetState createState() => _ChatScreenWidgetState();
}

class _ChatScreenWidgetState extends StateMVC<ChatScreenWidget> {

  PrivateChatController _con;
  TextEditingController chatcontroller = TextEditingController();
  int numberOfUsersConnectedToThisRoom = 1;

  String roomId ;
  String partnerId ;
  io.Socket socket;
  FocusNode _focusNode;
  String message = '';
  bool isCurrentUserTyping = false;
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

  List<Media> privateChatImageRes = new List<Media>();
  var publicImagePathsthumbnail = [];

  var privateImagePaths = [];
  var uploadingImageUrls = [];

  _ChatScreenWidgetState() : super(PrivateChatController()) {
    _con = controller;
  }

  Color senderFontColor = Colors.black;
  Color receiverFontColor = Colors.white;
 List<String>thumbnail=[];
 List<String>original=[];
  List<String>cthumbnail=[];
  List<String>coriginal=[];
  int page;
  final uuid = UID.Uuid();

  @override
  void initState()  {
    super.initState();


    log("------token");
    FirebaseMessaging.instance.getToken().then((value) {
      String token = value;

      log("------token" + token);
    });
    print("Room ID: " + widget.routeArgument.subData);
    print("Partner ID: " + widget.routeArgument.heroTag);
    roomId = widget.routeArgument.subData;

    partnerId = widget.routeArgument.heroTag;
    page = 1;
    initUsers();
    _con.getSettings();


    // initializeDateFormatting();
    initSocket();
    _scrollController = ScrollController(initialScrollOffset: 0);
    final emitLastMessageAsSeen = {};
    emitLastMessageAsSeen['chat_id'] = roomId;
    emitLastMessageAsSeen['user_id'] = Constants.userresponse['user']['_id'];
    final myLastMessageAsSeenJson = convert.jsonEncode(emitLastMessageAsSeen);
    socket.emit("makeLastMessageAsSeen", myLastMessageAsSeenJson);
    _con.updatecount(widget.routeArgument.subData, "0");

  }
  initUsers() async {
    setState(() {
      _con.loading = true;
    });
      var meId = widget.routeArgument.id;
      var meinfos = await _con.getUserData(meId);
      var partinfos = await _con.getUserData(partnerId);
      // log(partinfos)

      _con.meInfo = meinfos['data'];
      _con.partnerInfo = partinfos['data'];

      await getLastMessages();
      setState(() {
        _con.loading = false;
      });


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
    map['chatId'] = roomId;
    final myJson = convert.jsonEncode(map);
    socket.emit("joinChat", myJson);
  }
  void initSocket() async {
    final url = "${Constants.SOCKET_URL}/api/message";
    socket = io.io('$url', <String, dynamic>{
      'transports': ['websocket']
    });
    socket.on('connect', (_) {
      sendJoinChat();
    });

    socket.on('msgReceive', _onReceiveMessage);
  }
  void _onReceiveMessage(msg) {
    // final messageType = int.parse(data['message_type']);
    // print('type isssssssss $messageType');
    // final img = data['img'];

    setState(() {
      _con.listMessages.insert(
          0,
          PrivateMessageModel(
            id: msg['_id'],
            message: msg['message'],
            messageType: msg["message_type"],
            imgs: msg['imgs'],
            senderId: msg['sender_id'],
            receiverId: msg['receiver_id'],
            createdAt: int.parse(msg['createdAt'] == null ? '0': msg['createdAt'].toString()),
            roomId: msg['roomId'],
            isDeleted: int.parse(msg['isDeleted'] ==  null ? '0': msg['isDeleted'].toString()),
          ));
    });
  }
  void getLastMessages() async {
     await _con.getPrivateAllMessages(roomId);

     for(int i=0;i<_con.listMessages.length;i++)
     {
      if (_con.listMessages[i].senderId != _con.meInfo['_id'])

       {
         for(String img in _con.listMessages[i].imgs )
         {

           if(img.contains("min"))
           {
             setState(() {

               cthumbnail.add(img);
             });

           }
           else{
             coriginal.add(img);
           }
         }
       }
       else{


       for(String img in _con.listMessages[i].imgs )
         {

           if(img.contains("min"))
             {
               setState(() {

                 thumbnail.add(img);
               });

             }
           else{
             original.add(img);
           }
         }}



     }
  }

  _sendMessage({String img = ''}) async {
    if( chatcontroller.text.length > _con.limit_letters){
      Fluttertoast.showToast(msg: "letter".tr() + _con.limit_letters.toString());
    } else {
      final messageId = uuid.v1();
      final mainMap = <String, Object>{};
      mainMap['messageId'] = messageId;
      mainMap['chat_id'] = roomId;
      mainMap['sender_id'] = Constants.userresponse['user']['_id'];
      mainMap['receiver_id'] = _con.partnerInfo['_id'];
      mainMap['message'] = chatcontroller.text.trim();
      mainMap['imgs'] = [];
      mainMap['message_type'] = 1;

      final jsonString = convert.jsonEncode(mainMap);
      if(chatcontroller.text.trim().length == 0 && privateImagePaths.length == 0) {
        Fluttertoast.showToast(msg: 'empty'.tr());
      } else {
        if(privateImagePaths.length > 0 ) {
          await uploadMultiImages();
        } else {
          isMessageSent  = true;
          socket.emit('new_message', jsonString);
_con.sendnotif(chatcontroller.text.trim(),"You have a new message",_con.partnerInfo['deviceToken']);
          setState(() {
            isMessageSent = false;
            _con.listMessages.insert(
                0,
                (PrivateMessageModel(
                    id: messageId,
                    message: chatcontroller.text.trim(),
                    imgs: [],
                    senderId: Constants.userresponse['user']['_id'],
                    messageType: 1,
                    receiverId: _con.partnerInfo['_id'],
                    createdAt: 0,
                    roomId: roomId,
                    isDeleted: 0
                )));
            message = '';
            chatcontroller.text = '';
          });
          _scrollToLast();
        }
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

  Widget progress = Container(
    padding: EdgeInsets.symmetric(vertical: 15),
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      backgroundColor: Colors.green,
      strokeWidth: 7,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: "0"));

      },
      child: Scaffold(
          backgroundColor: Colors.white,
        key: _con.scaffoldKey,
        // resizeToAvoidBottomPadding: false,
        body: Container(
          height: double.infinity,
          child:  Column(
            children: [
              headBox(),
              Expanded(child: _con.loading ? progress: mainContent(),),
              chatBox()
            ],
          ),
        )
      ),
    );
  }

  Widget headBox() {
    return Container(
      height: config.App(context).appWidth(20),
      padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(5)),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          color: Color(0xff9496DE)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: "0"));
              // Navigator.of(context).pushNamed('/ChatRooms');
            },
            child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white,),
          ),
          SizedBox(width: 30,),
          Stack(
            children: [
              _con.meInfo == null ?
              Container(
                width: config.App(context).appWidth(12),
                height: config.App(context).appWidth(12),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xffC4C4C4).withOpacity(0.55)
                ),
                child: Center(
                  child: Image.asset('assets/img/avatar2.png', fit: BoxFit.fitWidth,),
                ),
              ):
              Container(
                width: config.App(context).appWidth(12),
                height: config.App(context).appWidth(12),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xffC4C4C4).withOpacity(0.55),
                    image: DecorationImage(
                      image: Image.network(Constants.SERVER_URL+ "v1/user/img-src/" + _con.partnerInfo['avatarUrl']).image,
                      fit: BoxFit.cover,
                    )
                ),
              ),

              Padding(
                  padding: EdgeInsets.only(left: config.App(context).appWidth(9), top: config.App(context).appWidth(9)),
                  child: Container(
                    width: 12, height: 12,
                    padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white
                    ),
                    child: Container(
                      width: 11, height: 11,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.green
                      ),
                    ),
                  )
              )
            ],
          ),
          SizedBox(width: 20,),
          SizedBox(height: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _con.meInfo != null?
                    Text(_con.partnerInfo['name'], textAlign: TextAlign.center, maxLines: 1,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white))
                    : Text("", textAlign: TextAlign.center, maxLines: 1,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(width: 10,),
                    if(_con.partnerInfo != null) ...[
                      if(_con.partnerInfo['gender'].toString() == '0') ...[
                        Image.asset('assets/img/man.png', height: 20, fit: BoxFit.fitHeight,),
                      ] else if(_con.partnerInfo['gender'].toString() == '1') ...[
                        Image.asset('assets/img/woman.png', height: 20, fit: BoxFit.fitHeight,),
                      ] else ...[
                        Image.asset('assets/img/shop_icon.png', height: 20, fit: BoxFit.fitHeight,),
                      ]
                    ]
                  ],
                ),
                Row(
                  children: [
                    Text(widget.routeArgument.param == null ? "" : widget.routeArgument.param['distance'], textAlign: TextAlign.center, maxLines: 1,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white)),
                    SizedBox(width: 5),
                    Icon(Icons.circle, size: 3, color: Colors.white,),
                    Text(widget.routeArgument.param == null ? "" : widget.routeArgument.param['credit'] + "%", textAlign: TextAlign.center, maxLines: 1,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white)),
                    SizedBox(width: 5),
                    Icon(CupertinoIcons.hand_thumbsup, color: Color(0xffD7443E), size: 12,)
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onLoadMore() {
    startLoadMore();
  }

  void startLoadMore() async {
    setState(() {
      _con.listMessages.clear();
    });
    var jsonResponse = await _con.getPrivateAllMessages(roomId);

    if (jsonResponse['error'] == false) {
      final data = jsonResponse['data'] as List;
      _con.listMessages.addAll(data.map((e) => PrivateMessageModel.fromMap(e)).toList());

      setState(() {});
    }

    if(_con.listMessages.length > 0){
      setState(_refreshController.loadComplete);
    } else {
      _refreshController.loadNoData();
    }
  }

  Widget mainContent() {
    return Container(
      width: config.App(context).appWidth(100),
      padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(5), vertical: 25),

      child: Column(
        children: [
          Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                header: WaterDropHeader(),
                onLoading: _onLoadMore,
                enablePullUp: false,
                enablePullDown: false,
                child: ListView.builder(
                    shrinkWrap: true,
                    reverse: true,
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: _con.listMessages.length,
                    itemBuilder: (BuildContext context, int index) {
                      if(_con.listMessages[index].senderId == _con.meInfo['_id']) {
                        return GestureDetector(
                          onLongPress:(){


                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("like").tr(),
                                      actions: <Widget>[
                                        GestureDetector(

                                          onTap: () {
                                             log(_con.listMessages[index].id);

                                             Clipboard.setData(new ClipboardData(text:_con.listMessages[index].message)).then((_){
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(content: Text('copied').tr()));
                                            });
                                            Navigator.pop(context);
                                            // _con.topItUp(_listMessages[i].messageId);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal:15, vertical:13),
                                            decoration: BoxDecoration(
                                                color:  Color(0xff7452A8),
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: Text("copy", style: TextStyle(color: Colors.white, fontSize: 12),).tr(),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                           _con.deletemessage(_con.listMessages[index].id);
                                           setState(() {
                                             _con.listMessages.removeAt(index);


                                           });
                                           Navigator.pop(context);

                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal:15, vertical:13),
                                            decoration: BoxDecoration(
                                                color: Color(0xff7452A8),
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: Text("delete", style: TextStyle(color: Colors.white, fontSize: 12),).tr(),
                                          ),
                                        ),

                                      ],
                                    );
                                  });


                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if(_con.listMessages[index].message.isNotEmpty) ... [
                                Container(
                                  color: Color(0xff9496DE),
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: 30.0,
                                      maxWidth: 300.0,
                                    ),
                                    child: Linkify(
                                      onOpen: (link) async {

                                        if (await canLaunch(link.url)) {
                                          await launch(link.url);
                                        } else {
                                          throw 'Could not launch $link';
                                        }
                                      },
                                      text:
                                      _con.listMessages[index].message,
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white),
                                      linkStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],

                              // Container(
                              //   color: Color(0xff9496DE),
                              //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              //   child: Text(_con.listMessages[index].message,
                              //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)),
                              // ),
                              SizedBox(height: 5,),
                              if((_con.listMessages[index].imgs as List).length > 0)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      return DetailScreen(url: Constants.SERVER_URL+ "v1/message/img-src/" + (coriginal.toString()));
                                    }));
                                  },
                                  child: Image.network(Constants.SERVER_URL+ "v1/message/img-src/" + (cthumbnail[index].toString()) ,width: config.App(context).appWidth(60), fit: BoxFit.fitWidth,),
                                ),
                              Padding(
                                  padding: EdgeInsets.only(right: 10, top: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(_con.listMessages[index].sendTime != null ? _con.listMessages[index].sendTime.toString() : DateFormat('hh:mm').format(DateTime.now()),
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xffACACAC))),
                                      // SizedBox(width: 10,),
                                      // Image.asset('assets/img/confirm_icon.png', width: 20, fit: BoxFit.fitWidth,)
                                    ],
                                  )
                              )
                            ],
                          ),
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: config.App(context).appWidth(8),
                                  height: config.App(context).appWidth(8),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: Color(0xffC4C4C4).withOpacity(0.55),
                                      image: DecorationImage(
                                        image: Image.network(Constants.SERVER_URL+ "v1/user/img-src/" + _con.partnerInfo['avatarUrl']).image,
                                        fit: BoxFit.cover,
                                      )
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: config.App(context).appWidth(6), top: config.App(context).appWidth(6)),
                                    child: Container(
                                      width: 10, height: 10,
                                      padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle, color: Colors.white
                                      ),
                                      child: Container(
                                        width: 9, height: 9,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle, color: Colors.green
                                        ),
                                      ),
                                    )
                                )
                              ],
                            ),
                            SizedBox(width: 15,),
                            GestureDetector(

                      onLongPress:(){
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("like").tr(),
                                        actions: <Widget>[
                                          GestureDetector(

                                            onTap: () {
                                              log(_con.listMessages[index].id);

                                              Clipboard.setData(new ClipboardData(text:_con.listMessages[index].message)).then((_){
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(content: Text('copied').tr()));
                                              });
                                              Navigator.pop(context);
                                              // _con.topItUp(_listMessages[i].messageId);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal:15, vertical:13),
                                              decoration: BoxDecoration(
                                                  color:Color(0xff7452A8),
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
                                              child: Text("copy", style: TextStyle(color: Colors.white, fontSize: 12),).tr(),
                                            ),
                                          ),

                                        ],
                                      );
                                    });
                              },
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if(_con.listMessages[index].message.isNotEmpty) ...[
                                    Container(
                                      color: Color(0xffEBECF2),
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: 30.0,
                                          maxWidth: 300.0,
                                        ),
                                        child:Linkify(
                      onOpen: (link) async {

                      if (await canLaunch(link.url)) {
                      await launch(link.url);
                      } else {
                      throw 'Could not launch $link';
                      }
                      },
                      text:
                      _con.listMessages[index].message,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xff7452A8)),
                      linkStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color:Color(0xff7452A8),
                      ))

                                      ),
                                    ),
                                  ],

                                  // Container(
                                  //   width: config.App(context).appWidth(35),
                                  //   color: Color(0xffEBECF2),
                                  //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  //   child: Text(_con.listMessages[index].message,
                                  //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff7452A8))),
                                  // ),

                                 if (json.decode(json.encode(_con.listMessages[index].imgs)).length>0)

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                                          return DetailScreen(url: Constants.SERVER_URL+ "v1/message/img-src/" + (original[index].toString()));
                                        }));
                                      },
                                      child: Image.network(Constants.SERVER_URL+ "v1/message/img-src/" + (thumbnail[index].toString()), width: config.App(context).appWidth(60), fit: BoxFit.fitWidth,),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10, top: 5),
                                    child: Text(_con.listMessages[index].sendTime != null ? _con.listMessages[index].sendTime : DateFormat('HH:mm').format(DateTime.now()),
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xffACACAC))),
                                  )
                                ],
                              ),
                            )
                          ],
                        );
                      }

                    }
                ),
              ),)
        ],
      )
    );
  }

  Widget chatBox() {
    return  Container(
        margin: EdgeInsets.only(bottom: config.App(context).appWidth(2)),
        padding: EdgeInsets.only(left: 20,right: 20,bottom: 10,top: 10),
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            // if(privateImagePaths.isNotEmpty)... [
            //   SizedBox(height: 40,
            //     child: ListView.builder(
            //       scrollDirection: Axis.horizontal,
            //       itemCount: privateImagePaths.length,
            //       itemBuilder: (context, index) {
            //         var item = privateImagePaths[index];
            //
            //         return new Container(
            //           margin: EdgeInsets.only(right: config.App(context).appWidth(3)),
            //           child: Image.file(
            //               new File(item),
            //               width: config.App(context).appWidth(7),
            //               fit: BoxFit.fill
            //           ),
            //         );
            //       },
            //     ),
            //   )
            // ],
            SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                    onTap: () async {
                      // PickedFile image = await _picker
                      //     .getImage(
                      //     source: ImageSource.gallery
                      // );
                      privateChatImageRes = await ImagesPicker.pick(
                        count: 1,
                        pickType: PickType.all,
                        language: Language.System,
                        // maxSize: 500,

                      );
                      setState(() {
                        if(privateImagePaths.length < 1) {
                          privateChatImageRes.map((e) => privateImagePaths.add(e.path)).toList();
                          isMessageSent = true;
                          convertthubnail(privateImagePaths);

                        }

                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Image.asset('assets/img/image_icon.png', height: config.App(context).appWidth(4), fit: BoxFit.fitHeight,),
                    )
                ),
                SizedBox(width: 15,),
                Expanded(
                  child: TextFormField(
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(fontSize: 16,),
                    decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      contentPadding:EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      // suffixIcon: Padding(
                      //   padding: EdgeInsets.only(right: 10),
                      //   child: Icon(Icons.emoji_emotions,size: 24, color: Color(0xff9496DE)),
                      // ),
                      suffixIconConstraints: BoxConstraints(maxHeight: 50),
                      hintText: "Aa",
                      hintStyle: TextStyle(color: Colors.black54, fontSize: 16),
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0), borderRadius: BorderRadius.circular(20)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0), borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                    controller: chatcontroller,
                  ),
                ),
                SizedBox(width: 20,),
                GestureDetector(
                    onTap: () {
                      if(!isMessageSent) {
                        _sendMessage();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: isMessageSent ? Image.asset('assets/img/send_icon.png',  height: config.App(context).appWidth(4), fit: BoxFit.fitHeight,)
                          : Image.asset('assets/img/send_icon.png', color: Color(0xff9496DE), height: config.App(context).appWidth(4), fit: BoxFit.fitHeight,),
                    )
                )
              ],

            ),
          ],
        )
    );
  }

  Future<void> uploadMultiImages() async {
    var formData = FormData();
    for (var file in publicImagePathsthumbnail) {
      formData.files.addAll([
        MapEntry("img", await MultipartFile.fromFile(
          file,
          filename: file
              .split('/')
              .last,
        )),
      ]);
    }
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');

    Dio dio = new Dio();

    dio.post(Constants.SERVER_URL + 'v1/message/upload_multi_imgs', data: formData,
      options: Options(
        headers: {
          HttpHeaders.AUTHORIZATION: 'Bearer ' +  token
        },
      ),)
        .then((response) {
      var result = jsonDecode(response.toString());
      if (result['error'] == false) {
        print('data');
        print(response.toString());

        setState(() {
          uploadingImageUrls = result['data'];
        });
        final mainMap = <String, Object>{};
        final messageId = uuid.v1();
        var messageContent;
        if(chatcontroller.text.trim().length == 0) {
          messageContent = "";
        } else {
          messageContent = chatcontroller.text.trim();
        }
        mainMap['messageId'] = messageId;
        mainMap['chat_id'] = roomId;
        mainMap['sender_id'] = Constants.userresponse['user']['_id'];
        mainMap['receiver_id'] = _con.partnerInfo['_id'];
        mainMap['message'] = messageContent;
        mainMap['imgs'] = uploadingImageUrls;
        mainMap['message_type'] = 1;

        final jsonString = convert.jsonEncode(mainMap);
        socket.emit('new_message', jsonString);

        setState(() {
          isMessageSent = false;
          _con.listMessages.insert(
              0,
              (PrivateMessageModel(
                id: messageId,
                  message: messageContent,
                  imgs: uploadingImageUrls,
                  messageType: 1,
                  senderId: Constants.userresponse['user']['_id'],
                  receiverId: _con.partnerInfo['_id'],
                  isDeleted: 0,
                  createdAt: 0,
                  roomId: roomId,
              )));
          message = '';
          chatcontroller.text = '';
        });

        _scrollToLast();
        isMessageSent = false;
        privateImagePaths = [];
        privateChatImageRes = [];

      }
    })
        .catchError((error) => print(error));
  }
  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 58,

    );


    return result;
  }
  convertthubnail(List listofimages)
  async {
    for(var filee in listofimages)
    {


      String extension=filee.toString().split('.').last;
      String fileName = filee.split('/').last;


      String dir = pathh.dirname(filee); //get directory
      String targetfile=dir+"/"+pathh.basenameWithoutExtension(fileName)+"."+"min"+"."+extension;

      var file=await testCompressAndGetFile(File(filee) ,targetfile);
      publicImagePathsthumbnail.add(file.path);


    }

    for(var filname in privateImagePaths)
    {
      publicImagePathsthumbnail.add(filname);
    }
    for(var fill in publicImagePathsthumbnail)
    {
      log(fill.toString());
    }

    uploadMultiImages();

  }

}
