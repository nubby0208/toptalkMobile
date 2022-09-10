import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locals/src/controllers/setting_controller.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/gestures.dart';

import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/HexColor.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:easy_localization/src/public_ext.dart';

class ChangeNickNameWidget extends StatefulWidget {
  final jsonResponse;

  ChangeNickNameWidget(this.jsonResponse);
  @override
  _ChangeNickNameWidgetState createState() => _ChangeNickNameWidgetState();
}

class _ChangeNickNameWidgetState extends StateMVC<ChangeNickNameWidget> {
  SettingController _con;

  _ChangeNickNameWidgetState() : super(SettingController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 3, heroTag: "0"));

          return false;
        },
      child: Scaffold(
          backgroundColor: Color(0xffE9DFF8),
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
      padding: EdgeInsets.only(top: config.App(context).appWidth(12), left: config.App(context).appWidth(7)),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 3, heroTag: "0"));
            },
            child: Icon(Icons.arrow_back_outlined, size: 24, color: Colors.black,),
          ),
          SizedBox(width: 50,),
          Text("change_nickname", textAlign: TextAlign.center, maxLines: 1,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
        ],
      ),
    );
  }

  Widget progress = Container(
    padding: EdgeInsets.symmetric(vertical: 15),
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      backgroundColor: Colors.green,
      strokeWidth: 7,
    ),
  );

  Widget mainContent() {
    return Container(
      width: config.App(context).appWidth(100),
      margin: EdgeInsets.only(top: config.App(context).appWidth(23)),
      padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(7), vertical: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Colors.white
      ),
      child: MediaQuery.removePadding(context: context,
          removeTop: true,
          child: ListView(
            children: [
              SizedBox(height: 100,),
              Text(widget.jsonResponse['data']['email'].toUpperCase(),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 30,),
              TextFormField(
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                    hintText: widget.jsonResponse['data']['nickname'],
                    hintStyle: TextStyle(color: Color(0xff959595), fontSize: 18, fontWeight: FontWeight.w400),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      //  when the TextFormField in unfocused
                    ) ,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff9496DE)),
                      //  when the TextFormField in focused
                    ) ,
                    border: UnderlineInputBorder(
                    )
                ),
                keyboardType: TextInputType.text,
                controller: _con.nicknameController,
              ),
              SizedBox(height: 120,),
              _con.loading ? progress: GestureDetector(
                onTap: () => {
                  if(_con.nicknameController.text.length != 0 ) {
                    _con.change_nickname(_con.nicknameController.text.trim())
                  }
                },
                child: Container(
                  width: config.App(context).appWidth(100),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xff7452A8)
                  ),
                  child: Text("change_nickname", textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)).tr(),
                ),
              ),
            ],
          ))
    );
  }
}
