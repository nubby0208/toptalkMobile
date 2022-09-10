import 'dart:async';
import 'dart:convert';
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

Future<String> fetchAll(String token, userId) async {
  var responseData;
  final String url = "v1/roomMessages/fetchAll" ;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"room_id": "61946f1e3e9419cb1103ed1a", "user_id": userId, "page": 1}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> topChat(String token, userId, roomId) async {
  var responseData;
  final String url = "v1/roomMessages/fetchTop/" +  userId;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"room_id": roomId}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> setTopItUp(String token, messageId, userID) async {
  print(messageId);
  var responseData;
  final String url = "v1/roomMessages/setTopMsg/" +  messageId.toString()  + "/" + userID.toString();
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"room_id": "61946f1e3e9419cb1103ed1a"}),
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

Future<String> cancelTopUp(String token, messageId, userID) async {
  var responseData;
  final String url = "v1/roomMessages/cancelTopMsg/" +  messageId.toString()  + "/" + userID.toString();
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"room_id": "61946f1e3e9419cb1103ed1a"}),
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

Future<String> deleteit(String token, messageId) async {
  var responseData;
  final String url = "https://localtalk.mobi/communicator/api/v1/roomMessages/delete";
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"id": messageId}),
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
