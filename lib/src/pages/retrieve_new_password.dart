import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/gestures.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/HexColor.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:easy_localization/src/public_ext.dart';


class RetrieveNewPasswordWidget extends StatefulWidget {

  String user_id;

  RetrieveNewPasswordWidget(this.user_id);
  @override
  _RetrieveNewPasswordWidgetState createState() => _RetrieveNewPasswordWidgetState();
}

class _RetrieveNewPasswordWidgetState extends StateMVC<RetrieveNewPasswordWidget> {
  UserController _con;
  TextEditingController passwordController = TextEditingController();
  TextEditingController reEnterPasswordController = TextEditingController();
  _RetrieveNewPasswordWidgetState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
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
              Navigator.of(context).pop();
            },
            child: Image.asset('assets/img/back_icon.png', width: config.App(context).appWidth(5), fit: BoxFit.fitWidth,),
          ),
          SizedBox(width: 50,),
          Text("retrieve_password", textAlign: TextAlign.center, maxLines: 1,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
        ],
      ),
    );
  }

  Widget mainContent() {
    return Container(
      width: config.App(context).appWidth(100),
      margin: EdgeInsets.only(top: config.App(context).appWidth(23)),
      padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(7), vertical: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Colors.white
      ),
      child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 160,),
              TextFormField(
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                obscureText: _con.passwordShow,
                controller: passwordController,
                decoration: InputDecoration(
                    suffixIcon: _con.passwordShow ? InkWell(
                      onTap: () {
                        _con.hidePassword();
                      },
                      child: Icon(CupertinoIcons.eye, color: Color(0xff959595),),
                    ) : InkWell(onTap: () {_con.showPassword();},
                      child: Icon(CupertinoIcons.eye_slash, color: Color(0xff959595),),
                    ),
                    hintText: "  " + "new_password".tr(),
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
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 40,),
              TextFormField(
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                obscureText: _con.passwordShow,
                controller: reEnterPasswordController,
                decoration: InputDecoration(
                    suffixIcon: _con.passwordShow ? InkWell(
                      onTap: () {
                        _con.hidePassword();
                      },
                      child: Icon(CupertinoIcons.eye, color: Color(0xff959595),),
                    ) : InkWell(onTap: () {_con.showPassword();},
                      child: Icon(CupertinoIcons.eye_slash, color: Color(0xff959595),),
                    ),
                    hintText: "  " + "re_enter_new_password".tr(),
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
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 40,),
              SizedBox(height: 100,),

              GestureDetector(
                onTap: () => {
                  if(passwordController.text.trim().length != 0) {
                    if(passwordController.text.toString() == reEnterPasswordController.text.toString()) {
                      _con.resetPassword(widget.user_id, passwordController.text.trim())
                    }

                  }
                },
                child: Container(
                  width: config.App(context).appWidth(100),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xff7452A8)
                  ),
                  child: Text("change_password", textAlign: TextAlign.center, maxLines: 1,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)).tr(),
                ),
              ),
            ],
          )
        ],
      )
    );
  }
}
