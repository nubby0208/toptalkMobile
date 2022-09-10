import 'package:flutter/material.dart';
import 'package:locals/src/pages/login.dart';
import 'package:locals/src/pages/sign_in.dart';
import 'package:locals/src/utils/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/gestures.dart';
import 'package:locals/src/models/route_argument.dart';
import '../repository/user_repository.dart' as repository;
import 'dart:convert';
import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/HexColor.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:shared_preferences/shared_preferences.dart';


class SplashWidget extends StatefulWidget {
  @override
  _SplashWidgetState createState() => _SplashWidgetState();
}

class _SplashWidgetState extends StateMVC<SplashWidget> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () async {
      //check if email is save to start login if not Navigate to WelcomePage
      final sharedPreferences = await SharedPreferences.getInstance();
      final email = sharedPreferences.getString('email');
      final password = sharedPreferences.getString('password');
      if (email != null && password != null) {
        startLogin(email, password);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SignInWidget()),
                (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        backgroundColor: Helper.baseColor,
        body: Image.asset('assets/img/welcome.jpeg',
          width: config.App(context).appWidth(100), height: config.App(context).appHeight(100),
          fit: BoxFit.fill,)
      ),
    );
  }
  void startLogin(String email, String password) async {
    // check email and password if succ Move to Home if Not Move to WelcomePage

    try{
      String response =await repository.userLogin(email, password);
      final jsonResponse = json.decode(response);
      Constants.userresponse = jsonResponse;
      if(jsonResponse['success'] == true){
        final sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('_id', jsonResponse['user']['_id']);
        sharedPreferences.setString('name', jsonResponse['user']['name']);
        sharedPreferences.setString('email', jsonResponse['user']['email']);
        sharedPreferences.setString('access_token', jsonResponse['accessToken']);
        sharedPreferences.setString('password', password);
        Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 0, heroTag: "0"));
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SignInWidget()),
                (route) => false);
      }
    } catch(err) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignInWidget()),
              (route) => false);
    }
  }
}
