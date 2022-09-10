import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/gestures.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/HexColor.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:easy_localization/src/public_ext.dart';


class UserAgreementWidget extends StatefulWidget {
  @override
  _UserAgreementState createState() => _UserAgreementState();
}

class _UserAgreementState extends StateMVC<UserAgreementWidget> {
  UserController _con;

  _UserAgreementState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.getPrivacyPolicy();
    _con.getUserAgreement();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() async {
Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
          backgroundColor: Color(0xffE9DFF8),
        key: _con.scaffoldKey,
        // resizeToAvoidBottomPadding: false,
        body:  Stack(
          children: [
            headBox(),
            _con.userAgreementDataLoaded && _con.userPolicyDataLoaded
            ? mainContent()
            : progress
          ],
        )
      ),
    );
  }

  Widget headBox() {
    return Padding(
      padding: EdgeInsets.only(top: config.App(context).appWidth(12), left: config.App(context).appWidth(7), right: config.App(context).appWidth(7)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.asset('assets/img/back_icon.png', width: config.App(context).appWidth(5), fit: BoxFit.fitWidth,),
          ),
          Text("user_agreement".toString().tr() ,
              textAlign: TextAlign.center, maxLines: 1,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
        ],
      ),
    );
  }

  Widget mainContent() {
    return Container(
      width: config.App(context).appWidth(100),
      margin: EdgeInsets.only(top: config.App(context).appWidth(23)),
      padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(7), vertical: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Colors.white
      ),
      child: MediaQuery.removePadding(context: context, removeTop: true,
          child: ListView(
            children: [

              Text(_con.userAgreement.toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),
              SizedBox(height: 20),
              Text(_con.privacyPolicyData.toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black)),

            ],
          )
      )
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

}
