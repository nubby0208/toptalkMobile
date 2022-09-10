import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:locals/src/controllers/public_chat_controller.dart';
import 'package:locals/src/elements/DetailScreen.dart';
import 'package:locals/src/models/message_model.dart';
import 'package:locals/src/utils/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../../generated/l10n.dart';
import '../controllers/public_chat_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';


class TopWidget extends StatefulWidget {
  @override
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  TopWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _TopWidgetState createState() => _TopWidgetState();
}

class _TopWidgetState extends StateMVC<TopWidget> {
  PublicChatController _con;
  List<MessageModel> _listMessages = [];
  final _refreshController = RefreshController(initialRefresh:false);


  _TopWidgetState() : super(PublicChatController()) {
    _con = controller;
  }

  Color senderFontColor = Colors.black;
  Color receiverFontColor = Colors.white;
  List<bool> isSelected=[];
Timer timer;
  @override
  void initState() {
    super.initState();
    isSelected = [true, false];

    getTopMessages();
     timer = Timer.periodic(Duration(minutes: _con.refresh_location_time_interval??3), (Timer t) => _onLoadMore());

  }

showbottom(int i,String imgurl,String sendername,String email,
    String credit,String distance,String unit,String gender){
  return showModalBottomSheet(
      context: context,
      backgroundColor:Color(0xff9496DE),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height:10,),
              Center(
                child: Container(
                  color:Colors.white,
                  width:40,
                  height:4,

                ),
              ),
              SizedBox(height:50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Container(
                        width: config.App(context).appWidth(12),
                        height: config.App(context).appWidth(12),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Color(0xffC4C4C4).withOpacity(0.55),
                              image: DecorationImage(
                                  image: Image.network(Constants.SERVER_URL + "v1/user/img-src/" + imgurl).image,
                                  fit: BoxFit.fill
                              )
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("$sendername",style:TextStyle(color:Colors.black,fontWeight:FontWeight.bold),),SizedBox(width:10,),

                            ],
                          ),
                          SizedBox(height:10),
                          Container(
                              width:90,

                              child: Text(email.toUpperCase(),style:TextStyle(color:Colors.white,fontSize: 12,),maxLines:2,))
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(gender.toString() == '0' ? 'assets/img/man.png': (gender.toString() == '1'? 'assets/img/woman.png': 'assets/img/shop_icon.png'), height: 16, fit: BoxFit.fitHeight,),
                          SizedBox(width:15,),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal:20, vertical: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10), color:Color(0xff4089D3))
                            ,
                            child: Row(
                              children: [

                                Icon(Icons.location_pin, size: 10, color: Colors.white,),
                                SizedBox(width: 5,),
                                Text(double.parse(distance).toStringAsFixed(0).toString() +unit.tr()  ,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),                      SizedBox(height:10,),
                      Row(
                        children: [
                          Text(credit + "%", textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                          SizedBox(width: 6,),
                          Icon(CupertinoIcons.hand_thumbsup, size: 13, color: Color(0xffD7443E),)
                        ],
                      ),

                    ],
                  ),
                ],
              ),
              // Image.asset(_listMessages[i].gender.toString() == '0' ? 'assets/img/man.png': (_listMessages[i].gender.toString() == '1'? 'assets/img/woman.png': 'assets/img/shop_icon.png'), height: 16, fit: BoxFit.fitHeight,),
              SizedBox(height:30,),
              Container(
                width:MediaQuery.of(context).size.width,
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
                              size: 23,
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
                              size: 23,
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
//                       Column(
//                         children: [
//                           Container(
//                             height:40,
//                             padding:EdgeInsets.symmetric(horizontal:20,vertical:10),
//                             width:140,
//
//                             decoration:BoxDecoration(
//                                 borderRadius: BorderRadius.only(
//
//                                     topLeft: Radius.circular(20.0)),
//                                 color:Colors.white38
//                             ),
//                             child:Icon(CupertinoIcons.hand_thumbsup_fill, size: 23, color: Color(0xffD7443E),)
//                             ,
//                           ),
//                           SizedBox(height:5,),
//                           Container(
//                             height:40,
//
//                             padding:EdgeInsets.symmetric(horizontal:20,vertical:10),
//                             width:140,
//
//                             decoration:BoxDecoration(
//                                 borderRadius: BorderRadius.only(
//
//                                     bottomLeft: Radius.circular(20.0)),
//                                 color:Colors.white38
//                             ),
//                             child:Icon(CupertinoIcons.hand_thumbsdown, size: 23, color: Color(0xffD7443E),)
//                             ,
//                           )
//                         ],
//                       ),
// SizedBox(width:5,),
//                       GestureDetector(
//
//                         onTap: (){
//                           _con.createRoom(
//                               _listMessages[i].senderId.toString(),_listMessages[i].credit,_listMessages[i].distance,_listMessages[i].distanceUnit);
//                           //
//                           // _con.createRoom(
//                           //     _listMessages[i].senderId.toString());
//                         },
//                         child: Container(
//                           padding:EdgeInsets.symmetric(horizontal:20,vertical:10),
//                           height:85,
//                           width:140,
//
//                           decoration:BoxDecoration(
//                               borderRadius: BorderRadius.only(
//                                   topRight: Radius.circular(20.0),
//                                   bottomRight: Radius.circular(20.0),
//                               ),
//                               color:Colors.white38
//                           ),
//                           child:Center(child: Text("private_chat",style:TextStyle(color:Colors.white),).tr())
//                           ,
//                         ),
//                       ),
                  ],
                ),
              ),
              SizedBox(height:30,),
            ],
          ),
        );
      });
}

  void getTopMessages() async {
    _listMessages.clear();
    var jsonResponse = await _con.getTopChats();
    print(jsonResponse);
    if (jsonResponse['error'] == false) {
      final data = jsonResponse['data'] as List;
      List<MessageModel>templist=[];

      _listMessages.addAll(data.map((e) => MessageModel.fromMap(e)).toList());
      setState(() {

      });
    }
  }

  void _onLoadMore() {
    startLoadMore();
  }
  void startLoadMore() async {
    setState(() {
      _listMessages.clear();
    });
    var jsonResponse = await _con.getAllMessages();
    if (jsonResponse['error'] == false) {
      final data = jsonResponse['data'] as List;
      List<MessageModel>templist=[];

      _listMessages.addAll(data.map((e) => MessageModel.fromMap(e)).toList());

    }

    if(_listMessages.length > 0){
      setState(() {
        _refreshController.loadComplete();
      });

    } else {
      _refreshController.loadNoData();
    }
  }

  Future<void> sortwrttime()
  async {
    _listMessages.clear();
    var jsonResponse = await _con.getTopChats();
    print(jsonResponse);
    if (jsonResponse['error'] == false) {
      final data = jsonResponse['data'] as List;
      List<MessageModel>templist=[];
      templist.addAll(data
          .map((e) => MessageModel.fromMap(e))
          .toList()..sort((a, b)=>a.createdAt.compareTo(b.createdAt)));

      setState(() {

          //softing on numerical order (Ascending order by Roll No integer)
      _listMessages=templist.reversed.toList();
      });


  }


  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
          backgroundColor: Colors.white,
        key: _con.scaffoldKey,
        // resizeToAvoidBottomPadding: false,
        body:  Stack(
          children: [
            headBox(),
            mainContent()
          ],
        )
      ),
    );
  }

  Widget headBox() {
    return Padding(
      padding: EdgeInsets.only(top: config.App(context).appWidth(12), left: config.App(context).appWidth(7),right: config.App(context).appWidth(7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text("top", textAlign: TextAlign.center, maxLines: 1,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)).tr(),

            Container(
              height:30,
              child: ToggleButtons(
                borderColor: Color(0xff7452A8),
                fillColor:Color(0xff7452A8),
                borderWidth:1,
                selectedBorderColor:Color(0xff7452A8),
                selectedColor: Colors.white,
                borderRadius: BorderRadius.circular(5),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:12.0),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.arrowUp,size:10,),
                        SizedBox(width:2,),
                        Text(
                          'distance',
                          style: TextStyle(fontSize: 12),
                        ).tr(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:15.0),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.arrowUp,size:10,),
                        SizedBox(width:2,),
                        Text(
                          'time',
                          style: TextStyle(fontSize: 12),
                        ).tr(),                      ],
                    ),
                  ),
                ],
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < isSelected.length; i++) {
                      isSelected[i] = i == index;
                    }
                    if(index==1)
                      {
                        sortwrttime();
                      }
                    else{

                      getTopMessages();
                    }
                  });
                },
                isSelected: isSelected,
              ),
            ),
        ],
      ),
    );
  }

  Widget mainContent() {
    return Container(
        width: config.App(context).appWidth(100),
        margin: EdgeInsets.only(top: config.App(context).appWidth(22),bottom: config.App(context).appWidth(12)),
        padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(5), vertical: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: Colors.white
        ),
        child:  Column(
          children: [
            _listMessages.length > 0 ?
            Expanded(child:
            Container(
              child: SmartRefresher(
                controller: _refreshController,
                header: WaterDropHeader(),
                onLoading: _onLoadMore,
                enablePullUp: false,
                enablePullDown:false,
                child: ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  itemBuilder: (context, i) {

                    return Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 0),

                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //headingtop
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (_con.myId !=
                                            _listMessages[i].senderId.toString()) {
                                          showbottom(i,_listMessages[i].avatarUrl.toString(),_listMessages[i].senderName.toString(),_listMessages[i].email.toString(),_listMessages[i].credit.toString(),_listMessages[i].distance.toString(),_listMessages[i].distanceUnit.toString(),_listMessages[i].gender);

                                        }
                                      },
                                      child: Container(
                                        width: config.App(context).appWidth(12),
                                        height: config.App(context).appWidth(12),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xffC4C4C4)
                                                  .withOpacity(0.55),
                                              image: DecorationImage(
                                                  image: Image.network(
                                                      Constants.SERVER_URL +
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
                                        crossAxisAlignment: CrossAxisAlignment.start,

                                        children: [
                                          _listMessages[i].senderId.toString() == _con.myId.toString()

                                              ? SizedBox(height:18,)
                                              :SizedBox(height:0,),
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
                                          SizedBox(height:5,),
                                          SizedBox(height: 5,),

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
                                        _listMessages[i].gender.toString() == '0'
                                            ? 'assets/img/man.png'
                                            : (_listMessages[i].gender.toString() ==
                                            '1'
                                            ? 'assets/img/woman.png'
                                            : 'assets/img/shop_icon.png'),
                                        height: 16,
                                        fit: BoxFit.fitHeight,
                                      ), SizedBox(width: 4,),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10), color: Color(0xff50529A)
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_pin, size: 10, color: Colors.white,),
                                            SizedBox(width: 5,),
                                            Text(_listMessages[i].distance == null ? "0 " : "${double.parse(_listMessages[i].distance ).toStringAsFixed(0).toString() } ${_listMessages[i].distanceUnit.tr()}",
                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: Colors.white)),

                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10,),
                                      Text(_listMessages[i].timeDiff.toString(),
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w400, color: Colors.black)),
                                      SizedBox(
                                        width: 1,
                                      ),
                                      Text("${_listMessages[i].timeUnit.replaceAll(" ","")}".tr(),
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
                                ],),



                              //messagebody
                              GestureDetector(
                                onLongPress:(){
                                  if( _listMessages[i].senderId.toString() == _con.myId.toString())
                                  {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("like").tr(),
                                            actions: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  _con.cancelTopMessage(_listMessages[i].id);


                                                  Navigator.pop(context);

                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal:15, vertical:13),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xff7452A8),
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: Text("cancel", style: TextStyle(color: Colors.white, fontSize: 12),).tr(),
                                                ),
                                              ),
                                              GestureDetector(

                                                onTap: () {
                                                  Clipboard.setData(new ClipboardData(text:_listMessages[i].message)).then((_){
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(SnackBar(content: Text('copied').tr()));
                                                  });
                                                  // _con.topItUp(_listMessages[i].messageId);
                                                  Navigator.pop(context);

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
                                                  _con.deletemessage(_listMessages[i].messageId);

                                                  setState(() {
                                                    _listMessages.removeAt(i);
                                                  }) ;
                                                  Navigator.pop(context);

                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal:15, vertical:13),
                                                  decoration: BoxDecoration(
                                                      color:  Color(0xff7452A8),
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: Text("delete", style: TextStyle(color: Colors.white, fontSize: 12),).tr(),
                                                ),
                                              ),

                                            ],
                                          );
                                        });
                                  }
                                  else
                                  {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("like").tr(),
                                            actions: <Widget>[

                                              GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(new ClipboardData(text:_listMessages[i].message)).then((_){
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

                                            ],
                                          );
                                        });
                                  }

                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 46),
                                  padding:EdgeInsets.all(10),
                                  width:MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5),bottomLeft:Radius.circular(5),bottomRight: Radius.circular(5)),
                                      color: Color(0xfff1f0ef)
                                  ),
                                  child:Column(
                                    crossAxisAlignment:CrossAxisAlignment.start,
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
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
                                        linkStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.deepPurpleAccent),
                                      ),
                                      SizedBox(height: 00,),
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
                                      // json.decode(json.encode(_listMessages[i].imgs)).length != 0
                                      //     ? SizedBox( height: (json.decode(json.encode(_listMessages[i].imgs)).length ~/ 3) == 0 || json.decode(json.encode(_listMessages[i].imgs)).length == 3 ? config.App(context).appWidth(25)
                                      //     : (json.decode(json.encode(_listMessages[i].imgs)).length ~/ 3) == 1 || json.decode(json.encode(_listMessages[i].imgs)).length == 6 ? config.App(context).appWidth(45)
                                      //     : (json.decode(json.encode(_listMessages[i].imgs)).length ~/ 3) == 2 || json.decode(json.encode(_listMessages[i].imgs)).length == 9 ? config.App(context).appWidth(65) : 0,
                                      //   child:ListView.builder(
                                      //     scrollDirection: Axis.vertical,
                                      //     shrinkWrap: true,
                                      //     physics: NeverScrollableScrollPhysics(),
                                      //
                                      //     itemCount: (json.decode(json.encode(_listMessages[i].imgs)).length ~/ 3) + 1,
                                      //     itemBuilder: (context, index) {
                                      //
                                      //       var totalCount = json.decode(json.encode(_listMessages[i].imgs)).length;
                                      //       var itemCount = 0;
                                      //       if(totalCount >= (index+ 1) * 3) {
                                      //         itemCount = 0;
                                      //       }  else {
                                      //         itemCount = totalCount  % 3;
                                      //       }
                                      //       if(index == 3) {
                                      //         itemCount = 3;
                                      //       }
                                      //
                                      //       if(totalCount == 3 && index == 1) {
                                      //         itemCount = 3;
                                      //       }
                                      //       if(totalCount == 6 && index == 2) {
                                      //         itemCount = 3;
                                      //       }
                                      //       return Padding(
                                      //           padding  : EdgeInsets.only(bottom: 5),
                                      //           child: Row(
                                      //             children: [
                                      //               if(itemCount == 0) ...
                                      //               [
                                      //                 GestureDetector(
                                      //                   onTap: () {
                                      //                     Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      //                       return DetailScreen(url: Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index].toString());
                                      //                     }));
                                      //                   },
                                      //                   child: Container(
                                      //                     height: config.App(context).appWidth(18),
                                      //                     width: config.App(context).appWidth(13),
                                      //                     margin: EdgeInsets.only(right: 10),
                                      //                     decoration: BoxDecoration(
                                      //                         borderRadius: BorderRadius.circular(5),
                                      //                         image: DecorationImage(
                                      //                           image: Image.network(Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index].toString()).image,
                                      //                           fit: BoxFit.fill,
                                      //                         )
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //                 GestureDetector(
                                      //                   onTap: () {
                                      //                     Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      //                       return DetailScreen(url: Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index + 1].toString());
                                      //                     }));
                                      //                   },
                                      //                   child: Container(
                                      //                     height: config.App(context).appWidth(18),
                                      //                     width: config.App(context).appWidth(13),
                                      //                     margin: EdgeInsets.only(right: 10),
                                      //                     decoration: BoxDecoration(
                                      //                         borderRadius: BorderRadius.circular(5),
                                      //                         image: DecorationImage(
                                      //                           image: Image.network(Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3* index + 1].toString()).image,
                                      //                           fit: BoxFit.fill,
                                      //                         )
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //                 GestureDetector(
                                      //                   onTap: () {
                                      //                     Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      //                       return DetailScreen(url: Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index + 2].toString());
                                      //                     }));
                                      //                   },
                                      //                   child: Container(
                                      //                     height: config.App(context).appWidth(18),
                                      //                     width: config.App(context).appWidth(13),
                                      //                     margin: EdgeInsets.only(right: 10),
                                      //                     decoration: BoxDecoration(
                                      //                         borderRadius: BorderRadius.circular(5),
                                      //                         image: DecorationImage(
                                      //                           image: Image.network(Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3* index + 2].toString()).image,
                                      //                           fit: BoxFit.fill,
                                      //                         )
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //
                                      //               ] else if(itemCount == 1) ...
                                      //               [
                                      //                 GestureDetector(
                                      //                   onTap: () {
                                      //                     Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      //                       return DetailScreen(url: Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index].toString());
                                      //                     }));
                                      //                   },
                                      //                   child: Container(
                                      //                     height: config.App(context).appWidth(18),
                                      //                     width: config.App(context).appWidth(13),
                                      //                     margin: EdgeInsets.only(right: 10),
                                      //                     decoration: BoxDecoration(
                                      //                         borderRadius: BorderRadius.circular(5),
                                      //                         image: DecorationImage(
                                      //                           image: Image.network(Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index].toString()).image,
                                      //                           fit: BoxFit.fill,
                                      //                         )
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //
                                      //               ] else if(itemCount == 2) ...
                                      //               [
                                      //                 GestureDetector(
                                      //                   onTap: () {
                                      //                     Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      //                       return DetailScreen(url: Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index].toString());
                                      //                     }));
                                      //                   },
                                      //                   child: Container(
                                      //                     height: config.App(context).appWidth(18),
                                      //                     width: config.App(context).appWidth(13),
                                      //                     margin: EdgeInsets.only(right: 10),
                                      //                     decoration: BoxDecoration(
                                      //                         borderRadius: BorderRadius.circular(5),
                                      //                         image: DecorationImage(
                                      //                           image: Image.network(Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index].toString()).image,
                                      //                           fit: BoxFit.fill,
                                      //                         )
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //                 GestureDetector(
                                      //                   onTap: () {
                                      //                     Navigator.push(context, MaterialPageRoute(builder: (_) {
                                      //                       return DetailScreen(url: Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index + 1].toString());
                                      //                     }));
                                      //                   },
                                      //                   child: Container(
                                      //                     height: config.App(context).appWidth(18),
                                      //                     width: config.App(context).appWidth(13),
                                      //                     margin: EdgeInsets.only(right: 10),
                                      //                     decoration: BoxDecoration(
                                      //                         borderRadius: BorderRadius.circular(5),
                                      //                         image: DecorationImage(
                                      //                           image: Image.network(Constants.SERVER_URL+ "v1/roomMessages/img-src/" + json.decode(json.encode(_listMessages[i].imgs))[3 * index + 1].toString()).image,
                                      //                           fit: BoxFit.fill,
                                      //                         )
                                      //                     ),
                                      //                   ),
                                      //                 ),
                                      //               ]
                                      //             ],
                                      //           )
                                      //       );
                                      //     },
                                      //   ),
                                      // )
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
            )):
                Container()
          ],
        )
    );
  }

  Widget chatBox() {
    return  Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: config.App(context).appWidth(15)),
        padding: EdgeInsets.only(left: 20,right: 20,bottom: 10,top: 10),
        width: double.infinity,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
                onTap: (){
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Image.asset('assets/img/camera_icon.png', height: config.App(context).appWidth(4), fit: BoxFit.fitHeight,),
                )
            ),
            SizedBox(width: 15,),
            GestureDetector(
                onTap: (){
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
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Icon(Icons.emoji_emotions,size: 24, color: Color(0xff9496DE)),
                  ),
                  suffixIconConstraints: BoxConstraints(maxHeight: 50),
                  hintText: "Aa".tr(),
                  hintStyle: TextStyle(color: Colors.black54, fontSize: 16),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0), borderRadius: BorderRadius.circular(20)
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0), borderRadius: BorderRadius.circular(20)
                  ),
                ),
              ),

            ),
            SizedBox(width: 20,),
            GestureDetector(
                onTap: () {

                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Image.asset('assets/img/send_icon.png', height: config.App(context).appWidth(4), fit: BoxFit.fitHeight,),
                )
            )
          ],

        ),
      ),
    );
  }
}
