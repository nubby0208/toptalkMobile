import 'dart:async';
import 'dart:developer';
import 'package:easy_localization/src/public_ext.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:locals/src/controllers/public_chat_controller.dart';
import 'package:locals/src/controllers/setting_controller.dart';
import 'package:locals/src/controllers/user_controller.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:locals/src/utils/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../controllers/public_chat_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../repository/settings_repository.dart' as setting;
import 'package:vibration/vibration.dart';

class SettingsWidget extends StatefulWidget {
  final jsonResponse;

  SettingsWidget(this.jsonResponse);
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends StateMVC<SettingsWidget> {
  SettingController _con;

  _SettingsWidgetState() : super(SettingController()) {
    _con = controller;
  }

  Color senderFontColor = Colors.black;
  Color receiverFontColor = Colors.white;
  double _currentSliderValue = 100;
  String maxCoverage = "300";
  bool isSwitched = true;
  bool use_current_location_as_permanent = false;
  bool display_position_with_random_offset = false;
  bool all_new_message_alert = false;
  bool public_chat_room_me_alert = false;
  bool change_kilometers_to_miles = false;
  bool voice_alert = false;
  bool vibration_alert = false;
  bool do_not_disturb = false;
  bool isExistAdmin = false;
  String adminID = "";
  String version = '1.0';
  getversion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      log(version);
    });
  }

  getversionnew() async {
    getdata = await _con.getsettinggs();
    Timer _timer;

    if (getdata["data"]['app_version']!=version)
    {   showDialog(
        context: context,
        builder: (context) {
          _timer = Timer(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            backgroundColor: Color(0xff9496DE),
            actions: [
              Center(
                child: Column(
                  children: [
                    Text(
                      "new_version",
                      style:
                      TextStyle(color: Colors.white),
                    ).tr(),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        var url = "https://localtalk.mobi";
                        await launch(url);},



                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        height: 40,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.white),
                            borderRadius:
                            BorderRadius.circular(40),
                            color: Color(0xff9496DE)),
                        child: Text(
                          "update_version",
                          style: TextStyle(
                              color: Colors.white),
                        ).tr(),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }).then((val){
      if (_timer.isActive) {
        _timer.cancel();
      }
    });


    }
  }


  var getdata;
  @override
  void initState() {
    super.initState();
    // simply use this

    _con.init();
    log("-------------------$adminID");
    getversionnew();
    getversion();
    setState(() {
      if (widget.jsonResponse['data']['coverage'] == null) {
        _currentSliderValue = double.parse(
            widget.jsonResponse['data']['max_coverage'].toString());
      } else {
        _currentSliderValue =
            widget.jsonResponse['data']['coverage'].toDouble();
        log(_currentSliderValue.toString());
      }

      maxCoverage = widget.jsonResponse['data']['max_coverage'].toString();
      use_current_location_as_permanent =
          widget.jsonResponse['data']['use_current_location_as_permanent'];
      display_position_with_random_offset =
          widget.jsonResponse['data']['display_position_with_random_offset'];
      all_new_message_alert =
          widget.jsonResponse['data']['all_new_message_alert'];
      public_chat_room_me_alert =
          widget.jsonResponse['data']['public_chat_room_me_alert'];
      change_kilometers_to_miles =
          widget.jsonResponse['data']['change_kilometers_to_miles'];
      voice_alert = widget.jsonResponse['data']['voice_alert'];
      vibration_alert = widget.jsonResponse['data']['vibration_alert'];
      do_not_disturb = widget.jsonResponse['data']['do_not_disturb'];
      isExistAdmin = widget.jsonResponse['data']['isExistAdmin'];
      adminID = widget.jsonResponse['data']['chatAdminId'].toString();
      log(widget.jsonResponse['data']['chatAdminId'].toString());
    });




  }

  savetodb() async {
    await _con.setSettings(
        int.parse(_currentSliderValue.toStringAsFixed(0)),
        use_current_location_as_permanent,
        display_position_with_random_offset,
        all_new_message_alert,
        public_chat_room_me_alert,
        change_kilometers_to_miles,
        voice_alert,
        vibration_alert,
        do_not_disturb);
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
      onWillPop: () async {
        Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 3, heroTag: "0"));

        return false;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          key: _con.scaffoldKey,
          // resizeToAvoidBottomPadding: false,
          body: Stack(
            children: [
              headBox(),
              _con.loading ? progress : mainContent(),
            ],
          )),
    );
  }

  Widget headBox() {
    return Container(
      height: config.App(context).appWidth(20),
      margin: EdgeInsets.only(top: config.App(context).appWidth(5)),
      padding:
          EdgeInsets.symmetric(horizontal: config.App(context).appWidth(5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () async {
                  Navigator.of(context).pushNamed('/NavBar',
                      arguments: RouteArgument(currentTab: 3, heroTag: "0"));
                },
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text("settings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
            ],
          ),
        ],
      ),
    );
  }

  Widget mainContent() {
    return Container(
        width: config.App(context).appWidth(100),
        margin: EdgeInsets.only(top: config.App(context).appWidth(20)),
        padding: EdgeInsets.symmetric(
            horizontal: config.App(context).appWidth(8), vertical: 25),
        child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: config.App(context).appWidth(12),
                          height: config.App(context).appWidth(12),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xffC4C4C4).withOpacity(0.55),
                              image: DecorationImage(
                                image: Image.network(Constants.SERVER_URL +
                                        "v1/user/img-src/" +
                                        _con.jsonResponse['data']['avatarUrl'])
                                    .image,
                                fit: BoxFit.cover,
                              )),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(widget.jsonResponse['data']['name'],
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                SizedBox(
                                  width: 10,
                                ),
                                Image.asset(
                                  _con.jsonResponse['data']['gender'] == 0
                                      ? 'assets/img/man.png'
                                      : (_con.jsonResponse['data']['gender'] ==
                                              1
                                          ? 'assets/img/woman.png'
                                          : 'assets/img/shop_icon.png'),
                                  height: 30,
                                  fit: BoxFit.fitHeight,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: config.App(context).appWidth(50),
                              child: Text(widget.jsonResponse['data']['email'].toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black)),
                            )
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.hand_thumbsup_fill,
                              color: Color(0xff9496DE),
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              color: Color(0xffE3E3E3),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(widget.jsonResponse['data']['like'].toString(),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.hand_thumbsdown,
                              color: Color(0xffD7443E),
                              size: 20,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 20,
                              width: 1,
                              color: Color(0xffE3E3E3),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                                widget.jsonResponse['data']['dislike']
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(height: 50),
                Text("nearby",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff5C5C5C))).tr(),
                SizedBox(
                  height: 45,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("0",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff9496DE))),
                    SizedBox(
                      width: config.App(context).appWidth(70),
                      child:SfSliderTheme(
                        data: SfSliderThemeData(
                          tooltipBackgroundColor: Color(0xff9496DE),
                        ),
                        child: SfSlider(
                          min: 0.0,
                          activeColor: Color(0xff9496DE),

                          max: double.parse(maxCoverage),

shouldAlwaysShowTooltip: true,
                          tooltipShape:SfRectangularTooltipShape(

                          ),
                          enableTooltip: true,
                          value:double.parse(_currentSliderValue.toStringAsFixed(0)),
                          onChanged: (dynamic newValue) {
                            setState(() {
                              _currentSliderValue= newValue;
                              log(_currentSliderValue.toString());
                              savetodb();
                            });
                          },
                        ),
                      ),


                    ),
                    Text(maxCoverage,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff9496DE))),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: config.App(context).appWidth(30),
                  child: Text("cover",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff5C5C5C))).tr(),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                    onTap: () {
                      if (!isExistAdmin) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('admin_set').tr(),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('close').tr())
                                ],
                              );
                            });
                      } else {
                        _con.createRoom(adminID);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                  color: Color(0xff9496DE), width: 2)),
                          child: Text("talk_service",
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff9496DE))).tr(),
                        ),
                      ],
                    )),
                // SizedBox(
                //   height: 20,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     SizedBox(
                //       width: config.App(context).appWidth(40),
                //       child: Text(
                //           "current_location",
                //           style: TextStyle(
                //               fontSize: 14,
                //               fontWeight: FontWeight.w400,
                //               color: Color(0xff5C5C5C))).tr(),
                //     ),
                //     Transform.scale(
                //       scale: 0.6,
                //       child: CupertinoSwitch(
                //         value: use_current_location_as_permanent,
                //         activeColor: Color(0xff4F57B4),
                //         trackColor: Color(0xffCBCBCB),
                //         onChanged: (value) {
                //           setState(() {
                //             use_current_location_as_permanent = value;
                //             savetodb();
                //           });
                //         },
                //       ),
                //     )
                //   ],
                // ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: config.App(context).appWidth(40),
                      child: Text("miless",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff5C5C5C))).tr(),
                    ),
                    Transform.scale(
                      scale: 0.6,
                      child: CupertinoSwitch(
                        value: change_kilometers_to_miles,
                        activeColor: Color(0xff4F57B4),
                        trackColor: Color(0xffCBCBCB),
                        onChanged: (value) {
                          setState(() {
                            change_kilometers_to_miles = value;
                            savetodb();
                          });
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: config.App(context).appWidth(30),
                      child: Text("version".tr() +" $version",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff5C5C5C)))
                    ),
                    GestureDetector(
                      onTap: () {
                        log(getdata['data']['app_version']);
                        log(version);
                        if (getdata["data"]['app_version'] == version) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Color(0xff9496DE),
                                  title: Center(
                                      child: Text(
                                    "noversion".tr(),
                                    style: TextStyle(color: Colors.white),
                                  )),
                                );
                              });
                        }
                        else {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Color(0xff9496DE),
                                  actions: [
                                    Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            "new_version",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ).tr(),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                var url = "https://localtalk.mobi";
                                await launch(url);},



                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 10),
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(40),
                                                  color: Color(0xff9496DE)),
                                              child: Text(
                                                "update_version",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ).tr(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              });
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            border:
                                Border.all(color: Color(0xff9496DE), width: 2)),
                        child: Text("check_version",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff9496DE))).tr(),
                      ),
                    ),
                  ],
                )
                // SizedBox(height: 40,),
                // Text("New Message Alert",
                //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff5C5C5C))),
                // SizedBox(height: 20,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     SizedBox(
                //       width: config.App(context).appWidth(40),
                //       child: Text("All new messages",
                //           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C))),
                //     ),
                //     Transform.scale(
                //       scale: 0.6,
                //       child: CupertinoSwitch(
                //         value: all_new_message_alert,
                //         activeColor: Color(0xff4F57B4),
                //         trackColor: Color(0xffCBCBCB),
                //         onChanged: (value) {
                //           setState(() {
                //             all_new_message_alert = value;
                //           });
                //         },
                //       ),
                //     )
                //   ],
                // ),
                // SizedBox(height: 20,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     SizedBox(
                //       width: config.App(context).appWidth(40),
                //       child: Text("public chatroom @me",
                //           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C))),
                //     ),
                //     Transform.scale(
                //       scale: 0.6,
                //       child: CupertinoSwitch(
                //         value: public_chat_room_me_alert,
                //         activeColor: Color(0xff4F57B4),
                //         trackColor: Color(0xffCBCBCB),
                //         onChanged: (value) {
                //           setState(() {
                //             public_chat_room_me_alert = value;
                //           });
                //         },
                //       ),
                //     )
                //   ],
                // ),
                // SizedBox(height: 20,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     SizedBox(
                //       width: config.App(context).appWidth(40),
                //       child: Text("Only private chat new messsage",
                //           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C))),
                //     ),
                //     Transform.scale(
                //       scale: 0.6,
                //       child: CupertinoSwitch(
                //         value: change_kilometers_to_miles,
                //         activeColor: Color(0xff4F57B4),
                //         trackColor: Color(0xffCBCBCB),
                //         onChanged: (value) {
                //           setState(() {
                //             change_kilometers_to_miles = value;
                //           });
                //         },
                //       ),
                //     )
                //   ],
                // ),
                ,
                SizedBox(
                  height: 40,
                ),
                // Text("New Private Chat Message Warning",
                //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff5C5C5C))),
                // SizedBox(height: 20,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     SizedBox(
                //       width: config.App(context).appWidth(40),
                //       child: Text("Voice",
                //           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C))),
                //     ),
                //     Transform.scale(
                //       scale: 0.6,
                //       child: CupertinoSwitch(
                //         value: voice_alert,
                //         activeColor: Color(0xff4F57B4),
                //         trackColor: Color(0xffCBCBCB),
                //         onChanged: (value) {
                //           setState(() {
                //             voice_alert = value;
                //           });
                //         },
                //       ),
                //     )
                //   ],
                // ),
                // SizedBox(height: 20,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     SizedBox(
                //       width: config.App(context).appWidth(40),
                //       child: Text("Vibration",
                //           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C))),
                //     ),
                //     Transform.scale(
                //       scale: 0.6,
                //       child: CupertinoSwitch(
                //         value: vibration_alert,
                //         activeColor: Color(0xff4F57B4),
                //         trackColor: Color(0xffCBCBCB),
                //         onChanged: (value) async {
                //
                //           setState(() {
                //             vibration_alert = value;
                //           });
                //           if(value) {
                //             print(value);
                //             if (await Vibration.hasVibrator()) {
                //               Vibration.vibrate();
                //               await Future.delayed(Duration(milliseconds: 500));
                //               Vibration.vibrate();
                //             }
                //           } else {
                //             Vibration.cancel();
                //           }
                //         },
                //       ),
                //     )
                //   ],
                // ),
                // SizedBox(height: 20,),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     SizedBox(
                //       width: config.App(context).appWidth(40),
                //       child: Text("Do not disturb",
                //           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C))),
                //     ),
                //     Transform.scale(
                //       scale: 0.6,
                //       child: CupertinoSwitch(
                //         value: do_not_disturb,
                //         activeColor: Color(0xff4F57B4),
                //         trackColor: Color(0xffCBCBCB),
                //         onChanged: (value) {
                //           setState(() {
                //             do_not_disturb = value;
                //           });
                //         },
                //       ),
                //     )
                //   ],
                // ),
                // GestureDetector(
                //     onTap: () async {
                //       setState((){
                //         _con.loading = true;
                //       });
                //       await _con.setSettings(_currentSliderValue.toInt(),
                //           use_current_location_as_permanent,
                //           display_position_with_random_offset,
                //           all_new_message_alert,
                //           public_chat_room_me_alert,
                //           change_kilometers_to_miles,
                //           voice_alert,
                //           vibration_alert,
                //           do_not_disturb
                //       );
                //       Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 3, heroTag: "0"));
                //     },
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Container(
                //           padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                //           margin: EdgeInsets.symmetric(vertical: 20),
                //           decoration: BoxDecoration(
                //               borderRadius: BorderRadius.all(Radius.circular(20)),
                //               color: Color(0xff9496DE)
                //               // border: Border.all(color: Color(0xff9496DE), width: 2)
                //           ),
                //           child: Text("Save",
                //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                //         ),
                //       ],
                //     )
                // ),
              ],
            )));
  }
}
