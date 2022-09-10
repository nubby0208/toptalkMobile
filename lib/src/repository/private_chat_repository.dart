import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
// import '../helpers/maps_util.dart';
import '../models/setting.dart';
import '../utils/constants.dart';

ValueNotifier<Setting> setting = new ValueNotifier(new Setting());
final navigatorKey = GlobalKey<NavigatorState>();

Future<String> sendnotification(String msg,String title,String tokeen) async {
  var responseData;
  final String url = "https://localtalk.mobi/communicator/api/notifications/push";
  final client = new http.Client();


  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({"pushData":{
      "message" :msg,
      "title" :title,
      "deviceToken" :tokeen
    }}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> deleteit(String token, messageId) async {
  var responseData;
log(token);
  final String url = "https://localtalk.mobi/communicator/api/v1/message/deleteMessageEveryone";
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body:{"id": messageId},
  );
  print(response.body.toString());
  if (response.statusCode == 200) {
    responseData = "success";
  } else {
    responseData = "failed";
    throw new Exception(response.body);
  }
  return responseData;
}
Future<String> uodatecount(String cid, String count,String token) async {
  var responseData;
  log(token);
  final String url = "https://localtalk.mobi/communicator/api/v1/conversions/updateChatCount";
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body:{"chat_id":cid,"unread_count":"0"},
  );
  print(response.body.toString());
  if (response.statusCode == 200) {
    responseData = "success";
  } else {
    responseData = "failed";
    throw new Exception(response.body);
  }
  return responseData;
}
Future<String> fetchAll(String token, String roomId) async {
  var responseData;
  final String url = "v1/message/fetch_all" ;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"chat_id": roomId, "page": 1}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> getUsers(String id, String token) async {
  var responseData;
  final String url = "v1/user/getLocalUsers/" + id ;
  final client = new http.Client();
  final response = await client.get(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
  );
  log(response.body);
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> getRooms(String id, String token) async {
  var responseData;
  final String url = "v1/conversions/getUserChats" ;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"user_id": id}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> createRoom(String id, String token, String two) async {
  var responseData;
  final String url = "v1/conversions/create";
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"user_one": id, "user_two": two, "lastMessage": 'Hi, there'}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> removeRoom(String roomId, String token) async {
  var responseData;
  final String url = "v1/conversions/remove";
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"chat_id": roomId}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> fetchPrivateChatAll(String token, roomId) async {
  var responseData;
  final String url = "v1/message/fetch_all" ;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"chat_id": roomId, "page": 1}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> getUser(String token, userId) async {
  var responseData;
  final String url = "v1/user/get/" + userId ;
  final client = new http.Client();
  log(Constants.SERVER_URL + url);
  log(token);
  final response = await client.get(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
  );
  print("me information");
  print(response.body.toString());
  if (response.statusCode == 200) {
     responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> setLikePost(String posterId, String token, String userId) async {
  var responseData;
  final String url = "v1/user/setLike/" + userId + "/" + posterId;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"location": "125.24215, 34.123512"}),
  );
  print(response.body.toString());
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> setDislikePost(String posterId, String token, String userId) async {
  var responseData;
  final String url = "v1/user/setDislike/" + userId + "/" + posterId;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"location": "125.24215, 34.123512"}),
  );
  print(response.body.toString());
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
   throw new Exception(response.body);
  }
  return responseData;
}
