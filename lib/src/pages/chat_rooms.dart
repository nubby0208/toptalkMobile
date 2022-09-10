import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locals/src/controllers/private_chat_controller.dart';
import 'package:locals/src/controllers/public_chat_controller.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:locals/src/utils/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../../generated/l10n.dart';
import '../controllers/public_chat_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';

class ChatRoomsWidget extends StatefulWidget {
  @override
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  ChatRoomsWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ChatRoomsWidgetState createState() => _ChatRoomsWidgetState();
}

class _ChatRoomsWidgetState extends StateMVC<ChatRoomsWidget> {
  PrivateChatController _con;

  _ChatRoomsWidgetState() : super(PrivateChatController()) {
    _con = controller;
  }

  Color senderFontColor = Colors.black;
  Color receiverFontColor = Colors.white;
  String myId ;

  @override
  void initState() {
    super.initState();

    _con.initRooms();
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
          left: config.App(context).appWidth(7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Text("private_chat",
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)
          ).tr(),
        ],
      ),
    );
  }

  Widget mainContent() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: Colors.white),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Column(
            children: [
              // Container(
              //     width: config.App(context).appWidth(100),
              //     padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              //     decoration: BoxDecoration(
              //         color: Color(0xffD2FBFF), borderRadius: BorderRadius.circular(15)
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Container(
              //           width: config.App(context).appWidth(10),
              //           height: config.App(context).appWidth(10),
              //           padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              //           decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(8), color: Color(0xff50529A)
              //           ),
              //           child: Center(
              //             child: Image.asset('assets/img/app_icon.png', width: config.App(context).appWidth(10), fit: BoxFit.fitWidth,),
              //           ),
              //         ),
              //         SizedBox(width: config.App(context).appWidth(63),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     // Text("App Administrator", textAlign: TextAlign.center,
              //                     //     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black)),
              //                     // SizedBox(height: 5,),
              //                     Text("Talk to customer service",
              //                         style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black)),
              //
              //                   ],
              //                 ),
              //                 Container(
              //                   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              //                   decoration: BoxDecoration(
              //                       color: Color(0xffEAEAEA), borderRadius: BorderRadius.circular(5)
              //                   ),
              //                   child: Icon(Icons.arrow_forward_ios, size: 24, color: Color(0xff9496DE),),
              //                 )
              //               ],
              //             )
              //         ),
              //       ],
              //     )
              // ),
              Expanded(child:
              ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: _con.rooms.length,
                  itemBuilder: (BuildContext context, int i) {
                    var userInfo = _con.rooms[i]['friend'];
                    // for (var user in  _con.rooms[i]['users']) {
                    //   if(user['email'] != _con.email) {
                    //     userInfo = user;
                    //   }
                    // }
                    return  Stack(
                      children: [
                        Container(
                          width: config.App(context).appWidth(100),
                          height: config.App(context).appWidth(15),
                          margin: EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                              color: Color(0xffD7443E), borderRadius: BorderRadius.circular(15)
                          ),
                        ),
                        Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actionExtentRatio: 0.15,
                          child: _con.rooms[i]['isAdminChannel']
                              ? GestureDetector(
                            onTap: () async {
                              final sharedPreferences = await SharedPreferences.getInstance();
                              final meId = sharedPreferences.getString('_id');
                              // Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: _con.rooms[i]['_id'].toString()));
                              Navigator.of(context).pushNamed('/ChatScreen', arguments: RouteArgument(subData: _con.rooms[i]['_id'].toString(), heroTag: userInfo['_id'].toString(), id: meId.toString() ) );
                            },
                            child:  Container(
                                width: config.App(context).appWidth(100),
                                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                decoration: BoxDecoration(
                                    color: Color(0xffD2FBFF), borderRadius: BorderRadius.circular(15)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Stack(
                                    //   overflow:Overflow.visible,
                                    //   children: [
                                    //     Container(
                                    //       width: config.App(context).appWidth(12),
                                    //       height: config.App(context).appWidth(12),
                                    //       decoration: BoxDecoration(
                                    //           shape: BoxShape.circle, color: Color(0xffC4C4C4).withOpacity(0.55),
                                    //           image: DecorationImage(
                                    //               image: Image.network(Constants.SERVER_URL + "v1/user/img-src/" + userInfo['avatarUrl'].toString()).image,
                                    //               fit: BoxFit.fill
                                    //           )
                                    //       ),
                                    //     ),
                                    //     _con.rooms[i]['lastMessage']['unread_count'] > 0 && !json.decode(json.encode(_con.rooms[i]['lastMessage']['users_see_message'])).contains(_con.myID.toString())
                                    //
                                    //         ?Positioned(
                                    //         top:0,
                                    //         right:-3,
                                    //         child:
                                    //
                                    //
                                    //         Container(
                                    //           width: 15, height: 15,
                                    //           decoration:BoxDecoration(
                                    //               color:Colors.red,
                                    //               shape: BoxShape.circle
                                    //               ,border:Border.all(color:Colors.red,)
                                    //           ),
                                    //           padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                                    //           child:Text(_con.rooms[i]['lastMessage']['unread_count'].toString(), textAlign: TextAlign.center,
                                    //             style: TextStyle(color: Colors.white, fontSize: 10, ),
                                    //           ),
                                    //         ))
                                    //         :Container(),
                                    //     Padding(
                                    //         padding: EdgeInsets.only(left: config.App(context).appWidth(9), top: config.App(context).appWidth(9)),
                                    //         child: Container(
                                    //           width: 12, height: 12,
                                    //           padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                                    //           decoration: BoxDecoration(
                                    //               shape: BoxShape.circle, color: Colors.white
                                    //           ),
                                    //           child: Container(
                                    //             width: 11, height: 11,
                                    //             decoration: BoxDecoration(
                                    //                 shape: BoxShape.circle, color: userInfo['online'] ? Colors.green :  Color(0xeef3bf01)
                                    //             ),
                                    //           ),
                                    //         )
                                    //     ),
                                    //
                                    //   ],
                                    // ),
                                    Stack(
                                      overflow:Overflow.visible,
                                      children: [
                                        Container(
                                          width: config.App(context).appWidth(10),
                                          height: config.App(context).appWidth(10),
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8), color: Color(0xff4B70BA)
                                          ),
                                          child: Center(
                                            child: Image.asset('assets/img/appicon.png', width: config.App(context).appWidth(10), fit: BoxFit.fitWidth,),
                                          ),
                                        ),
                                        _con.rooms[i]['lastMessage']['unread_count'] > 0 && !json.decode(json.encode(_con.rooms[i]['lastMessage']['users_see_message'])).contains(_con.myID.toString())

                                            ?Positioned(
                                            top:-2,
                                            right:-3,
                                            child:


                                            Container(
                                              width: 15, height: 15,
                                              decoration:BoxDecoration(
                                                  color:Colors.red,
                                                  shape: BoxShape.circle
                                                  ,border:Border.all(color:Colors.red,)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                                              child:Text(_con.rooms[i]['lastMessage']['unread_count'].toString(), textAlign: TextAlign.center,
                                                style: TextStyle(color: Colors.white, fontSize: 10, ),
                                              ),
                                            ))
                                            :Container()

                                      ],
                                    ),
                                    SizedBox(width: config.App(context).appWidth(73),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Text("App Administrator", textAlign: TextAlign.center,
                                                //     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black)),
                                                // SizedBox(height: 5,),
                                                Text("customer".tr(),
                                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black)),

                                              ],
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                              decoration: BoxDecoration(
                                                  color: Color(0xffEAEAEA), borderRadius: BorderRadius.circular(5)
                                              ),
                                              child: Icon(Icons.arrow_forward_ios, size: 24, color: Color(0xff9496DE),),
                                            )
                                          ],
                                        )
                                    ),
                                  ],
                                )
                            ),
                          )
                              :GestureDetector(
                            onTap: () async {
                              final sharedPreferences = await SharedPreferences.getInstance();
                              final meId = sharedPreferences.getString('_id');
                              // Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: _con.rooms[i]['_id'].toString()));
                              Navigator.of(context).pushNamed('/ChatScreen', arguments: RouteArgument(subData: _con.rooms[i]['_id'].toString(), heroTag: userInfo['_id'].toString(), id: meId.toString(), param: {"distance": double.parse(_con.rooms[i]['friend']["distance"]).toStringAsFixed(0).toString()+ _con.rooms[i]['friend']["distance_unit"].toString().tr(), "credit": _con.rooms[i]['friend']["credit"] } ) );

                            },
                            child: Container(
                                width: config.App(context).appWidth(100),
                                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white, borderRadius: BorderRadius.circular(15)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Stack(
                                      overflow:Overflow.visible,
                                      children: [
                                        Container(
                                          width: config.App(context).appWidth(12),
                                          height: config.App(context).appWidth(12),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle, color: Color(0xffC4C4C4).withOpacity(0.55),
                                              image: DecorationImage(
                                                  image: Image.network(Constants.SERVER_URL + "v1/user/img-src/" + userInfo['avatarUrl'].toString()).image,
                                                  fit: BoxFit.fill
                                              )
                                          ),
                                        ),
                                        _con.rooms[i]['lastMessage']['unread_count'] > 0 && !json.decode(json.encode(_con.rooms[i]['lastMessage']['users_see_message'])).contains(_con.myID.toString())

                                        ?Positioned(
                                            top:0,
                                            right:-3,
                                            child:


                                        Container(
                                          width: 15, height: 15,
                                          decoration:BoxDecoration(
                                            color:Colors.red,
                                            shape: BoxShape.circle
                                              ,border:Border.all(color:Colors.red,)
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                                          child:Text(_con.rooms[i]['lastMessage']['unread_count'].toString(), textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white, fontSize: 10, ),
                                          ),
                                        ))
                                            :Container(),
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
                                                    shape: BoxShape.circle, color: userInfo['online'] ? Colors.green :  Color(0xeef3bf01)
                                                ),
                                              ),
                                            )
                                        ),

                                      ],
                                    ),
                                    SizedBox(width: config.App(context).appWidth(60),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                SizedBox(
                                                  width:100,
                                                  child : Text(userInfo['name'], textAlign: TextAlign.left, overflow: TextOverflow.ellipsis, maxLines: 2,
                                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: senderFontColor)),
                                                ),


                                                Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(width: 5,),
                                                        if(userInfo['gender'] == 0) ... [
                                                          Image.asset('assets/img/man.png', height: 16, fit: BoxFit.fitHeight,),
                                                        ] else if (userInfo['gender'] == 1) ...[
                                                          Image.asset('assets/img/woman.png', height: 16, fit: BoxFit.fitHeight,),
                                                        ] else ...[
                                                          Image.asset('assets/img/shop_icon.png', height: 16, fit: BoxFit.fitHeight,),
                                                        ],
                                                      ],
                                                    ),
                                                    Icon(Icons.circle, size: 5,),

                                                    Text(double.parse(_con.rooms[i]['friend']["credit"].toString()).toStringAsFixed(0).toString() + "%", textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),

                                                    Icon(CupertinoIcons.hand_thumbsup, size: 13, color: Color(0xff9496DE),)

                                                  ],
                                                ),

                                              ],
                                            ),
                                            SizedBox(height: 5,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Icon(Icons.circle, size: 2,),
                                                // Text(" 05-12", textAlign: TextAlign.center,
                                                //     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),
                                                // SizedBox(width: 5,),
                                                // Icon(Icons.watch_later_outlined, size: 12,),
                                                // Text(" 22:15", textAlign: TextAlign.center,
                                                //     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),
                                                Row(
                                                  children: [
                                                    Text(_con.rooms[i]['lastMessage']['timeDiff'], textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 13,
                                                            fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),SizedBox(width:1,),
                                                    Text(_con.rooms[i]['lastMessage']['timeUnit'].toString().replaceAll(" ","").tr(), textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 13,
                                                            fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),
                                                    SizedBox(width:1,),
                                                    Text("ago".tr(), textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 13,
                                                            fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(Icons.circle, size: 5,),
                                                    Text(double.parse(userInfo['distance'].toString()).toStringAsFixed(0).toString() + userInfo['distance_unit'].toString().tr(), textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),
                                                    SizedBox(width: 3,),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5,),
                                            SizedBox(
                                              width: config.App(context).appWidth(50),
                                              child:  Text(_con.rooms[i]['lastMessage']['message'], maxLines: 1,overflow: TextOverflow.ellipsis,
                                                  style: TextStyle( fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black)),
                                            )
                                          ],
                                        )
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                      decoration: BoxDecoration(
                                          color: Color(0xffEAEAEA), borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: Icon(Icons.arrow_forward_ios, size: 24, color: Color(0xff9496DE),),
                                    )
                                  ],
                                )
                            ),
                          ),
                          secondaryActions: <Widget>[
                            // Icon(CupertinoIcons.clear_thick, size: 24,)
                            InkWell(
                              onTap: () => {
                                _con.removeRoom(_con.rooms[i]['_id'].toString())
                              },
                              child: Icon(CupertinoIcons.clear_thick, size: 18, color: Colors.white,),
                            )
                          ],
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
