import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:locals/src/models/private_message_model.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:locals/src/pages/chat_rooms.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/private_chat_repository.dart' as repository;
import 'package:easy_localization/src/public_ext.dart';

class PrivateChatController extends ControllerMVC {
  bool loading = false;
  GlobalKey scaffoldKey ;
  dynamic jsonResponse;
  List responseList = [];
  List rooms = [];
  List<PrivateMessageModel> listMessages = [];

  var email ;

  var meInfo = null;
  var partnerInfo = null;
  var myID ;
  int limit_letters = 0;

  PrivateChatController() {
    scaffoldKey = new GlobalKey();
  }

  void init() async{
    setState((){
      loading = true;
    });
    final sharedPreferences = await SharedPreferences.getInstance();

    final id = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');

    try{
      String response= await repository.getUsers(id, token);
      final jsonResponse = json.decode(response);
      log(response);
      setState((){

        responseList = jsonResponse['data'] as List;
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

  Future<void> getSettings () async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      limit_letters = sharedPreferences.getInt('limit_letter_number');
    });
  }
  void initRooms() async{
    setState((){
      loading = true;
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    final id = sharedPreferences.getString('_id');
    myID = id;
    setState(() {
      myID = id;
    });
    email = sharedPreferences.getString('email');
    final token = sharedPreferences.getString('access_token');

    try{
      String response= await repository.getRooms(id, token);
      final jsonResponse = json.decode(response);
      log("id $id : tokken $token");
      log(response);
      final data= jsonResponse['data'] as List;
      List temp=[];
      temp.addAll(data..sort((a, b)=>a['lastMessage']['updated'].
      compareTo(a['lastMessage']['updated'])));
      setState((){
      rooms=temp.reversed.toList();


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

  void createRoom(int i) async{
    final sharedPreferences = await SharedPreferences.getInstance();

    final id = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');
    String response= await repository.createRoom(id, token, responseList[i]["_id"]);
    final jsonResponse = json.decode(response);
    if(jsonResponse['error'] == false) {
      Navigator.of(context).pushNamed('/NavBar', arguments: RouteArgument(currentTab: 2, heroTag: "0"));
    }
  }
  void createRoom2( int i,String fcredit,String fdistance,String fdistanceunit) async{
    final sharedPreferences = await SharedPreferences.getInstance();

    final userID = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');
    String response= await repository.createRoom(userID, token, responseList[i]["_id"]);
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

  void removeRoom(String roomId) async{
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');
    String response= await repository.removeRoom(roomId, token);
    final jsonResponse = json.decode(response);
    if(jsonResponse['error'] == false) {
      rooms = [];
      initRooms();
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
  getPrivateAllMessages(String roomId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');
    String response= await repository.fetchAll(token, roomId);
    final responses = json.decode(response);
    log("sssssss");
    log(responses.toString());
    if (responses['error'] == false) {
      final data = responses['data'] as List;
      listMessages.addAll(data.map((e) => PrivateMessageModel.fromMap(e)).toList());
      setState(() {});
    }
  }
  void sendnotif(String msg,String title,String devtokken) async{

    String response= await repository.sendnotification(msg, title, devtokken);
    final jsonResponse = json.decode(response);
    log(jsonResponse.toString());

  }
  void updatecount(String cid,String uncount) async{
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');
    String response= await repository.uodatecount(cid, uncount, token);


  }
   getUserData(String userId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('access_token');

    String response= await repository.getUser(token, userId);

    return json.decode(response);
  }

  void setLike(var userId) async{
    final sharedPreferences = await SharedPreferences.getInstance();

    final posterID = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');
    String response= await repository.setLikePost(posterID, token, userId);
    final jsonResponse = json.decode(response);

    if(jsonResponse['error'] == false) {
      Fluttertoast.showToast(msg: 'vote like successfully');
    }
  }

  void setDislike(var userId) async{
    final sharedPreferences = await SharedPreferences.getInstance();

    final posterID = sharedPreferences.getString('_id');
    final token = sharedPreferences.getString('access_token');
    String response= await repository.setDislikePost(posterID, token, userId);
    final jsonResponse = json.decode(response);

    if(jsonResponse['error'] == false) {
      Fluttertoast.showToast(msg: 'vote dislike successfully');
    }
  }


}
