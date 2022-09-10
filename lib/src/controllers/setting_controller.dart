import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:locals/src/repository/settings_repository.dart';
import 'package:locals/src/utils/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import 'dart:convert';
import '../repository/settings_repository.dart' as repository;
import '../repository/user_repository.dart' as userRepository;
import 'package:image_picker/image_picker.dart';
import '../repository/private_chat_repository.dart' as privateRepository;
import 'package:easy_localization/src/public_ext.dart';

class SettingController extends ControllerMVC {

  GlobalKey<ScaffoldState> scaffoldKey;
  bool loading;
  dynamic jsonResponse;
  bool passwordShow = true;
  TextEditingController oldpwController;
  TextEditingController newpwController;
  TextEditingController confirmnewpwController;
  TextEditingController nicknameController;
  bool maleCheck = false;
  bool femaleCheck = false;
  bool businessCheck = false;

  SettingController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    oldpwController= TextEditingController();
    newpwController= TextEditingController();
    confirmnewpwController= TextEditingController();
    nicknameController= TextEditingController();

    loading = false;
  }
  void showPassword() {
    setState(() {
      passwordShow = true;
    });
  }

  void hidePassword() {
    setState(() {
      passwordShow = false;
    });
  }
  void maleCheckHandle() {
    if(maleCheck) {
      setState(() {
        maleCheck = false;
      });
    } else {
      setState(() {
        maleCheck = true;
        femaleCheck = false;
        businessCheck = false;
      });
    }
  }

  void femaleCheckHandle() {
    if(femaleCheck) {
      setState(() {
        femaleCheck = false;
      });
    } else {
      setState(() {
        femaleCheck = true;
        maleCheck = false;
        businessCheck = false;
      });
    }
  }

  void businessCheckHandle() {
    if(businessCheck) {
      setState(() {
        businessCheck = false;
      });
    } else {
      setState(() {
        businessCheck = true;
        femaleCheck = false;
        maleCheck = false;
      });
    }
  }

  void init() async{
    setState((){
      loading = true;
    });
    final sharedPreferences = await SharedPreferences.getInstance();

    final id = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');

    try{
      String response= await repository.initSettings(id, token);
      setState((){
        jsonResponse = json.decode(response);
      });
      if(jsonResponse['error'] == false) {
        setState((){
          loading = false;
        });
      }
    }catch(err){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(err.toString()),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close').tr())
              ],
            );
          });
    }

  }
   getsettinggs() async{

    final sharedPreferences = await SharedPreferences.getInstance();

    final id = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');


      var response= await repository.getSettingsForChat(id, token);
       log(response);
return json.decode(response);
  }
  void change_password(String oldpw, String newpw) async{
    setState((){
      loading = true;
    });
    final sharedPreferences = await SharedPreferences.getInstance();

    final id = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');

    try{
      String response= await repository.changePassword(id, token, oldpw, newpw);
      var jsonResponses = json.decode(response);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(jsonResponses['error'] == true ?jsonResponses['data']: 'changed'.tr()),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close').tr())
              ],
            );
          });
    }catch(err){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("incorrect".tr()),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close').tr())
              ],
            );
          });
    }
    setState((){
      loading = false;
    });
  }

  void setSettings(int coverrage, bool use_current_location_as_permanent,
      bool display_position_with_random_offset,
      bool all_new_message_alert,
      bool public_chat_room_me_alert,
      bool change_kilometers_to_miles,
      bool voice_alert,
      bool vibration_alert,
      bool do_not_disturb
      ) async{

    final sharedPreferences = await SharedPreferences.getInstance();

    final id = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');
    try{
      await repository.setSettings(id, token, coverrage, use_current_location_as_permanent,
          display_position_with_random_offset,
          all_new_message_alert,
          public_chat_room_me_alert,
          change_kilometers_to_miles,
          voice_alert,
          vibration_alert,
          do_not_disturb);
    }catch(err){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(err.toString()),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close').tr())
              ],
            );
          });
    }
  }

  change_nickname(String trim) async {
    setState((){
      loading = true;
    });
    final sharedPreferences = await SharedPreferences.getInstance();

    final id = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');

    try{
      String response= await repository.changeNickName(id, token, trim);
      var jsonResponses = json.decode(response);
      setState(() {
        sharedPreferences.setString('name', trim);
      });
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(jsonResponses['error'] == true ?jsonResponses['data']: 'changed'.tr()),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close').tr())
              ],
            );
          });
    }catch(err){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Failed"),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close').tr())
              ],
            );
          });
    }
    setState((){
      loading = false;
    });
  }

  Future<void> change_gender(String gender) async {
    setState((){
      loading = true;
    });
    final sharedPreferences = await SharedPreferences.getInstance();

    final id = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');

    try{
      String response= await repository.changeGender(id, token, gender);
      var jsonResponses = json.decode(response);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(jsonResponses['error'] == true ?jsonResponses['data']: 'changed'.tr()),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close').tr())
              ],
            );
          });
    }catch(err){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Failedd"),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close').tr())
              ],
            );
          });
    }
    setState((){
      loading = false;
    });
  }

  void createRoom(String adminId) async{
    setState(() {
      loading = true;
    });
    final sharedPreferences = await SharedPreferences.getInstance();

    final userId = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');
    String response= await privateRepository.createRoom(userId, token, adminId);
    final jsonResponse = json.decode(response);
    if(jsonResponse['error'] == false) {
      Navigator.of(context).pushNamed('/ChatScreen', arguments: RouteArgument(subData: jsonResponse['data']['_id'].toString(), heroTag:  adminId, id: userId));
    }
  }

  signOut() async {
    setState((){loading = true;});
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');
    final myId = sharedPreferences.getString('_id');
    print(myId);
    try{
      String response =await userRepository.userLogOut(token);
      final jsonResponse = json.decode(response);
      Constants.userresponse = jsonResponse;
      if(jsonResponse['success'] == true){
        await sharedPreferences.clear();
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed('/SignIn');
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Logout failed'),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('close').tr())
                ],
              );
            });
      }
    } catch(err) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Failed"),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close').tr())
              ],
            );
          });
    }
    setState((){loading = false;});
  }


}
