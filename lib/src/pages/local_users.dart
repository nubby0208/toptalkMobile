import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locals/src/controllers/private_chat_controller.dart';
import 'package:locals/src/controllers/public_chat_controller.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:locals/src/pages/chat_rooms.dart';
import 'package:locals/src/utils/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:easy_localization/src/public_ext.dart';
import '../../generated/l10n.dart';
import '../controllers/public_chat_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';

class LocalUsersChatWidget extends StatefulWidget {
  @override
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  LocalUsersChatWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _LocalUsersWidgetState createState() => _LocalUsersWidgetState();
}

class _LocalUsersWidgetState extends StateMVC<LocalUsersChatWidget> {
  PrivateChatController _con;

  _LocalUsersWidgetState() : super(PrivateChatController()) {
    _con = controller;
  }

  Color senderFontColor = Colors.black;
  Color receiverFontColor = Colors.white;
  RegExp regex = RegExp(r"([.]*0)(?!.*\d)");

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
    return Scaffold(
        backgroundColor: Colors.white,
        key: _con.scaffoldKey,
        // resizeToAvoidBottomPadding: false,
        body: Column(
          children: [
            headBox(),
            Expanded(child: _con.loading ? progress : mainContent()),
          ],
        ));
  }

  Widget headBox() {
    return Padding(
      padding: EdgeInsets.only(
          top: config.App(context).appWidth(12),
          left: config.App(context).appWidth(7), right: config.App(context).appWidth(10)),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back_rounded, size: 24,),
          ),
          SizedBox(width: 30,),
          Text("user_list".tr() + " (" + _con.responseList.length.toString() +")",
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
              //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              //           decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(8), color: Color(0xff50529A)
              //           ),
              //           child: Center(
              //             child: Image.asset('assets/img/local_mark.png'),
              //           ),
              //         ),
              //         SizedBox(width: config.App(context).appWidth(63),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Column(
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     Text("App Administrator", textAlign: TextAlign.center,
              //                         style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black)),
              //                     SizedBox(height: 5,),
              //                     Text("Tell me something here....",
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
                        Container(
                            width: config.App(context).appWidth(100),
                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(15)
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Stack(
                                      children: [
                                        GestureDetector(
                                          onTap:(){
                                         showbottom(i, context);
                                          },
                                          child: Container(
                                            width: config.App(context).appWidth(10),
                                            height: config.App(context).appWidth(12),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle, color: Color(0xffC4C4C4).withOpacity(0.55),
                                                image: DecorationImage(
                                                    image: Image.network(Constants.SERVER_URL + "v1/user/img-src/" + _con.responseList[i]["avatarUrl"].toString()).image,
                                                    fit: BoxFit.fill
                                                )
                                            ),
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
                                    SizedBox(width:10,),
                                    SizedBox(
                                      width: config.App(context).appWidth(25),
                                      child:  Text("${_con.responseList[i]['name']}", maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: senderFontColor)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20.0),
                                      child: SizedBox(width: config.App(context).appWidth(20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [

                                                  Row(
                                                    children: [
                                                      Image.asset(_con.responseList[i]["gender"].toString() == '0' ? 'assets/img/man.png': (_con.responseList[i]["gender"].toString() == '1'? 'assets/img/woman.png': 'assets/img/shop_icon.png'), height: 16, fit: BoxFit.fitHeight,),
SizedBox(width:15,),
                                                      Icon(Icons.circle, size: 4,),
                                                      SizedBox(width: 5),
                                                      Text(double.parse(_con.responseList[i]['distance'].toString()).toStringAsFixed(0).toString() + _con.responseList[i]['distance_unit'].toString().tr(), textAlign: TextAlign.center,
                                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),


                                                    ],
                                                  ),


                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(double.parse(_con.responseList[i]["credit"].toString()).toStringAsFixed(0).toString() + "%", textAlign: TextAlign.center,
                                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xffAEAEAE))),
                                                  SizedBox(width: 5,),
                                                  Icon(CupertinoIcons.hand_thumbsup, size: 13, color: Color(0xff9496DE),)
                                                ],
                                              )
                                            ],
                                          )
                                      ),
                                    ), SizedBox(width:5,),
                                    GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                        decoration: BoxDecoration(
                                            color: Color(0xffEAEAEA), borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Icon(Icons.arrow_forward_ios, size: 24, color: Color(0xff9496DE),),
                                      ),
                                      onTap: () {
                                        // openChattingModal(context, i);
                                        showbottom(i, context);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            )
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
                ),
                Row(
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
                                        _con.responseList[i]["avatarUrl"].toString()).image,
                                    fit: BoxFit.fill)),
                          ),
                        ),
                        SizedBox(width:10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _con.responseList[i]['name'],
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
                                _con.responseList[i]['email'].toString().toUpperCase(),
                                style: TextStyle(color: Colors.white,fontSize: 12),overflow:TextOverflow.ellipsis,maxLines:2,
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
                              _con.responseList[i]['gender'].toString() == '0'
                                  ? 'assets/img/man.png'
                                  : ( _con.responseList[i]['gender'].toString() == '1'
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
                                  Text(double.parse(_con.responseList[i]['distance'].toString()).toStringAsFixed(0).toString()  +
                                      _con.responseList[i]['distance_unit'].toString().tr(),
                                      style:TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white))
                                  // Text(
                                  //     double.parse(_con.responseList[i]['distance'])
                                  //         .toStringAsFixed(0) +
                                  //         _con.responseList[i]['distanceUnit'],
                                  //     style: TextStyle(
                                  //         fontSize: 12,
                                  //         fontWeight: FontWeight.w400,
                                  //         color: Colors.white)),
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
                            Text(_con.responseList[i]['credit'] + "%",
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

                              _con.setLike(_con.responseList[i]['_id'].toString());
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
                              _con.setDislike(_con.responseList[i]['_id'].toString());
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
                          _con.createRoom2(i,_con.responseList[i]['credit'],_con.responseList[i]['distance'],'km');

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
  // void openChattingModal(context, index) async {
  //   showCupertinoModalPopup(
  //     context: context,
  //     builder : (context) {
  //       return StatefulBuilder(
  //         builder:  (BuildContext context, StateSetter setStater) {
  //           return Card(
  //             elevation: 4,
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
  //             child:  Container(
  //               width: config.App(context).appWidth(100),
  //               height: config.App(context).appWidth(70),
  //               padding: EdgeInsets.only(top: 15),
  //               decoration: BoxDecoration(
  //                   color: Color(0xff9496DE),
  //                   borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight:Radius.circular(25))
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     height:4.0,
  //                     width: 35,
  //                     decoration: BoxDecoration(
  //                         color:Colors.white,
  //                         borderRadius: BorderRadius.circular(20)
  //                     ),
  //                   ),
  //                   SizedBox(height: 50,),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Container(
  //                         width: config.App(context).appWidth(12),
  //                         height: config.App(context).appWidth(12),
  //                         decoration: BoxDecoration(
  //                             shape: BoxShape.circle, color: Color(0xffC4C4C4).withOpacity(0.55),
  //                             image: DecorationImage(
  //                                 image: Image.network(Constants.SERVER_URL + "v1/user/img-src/" + _con.responseList[index]["avatarUrl"].toString()).image,
  //                                 fit: BoxFit.fill
  //                             )
  //                         ),
  //                       ),
  //                       SizedBox(width: 40,),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Row(
  //                             children: [
  //                               SizedBox(
  //                                 width: config.App(context).appWidth(20),
  //                                 child:  Text(_con.responseList[index]['name'], maxLines: 1, overflow: TextOverflow.ellipsis,
  //                                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
  //                               ),
  //                               SizedBox(width: 10,),
  //                               Image.asset(_con.responseList[index]["gender"].toString() == '0' ? 'assets/img/man.png': (_con.responseList[index]["gender"].toString() == '1'? 'assets/img/woman.png': 'assets/img/shop_icon.png'), height: 16, fit: BoxFit.fitHeight,),
  //                             ],
  //                           ),
  //                           SizedBox(height: 10,),
  //                           Row(
  //                             children: [
  //                               Text(_con.responseList[index]['email'],
  //                                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(width: 40,),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Container(
  //                             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
  //                             decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.circular(20),
  //                                 color: Color(0xff4089D3)
  //                             ),
  //                             child: Row(
  //                               children: [
  //                                 Icon(Icons.location_on_rounded, size: 12, color: Colors.white,),
  //                                 SizedBox(width: 5,),
  //                                 Text(double.parse(_con.responseList[index]['distance'].toString()).toStringAsFixed(0).toString()  + "km",
  //                                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white))
  //                               ],
  //                             ),
  //                           ),
  //                           SizedBox(height: 10,),
  //                           Row(
  //                             children: [
  //                               Text(double.parse(_con.responseList[index]["credit"].toString()).toStringAsFixed(0).toString() + "%",
  //                                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
  //                               SizedBox(width: 5,),
  //                               Icon(CupertinoIcons.hand_thumbsup, size: 13, color: Colors.red,)
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 50,),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           GestureDetector(
  //                             onTap: () {
  //                               _con.setLike(_con.responseList[index]['_id'].toString());
  //                             },
  //                             child: Container(
  //                               width: config.App(context).appWidth(30),
  //                               height: config.App(context).appWidth(7),
  //                               decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
  //                                   color: Color(0xffB3B5E7)
  //                               ),
  //                               padding: EdgeInsets.symmetric(vertical: 5),
  //                               child: Icon(CupertinoIcons.hand_thumbsup_fill, size: 22, color: Colors.red,),
  //                             ),
  //                           ),
  //                           SizedBox(height: config.App(context).appWidth(1),),
  //                           GestureDetector(
  //                             onTap: () {
  //                               _con.setDislike(_con.responseList[index]['_id'].toString());
  //                             },
  //                             child: Container(
  //                               width: config.App(context).appWidth(30),
  //                               height: config.App(context).appWidth(7),
  //                               decoration: BoxDecoration(
  //                                   borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
  //                                   color: Color(0xffB3B5E7)
  //                               ),
  //                               padding: EdgeInsets.symmetric(vertical: 5),
  //                               child: Icon(CupertinoIcons.hand_thumbsdown, size: 22, color: Colors.red,),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(width: 5,),
  //                       GestureDetector(
  //                         onTap: () {
  //                           _con.createRoom(index);
  //                         },
  //                         child: Container(
  //                             width: config.App(context).appWidth(30),
  //                             height: config.App(context).appWidth(15),
  //                             decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
  //                                 color: Color(0xffB3B5E7)
  //                             ),
  //                             child: Center(
  //                               child: Text("private_chat",textAlign: TextAlign.center,
  //                                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)).tr(),
  //                             )
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(width: 10,),
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
