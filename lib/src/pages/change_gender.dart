import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locals/src/controllers/setting_controller.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/HexColor.dart';
import '../repository/user_repository.dart' as userRepo;

class ChangeGenderWidget extends StatefulWidget {
  final jsonResponse;

  ChangeGenderWidget(this.jsonResponse);
  @override
  _ChangeGenderWidgetState createState() => _ChangeGenderWidgetState();
}

class _ChangeGenderWidgetState extends StateMVC<ChangeGenderWidget> {
  SettingController _con;

  _ChangeGenderWidgetState() : super(SettingController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.maleCheck = widget.jsonResponse['data']['gender'].toString() == '0';
    _con.femaleCheck = widget.jsonResponse['data']['gender'].toString() == '1';
    _con.businessCheck =
        widget.jsonResponse['data']['gender'].toString() == '2';
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
          body: Stack(
            children: [headBox(), mainContent()],
          )),
    );
  }

  Widget headBox() {
    return Padding(
      padding: EdgeInsets.only(
          top: config.App(context).appWidth(12),
          left: config.App(context).appWidth(7)),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/NavBar',
                  arguments: RouteArgument(currentTab: 3, heroTag: "0"));
            },
            child: Icon(
              Icons.arrow_back_outlined,
              size: 24,
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: 50,
          ),
          Text("change_gender",
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)).tr(),
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
        padding: EdgeInsets.symmetric(
            horizontal: config.App(context).appWidth(7), vertical: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: Colors.white),
        child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              children: [
                SizedBox(
                  height: 100,
                ),
                Text(widget.jsonResponse['data']['email'].toUpperCase(),
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              _con.maleCheckHandle();
                            },
                            child: Icon(
                              _con.maleCheck
                                  ? CupertinoIcons.checkmark_square
                                  : Icons.check_box_outline_blank_rounded,
                              color: Color(0xff9496DE),
                              size: 25,
                            ),
                          ),
                          // Icon(CupertinoIcons.checkmark_square, color: Color(0xff9496DE), size: 25,),
                          SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            'assets/img/male.png',
                            height: 25,
                            fit: BoxFit.fitHeight,
                          )
                        ],
                      ),
                      SizedBox(width:40),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              _con.femaleCheckHandle();
                            },
                            child: Icon(
                              _con.femaleCheck
                                  ? CupertinoIcons.checkmark_square
                                  : Icons.check_box_outline_blank_rounded,
                              color: Color(0xff9496DE),
                              size: 25,
                            ),
                          ),
                          // Icon(CupertinoIcons.checkmark_square, color: Color(0xff9496DE), size: 25,),
                          SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            'assets/img/woman.png',
                            height: 25,
                            fit: BoxFit.fitHeight,
                          )
                        ],
                      ),
                      // Row(
                      //   children: [
                      //     InkWell(
                      //       onTap: () {
                      //         _con.businessCheckHandle();
                      //       },
                      //       child: Icon(
                      //         _con.businessCheck
                      //             ? CupertinoIcons.checkmark_square
                      //             : Icons.check_box_outline_blank_rounded,
                      //         color: Color(0xff9496DE),
                      //         size: 25,
                      //       ),
                      //     ),
                      //     // Icon(CupertinoIcons.checkmark_square, color: Color(0xff9496DE), size: 25,),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      //     Image.asset(
                      //       'assets/img/shop_icon.png',
                      //       height: 25,
                      //       fit: BoxFit.fitHeight,
                      //     )
                      //   ],
                      // )
                    ],
                  ),
                ),
                SizedBox(
                  height: 120,
                ),
                _con.loading
                    ? progress
                    : GestureDetector(
                        onTap: () {
                          if (_con.maleCheck ||
                              _con.femaleCheck ||
                              _con.businessCheck) {
                            String gender = '0';
                            if (_con.maleCheck) {
                              gender = '0';
                            }
                            if (_con.femaleCheck) {
                              gender = '1';
                            }
                            if (_con.businessCheck) {
                              gender = '2';
                            }
                            _con.change_gender(gender);
                          }
                        },
                        child: Container(
                          width: config.App(context).appWidth(100),
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color(0xff7452A8)),
                          child: Text("change_gender",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)).tr(),
                        ),
                      ),
              ],
            )));
  }
}
