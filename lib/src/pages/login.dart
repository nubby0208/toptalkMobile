import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import 'package:easy_localization/src/public_ext.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> {
  UserController _con;

  _LoginWidgetState() : super(UserController()) {
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
          backgroundColor: Helper.baseColor,
          key: _con.scaffoldKey,
          // resizeToAvoidBottomPadding: false,
          body:  Stack(
            children: [
              Image.asset('assets/img/back.png', width: config.App(context).appWidth(100), height: config.App(context).appHeight(100), fit: BoxFit.fill,),
              Image.asset('assets/img/login_back.png', width: config.App(context).appWidth(100), fit: BoxFit.fitWidth,),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () => {
                    Navigator.of(context).pushNamed('/SignIn')
                  },
                  child: Container(
                    width: config.App(context).appWidth(100),
                    margin: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(5), vertical: 190),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white
                    ),
                    child: Text("sign_in", textAlign: TextAlign.center, maxLines: 1, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xff7452A8))).tr(),
                  ),
                ),
              )
            ],
          )
      ),
    );
  }
}
