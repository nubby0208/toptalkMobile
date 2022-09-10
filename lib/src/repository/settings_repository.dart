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

Future<String> initSettings(String id, String token) async {
  var responseData;
  final String url = "v1/user/get/" + id;
  final client = new http.Client();
  final response = await client.get(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> getSettingsForChat(String id, String token) async {
  var responseData;
  final String url = "v1/settings/parameter";
  final client = new http.Client();
  final response = await client.get(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
  );
  if (response.statusCode == 200) {
    responseData = response.body;

  } else {
    throw new Exception(response.body);
  }
  return responseData;
}


Future<String> changePassword(String id, String token, String oldpw, String newpw) async {
  var responseData;
  final String url = "v1/user/change_password/" + id;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"old_password": oldpw, "new_password": newpw}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    if (response.statusCode == 401) {
      responseData = response.body;
      return responseData;
    }
    throw new Exception(response.body);
  }
  return responseData;
}
Future<String> changeNickName(String id, String token, String trim) async {
  var responseData;
  final String url = "v1/user/setNickname/" + id;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"nickname": trim}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    if (response.statusCode == 401) {
      responseData = response.body;
      return responseData;
    }
    throw new Exception(response.body);
  }
  return responseData;
}
Future<String> changeGender(String id, String token, String trim) async {
  var responseData;
  final String url = "v1/user/setGender/" + id;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"gender": trim}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    if (response.statusCode == 401) {
      responseData = response.body;
      return responseData;
    }
    throw new Exception(response.body);
  }
  return responseData;
}
Future<String> setSettings(String id, String token, int coverrage, bool use_current_location_as_permanent,
    bool display_position_with_random_offset,
    bool all_new_message_alert,
    bool public_chat_room_me_alert,
    bool change_kilometers_to_miles,
    bool voice_alert,
    bool vibration_alert,
    bool do_not_disturb) async {
  var responseData;
  final String url = "v1/user/setSettings/" + id;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({
      "coverage": coverrage,
      "use_current_location_as_permanent": use_current_location_as_permanent,
      "display_position_with_random_offset": display_position_with_random_offset,
      "all_new_message_alert": all_new_message_alert,
      "public_chat_room_me_alert": public_chat_room_me_alert,
      "change_kilometers_to_miles": change_kilometers_to_miles,
      "voice_alert": voice_alert,
      "vibration_alert": vibration_alert,
      "do_not_disturb": do_not_disturb
    }),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    if (response.statusCode == 401) {
      responseData = response.body;
      return responseData;
    }
    throw new Exception(response.body);
  }
  return responseData;
}

void setBrightness(Brightness brightness) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (brightness == Brightness.dark) {
    prefs.setBool("isDark", true);
    brightness = Brightness.dark;
  } else {
    prefs.setBool("isDark", false);
    brightness = Brightness.light;
  }
}

Future<void> setDefaultLanguage(String language) async {
  if (language != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }
}

Future<String> getDefaultLanguage(String defaultLanguage) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('language')) {
    defaultLanguage = await prefs.get('language');
  }
  return defaultLanguage;
}

Future<void> saveMessageId(String messageId) async {
  if (messageId != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('google.message_id', messageId);
  }
}

Future<String> getMessageId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.get('google.message_id');
}
