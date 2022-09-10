import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locals/src/controllers/public_chat_controller.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../generated/l10n.dart';
import '../controllers/public_chat_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import 'package:easy_localization/src/public_ext.dart';

class UploadScreenWidget extends StatefulWidget {
  @override
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  UploadScreenWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _UploadScreenWidgetState createState() => _UploadScreenWidgetState();
}

class _UploadScreenWidgetState extends StateMVC<UploadScreenWidget> {
  PublicChatController _con;

  _UploadScreenWidgetState() : super(PublicChatController()) {
    _con = controller;
  }

  Color senderFontColor = Colors.black;
  Color receiverFontColor = Colors.white;

  @override
  void initState() {
    super.initState();
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
              mainContent(),
              chatBox()
            ],
          )
      ),
    );
  }

  Widget headBox() {
    return Container(
      height: config.App(context).appWidth(20),
      padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: "1"));
                },
                child: Icon(Icons.arrow_back_ios_rounded, color: Colors.black,),
              ),
              SizedBox(width: 40,),
              Text("text_input",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)).tr(),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color(0xff9496DE)
            ),
            child: Text("send",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)).tr(),
          )

        ],
      ),
    );
  }

  Widget mainContent() {
    return Container(
        width: config.App(context).appWidth(100),
        margin: EdgeInsets.only(top: config.App(context).appWidth(25)),
        padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(5), vertical: 25),

        child: MediaQuery.removePadding(context: context, removeTop: true,
            child: ListView(
              children: [
                TextField(
                  maxLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'text'.tr(),
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 0), borderRadius: BorderRadius.circular(1)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 0), borderRadius: BorderRadius.circular(1)
                    ),
                  ),
                  onChanged: (text) => setState(() {}),

                ),
                SizedBox(height: 5,),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("max_photo",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xffACACAC))).tr(),
                ),
                SizedBox(height: 20,),
                Container(
                  width: config.App(context).appWidth(100),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(width: 3, color: Color(0xff9496DE))
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: config.App(context).appWidth(11),
                        height: config.App(context).appWidth(11),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xff9496DE)
                        ),
                        child: Center(
                          child: Icon(Icons.add_rounded, size: 32, color: Colors.white, ),
                        ),
                      ),
                      Text("photos",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff7452A8))).tr(),
                      SizedBox(width: config.App(context).appWidth(11),)
                    ],
                  ),
                )
              ],
            ))
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
                  child: Image.asset('assets/img/camera_icon.png', height: config.App(context).appWidth(4), color: Colors.black, fit: BoxFit.fitHeight,),
                )
            ),
            SizedBox(width: 15,),
            GestureDetector(
                onTap: (){
                  Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: "2"));
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Image.asset('assets/img/image_icon.png', height: config.App(context).appWidth(4), color: Colors.black, fit: BoxFit.fitHeight,),
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
                    child: Icon(Icons.emoji_emotions,size: 24, color: Colors.black,),
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
                  child: Image.asset('assets/img/send_icon.png', height: config.App(context).appWidth(4), color: Colors.black, fit: BoxFit.fitHeight,),
                )
            )
          ],

        ),
      ),
    );
  }
}
