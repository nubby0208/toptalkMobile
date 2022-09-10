import 'dart:async';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:locals/generated/l10n.dart';
import 'package:locals/src/pages/chat_rooms.dart';
import 'package:locals/src/pages/chat_screen.dart';
import 'package:locals/src/pages/me.dart';
import 'package:locals/src/pages/private_chat.dart';
import 'package:locals/src/pages/top.dart';
import 'package:locals/src/pages/upload_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:locals/src/helpers/helper.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:locals/src/pages/public_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/app_config.dart' as config;
import '../repository/user_repository.dart' as repository;
import 'package:geolocator/geolocator.dart';

class NavBarWidget extends StatefulWidget {
  dynamic currentTab;
  dynamic currentSubIndex;
  RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  Widget currentPage = PublicChatWidget();
  NavBarWidget({
    Key key,
    this.currentTab, this.routeArgument
  }) {
    if (currentTab != null) {
      RouteArgument argument = currentTab;
      currentTab = argument.currentTab;
      currentSubIndex = argument.heroTag;
      print(currentSubIndex);
    } else {
      currentTab = 0;
      currentSubIndex = "0";
    }
  }

  @override
  _NavBarWidgetState createState() {
    return _NavBarWidgetState();
  }
}

class _NavBarWidgetState extends State<NavBarWidget> {

  // Position _currentPosition;
  StreamSubscription<Position> positionStream;
  initState() {
    super.initState();
    _selectTab(widget.currentTab);
    setCurrentLocation();
    _getCurrentLocation();
  }
  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  void _selectTab(int tabItem) async {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage = PublicChatWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 1:
          widget.currentPage = TopWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 2:
        // widget.currentPage = UploadScreenWidget(parentScaffoldKey: widget.scaffoldKey);
          widget.currentPage = ChatRoomsWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 3:
          widget.currentPage = MeWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
    });
  }

  setCurrentLocation() async {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) async {
      var _currentPosition;
      setState(() {
        _currentPosition = position;
      });
      print(_currentPosition);
      var myLocation = _currentPosition.latitude.toString() + "," + _currentPosition.longitude.toString();
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('access_token');
      final userId = sharedPreferences.getString('_id');
      await repository.updateLocation(token,userId, myLocation.toString());

    }).catchError((e) {
      print(e);
    });
  }
  _getCurrentLocation() async{


    positionStream = Geolocator.getPositionStream(
      intervalDuration: Duration(minutes: 3),
    ).listen((position) async {
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('access_token');
      final userId = sharedPreferences.getString('_id');
      String locationValue = position.latitude.toString() + "," + position.longitude.toString();
      repository.updateLocation(token,userId,  locationValue);
    });
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: widget.scaffoldKey,
        body: Stack(
          children: [
            widget.currentPage,
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  child: Container(
                    width: config.App(context).appWidth(100),
                    height: config.App(context).appWidth(15),
                    color: Colors.white,
                    child:  SalomonBottomBar(
                      currentIndex: widget.currentTab,
                      onTap: (i) => {_selectTab(i)},
                      itemPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                      items: [
                        /// Home
                        SalomonBottomBarItem(
                            icon: ImageIcon(AssetImage('assets/img/tab1.png'), size: 24,),
                            title: Text("public_chat".tr(), style: TextStyle(color: Color(0xff7452A8), fontSize: 10)).tr(),
                            selectedColor: Color(0xff7452A8),
                            unselectedColor: Color(0xff7452A8)
                        ),

                        SalomonBottomBarItem(
                            icon: ImageIcon(AssetImage('assets/img/tab2.png'), size: 24,),
                            title: Text("top".tr(), style: TextStyle(color: Color(0xff7452A8), fontSize: 10)).tr(),
                            selectedColor: Color(0xff7452A8),
                            unselectedColor: Color(0xff7452A8)
                        ),
                        SalomonBottomBarItem(
                            icon: ImageIcon(AssetImage('assets/img/tab4.png'), size: 24,),
                            title: Text("private_chat", style: TextStyle(color: Color(0xff7452A8), fontSize: 10)).tr(),
                            selectedColor: Color(0xff7452A8),
                            unselectedColor: Color(0xff7452A8)
                        ),
                        SalomonBottomBarItem(
                            icon: ImageIcon(AssetImage('assets/img/tab5.png'), size: 24,),
                            title: Text("me", style: TextStyle(color: Color(0xff7452A8), fontSize: 10)).tr(),
                            selectedColor: Color(0xff7452A8),
                            unselectedColor: Color(0xff7452A8)
                        ),
                      ],
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}