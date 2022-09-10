import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/public_chat_repository.dart' as repository;
import '../repository/private_chat_repository.dart' as privateRepository;
import '../repository/settings_repository.dart' as settingRepository;
import 'package:easy_localization/src/public_ext.dart';

class PublicChatController extends ControllerMVC {
  bool loading = false;
  GlobalKey scaffoldKey ;
  dynamic jsonResponse;
  dynamic jsonResponse2;
  bool ExistAdmin=false ;
  String adminID;
  var myId;
  int limit_letters = 0;
  int top_message_num = 0;
  int refresh_location_time_interval = 3;

  PublicChatController()  {
    scaffoldKey = new GlobalKey();
    getUserInfo();
  }

  getUserInfo() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      myId = sharedPreferences.getString('_id');
    });
  }
  void init() async{

    final sharedPreferences = await SharedPreferences.getInstance();

    final id = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');

    try{
      String response= await settingRepository.initSettings(id, token);

      jsonResponse2 = json.decode(response);
      setState((){

       ExistAdmin=jsonResponse2['data']['isExistAdmin'];
        adminID=jsonResponse2['data']['chatAdminId'].toString();
       if (ExistAdmin) {
         createadminroom(adminID);
       }
      });

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
  void getSettings() async{
    final sharedPreferences = await SharedPreferences.getInstance();

    final id = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');

    try{
      String response= await settingRepository.getSettingsForChat(id, token);
         log("setinggggg");
         log(response);

      if(json.decode(response)['error'] == false) {
        var limit_letter_number = json.decode(response)['data']['message_limit_character_num'];
        var top_count = json.decode(response)['data']['top_message_num'];
        var refreshtime = json.decode(response)['data']['refresh_location_time_interval'];

        sharedPreferences.setInt('limit_letter_number', int.parse(limit_letter_number));
        setState(() {
          limit_letters = int.parse(limit_letter_number);
          top_message_num = int.parse(top_count);
          refresh_location_time_interval=int.parse(refreshtime);

        }) ;
      }
    }catch(err){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("error").tr(),
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



  getAllMessages() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');
    final userId = sharedPreferences.getString('_id');
    String response= await repository.fetchAll(token, userId);
    return json.decode(response);
  }
  void createadminroom( String messageID) async{
    final sharedPreferences = await SharedPreferences.getInstance();

    final userID = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');
    String response= await privateRepository.createRoom(userID, token, messageID);
    final jsonResponse = json.decode(response);

  }
  getTopChats() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');
    final userId = sharedPreferences.getString('_id');
    final roomId = "61946f1e3e9419cb1103ed1a";
    String response= await repository.topChat(token, userId, roomId);

    return json.decode(response);
  }

  Future<void> topItUp(String messageId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');
    final userId = sharedPreferences.getString('_id');
    String response= await repository.setTopItUp(token,messageId, userId);
    if(response == "success") {
      Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 1, heroTag: "0"));
    }
  }

  Future<void> cancelTopMessage(String messageId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');
    final userId = sharedPreferences.getString('_id');
    String response= await repository.cancelTopUp(token,messageId, userId);
    if(response == "success") {
      Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 1, heroTag: "0"));
    }
  }
  Future<void> cancelTopMessage2(String messageId,String addto) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');
    final userId = sharedPreferences.getString('_id');
    String response= await repository.cancelTopUp(token,messageId, userId);
    if(response == "success") {
      topItUp(addto);
    }
  }

  void setLike(var userId) async{
    final sharedPreferences = await SharedPreferences.getInstance();

    final posterID = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');
    String response= await privateRepository.setLikePost(posterID, token, userId);
    final jsonResponse = json.decode(response);

    if(jsonResponse['error'] == false) {
      Fluttertoast.showToast(msg:'votelike'.tr());
    }
  }
  void deletemessage(var id) async{
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');

    String response= await repository.deleteit(token,id);
    final jsonResponse = json.decode(response);

    if(jsonResponse['error'] == false) {
      Fluttertoast.showToast(msg: 'deleted successfully');
    }
  }
  void setDislike(var userId) async{
    final sharedPreferences = await SharedPreferences.getInstance();

    final posterID = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');
    String response= await privateRepository.setDislikePost(posterID, token, userId);
    final jsonResponse = json.decode(response);

    if(jsonResponse['error'] == false) {
      Fluttertoast.showToast(msg: 'votedislike'.tr());
    }
  }
  // void createRoom( String messageID) async{
  //   final sharedPreferences = await SharedPreferences.getInstance();
  //
  //   final userID = sharedPreferences.getString('_id');
  //   final token = sharedPreferences.getString('access_token');
  //   String response= await privateRepository.createRoom(userID, token, messageID);
  //   final jsonResponse = json.decode(response);
  //   log("response + ${jsonResponse}");
  //   if(jsonResponse['error'] == false) {
  //     // Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: "0"));
  //     final sharedPreferences = await SharedPreferences.getInstance();
  //     final meId = sharedPreferences.getString('_id');
  //     log("response + ${jsonResponse['data']['users'][1]}");
  //     // Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: _con.rooms[i]['_id'].toString()));
  //     // Navigator.of(context).pushNamed('/ChatScreen', arguments:
  //     // RouteArgument(subData: jsonResponse['data']['_id'],
  //     //     heroTag: jsonResponse['data']['users'][1], id: meId.toString(),
  //     //     param: {"distance": double.parse(_con.rooms[i]['friend']["distance"]).
  //     //     toStringAsFixed(0).toString()+ _con.rooms[i]['friend']["distance_unit"],
  //     //       "credit": _con.rooms[i]['friend']["credit"] } ) );
  //     //
  //
  //   }
  // }
  void createRoom( String messageID,String fcredit,String fdistance,String fdistanceunit) async{
    final sharedPreferences = await SharedPreferences.getInstance();

    final userID = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');
    String response= await privateRepository.createRoom(userID, token, messageID);
    final jsonResponse = json.decode(response);
    log("response + ${jsonResponse}");
    if(jsonResponse['error'] == false) {
      // Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: "0"));
      final sharedPreferences = await SharedPreferences.getInstance();
      final meId = sharedPreferences.getString('_id');
      log("response + ${jsonResponse['data']['users'][1]}");
      // Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: _con.rooms[i]['_id'].toString()));
      Navigator.of(context).pushNamed('/ChatScreen', arguments:
      RouteArgument(subData: jsonResponse['data']['_id'],
          heroTag: jsonResponse['data']['users'][1], id: meId.toString(),
          param: {"distance": double.parse(fdistance).
          toStringAsFixed(0).toString()+ fdistanceunit,
            "credit": fcredit} ) );


    }
  }


}
