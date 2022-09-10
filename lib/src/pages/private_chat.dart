import 'dart:developer';
import 'package:easy_localization/src/public_ext.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locals/src/controllers/private_chat_controller.dart';
import 'package:locals/src/controllers/public_chat_controller.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:locals/src/pages/chat_rooms.dart';
import 'package:locals/src/utils/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../generated/l10n.dart';
import '../controllers/public_chat_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';

class PrivateChatWidget extends StatefulWidget {
  @override
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  PrivateChatWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _PrivateChatWidgetState createState() => _PrivateChatWidgetState();
}

class _PrivateChatWidgetState extends StateMVC<PrivateChatWidget> {
  PrivateChatController _con;

  _PrivateChatWidgetState() : super(PrivateChatController()) {
    _con = controller;
  }

  Color senderFontColor = Colors.black;
  Color receiverFontColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _con.init();

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
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
          backgroundColor: Colors.white,
          key: _con.scaffoldKey,
          // resizeToAvoidBottomPadding: false,
          body: Column(
            children: [
              headBox(),
              Expanded(child: _con.loading ? progress : mainContent()),
            ],
          )),
    );
  }

  Widget headBox() {
    return Padding(
      padding: EdgeInsets.only(
          top: config.App(context).appWidth(12),
          left: config.App(context).appWidth(7), right: config.App(context).appWidth(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("private_chat",
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)
          ).tr(),
          InkWell(
            onTap: () async {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ChatRoomsWidget()));
            },
            child: Image.asset('assets/img/tab3.png', height: 20, fit: BoxFit.fitHeight,),
          )
        ],
      ),
    );
  }

  Widget mainContent() {
    return Container(
        width: config.App(context).appWidth(100),
        padding: EdgeInsets.symmetric(
            horizontal: config.App(context).appWidth(5), vertical: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: Colors.white),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Column(
            children: [

              Expanded(child:
              ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: _con.responseList.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Stack(
                      children: [
                        Container(
                          width: config.App(context).appWidth(100),
                          height: config.App(context).appWidth(15),
                          decoration: BoxDecoration(
                              color: Color(0xffD7443E), borderRadius: BorderRadius.circular(15)
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: "1"));
                          },
                          child: Container(
                              width: config.App(context).appWidth(100),
                              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(15)
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: config.App(context).appWidth(12),
                                        height: config.App(context).appWidth(12),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle, color: Color(0xffC4C4C4).withOpacity(0.55),
                                            image: DecorationImage(
                                                image: Image.network(Constants.SERVER_URL + "v1/user/img-src/" + _con.responseList[i]["avatarUrl"].toString()).image,
                                                fit: BoxFit.fill
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
                                                  shape: BoxShape.circle, color: _con.responseList[i]["online"] == true? Colors.green: Color(0xeef3bf01)
                                              ),
                                            ),
                                          )
                                      )
                                    ],
                                  ),
                                  SizedBox(width: config.App(context).appWidth(50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(_con.responseList[i]['name'], textAlign: TextAlign.center,
                                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: senderFontColor)),
                                              SizedBox(width: 10,),
                                              Image.asset(_con.responseList[i]["gender"].toString() == '0' ? 'assets/img/man.png': (_con.responseList[i]["gender"].toString() == '1'? 'assets/img/woman.png': 'assets/img/shop_icon.png'), height: 16, fit: BoxFit.fitHeight,),
                                              SizedBox(width: 20,),
                                              Row(
                                                children: [
                                                  Icon(Icons.circle, size: 2,),
                                                  Text(" 0.1km", textAlign: TextAlign.center,
                                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),
                                                  Icon(Icons.circle, size: 2,),
                                                  Text(_con.responseList[i]["like"].toString(), textAlign: TextAlign.center,
                                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),
                                                ],
                                              ),
                                              SizedBox(width: 10,),
                                              Icon(CupertinoIcons.hand_thumbsup, size: 13, color: Color(0xff9496DE),)
                                            ],
                                          )
                                        ],
                                      )
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                      decoration: BoxDecoration(
                                          color: Color(0xffEAEAEA), borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: Icon(Icons.arrow_forward_ios, size: 24, color: Color(0xff9496DE),),
                                    ),
                                    onTap: () {
                                      _con.createRoom(i);
                                    },
                                  )
                                ],
                              )
                          ),
                        ),
                      ],
                    );
                  }
              )
              )
            ],
          ),
        ));
  }
}
