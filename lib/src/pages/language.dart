import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locals/src/controllers/public_chat_controller.dart';
import 'package:locals/src/controllers/user_controller.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:easy_localization/src/public_ext.dart';
import '../../generated/l10n.dart';
import '../controllers/public_chat_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';


class LanguageWidget extends StatefulWidget {
  @override
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  LanguageWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _LanguageWidgetState createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends StateMVC<LanguageWidget> {
  UserController _con;

  _LanguageWidgetState() : super(UserController()) {
    _con = controller;
  }

  Color senderFontColor = Colors.black;
  Color receiverFontColor = Colors.white;
  bool isSelectedEnglish = true;

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
                  Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 3, heroTag: "0"));
                },
                child: Icon(Icons.arrow_back_outlined, color: Colors.black,),
              ),
              SizedBox(width: 40,),
              Text("language",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)).tr(),
            ],
          ),
          GestureDetector(
            onTap: () {

            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: Color(0xff9496DE), width: 2)
              ),
              child: Text("save",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xff9496DE))).tr(),
            ),
          )

        ],
      ),
    );
  }

  Widget mainContent() {
    return Container(
        width: config.App(context).appWidth(100),
        margin: EdgeInsets.only(top: config.App(context).appWidth(25)),
        padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(8), vertical: 25),

        child: MediaQuery.removePadding(context: context, removeTop: true,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/img/english_lang.png', width: 45, fit: BoxFit.fitWidth,),
                        SizedBox(width: 20,),
                        Text("english",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
                      ],
                    ),
                    Icon(Icons.check_circle, size: 24, color: Colors.green,)
                  ],
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/img/chinese_lang.png', width: 45, fit: BoxFit.fitWidth,),
                        SizedBox(width: 20,),
                        Text("chinese",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
                      ],
                    ),
                    Icon(Icons.check_circle, size: 24, color: Color(0xff9E9E9E),)
                  ],
                ),
              ],
            ))
    );
  }

}
