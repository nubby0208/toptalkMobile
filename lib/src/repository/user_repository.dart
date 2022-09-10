import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../utils/constants.dart';

ValueNotifier<User> currentUser = new ValueNotifier(User());

Future<String> sendPhoneNumber(phoneNumber) async {
  var responseData;
  final String url = "";
  final client = new http.Client();
  final response = await client.post(
    Uri(),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({"phone_number": phoneNumber}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> userLogin(number, password) async {
  var responseData;
  final String url = "v1/auth/login";
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    // Uri.parse("https://localtalk.mobi/communicator/api/v1/auth/loginV2"),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({"number": number, "password": password}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> userLogOut(token) async {
  var responseData;
  final String url = "v1/auth/logout";
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> userRegister(number, password, name, gender,devicetokken) async {

  String deviceId = await _getId();

  log("$number/ $password /$name /$gender /$devicetokken");
  var responseData;
  final String url = "v1/auth/register";
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    // Uri.parse("https://localtalk.mobi/communicator/api/v1/auth/register"),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      'utoken' :deviceId

    },
    body: json.encode({"number": number,"email":number, "password": password, "name": name, 'gender': gender,'deviceToken':devicetokken}),
  );
  log(json.encode({"number": number,"email":number, "password": password, "name": name, 'gender': gender,'deviceToken':devicetokken}));
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    if(response.statusCode == 401) {
      responseData = response.body;
      return responseData;
    }
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> sendEmail(email) async {
  var responseData;
    final String url = "v1/auth/retrieve-pwd-mail-send";
  final client = new http.Client();

  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({"email": email}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}
Future<String> updatetokken(String userid,String devicetokken,String token) async {
  log(token);
  var responseData;
  final String url = "v1/user/updateDeviceToken";
  final client = new http.Client();

  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({
      "id" :userid ,
      "deviceToken": devicetokken
    }),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}
Future<String> sendRegisterEmail(email) async {
  var responseData;
  final String url = "v1/auth/register-mail-send";
  final client = new http.Client();

  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({"email": email}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}


Future<String> reset_password(user_id, pwd) async {
  var responseData;
  final String url = "v1/auth/reset-password/" + user_id;
  final client = new http.Client();

  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({"new_password": pwd}),
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> _getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) { // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId; // unique ID on Android
  }
}
Future<String> getnumbers(int index) async {
  String deviceId = await _getId();

  var responseData;
  final String url = "v1/numbers";
  final client = new http.Client();
  var bodydata=
  {
  "limit":8, "startIndex":index
  };
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    // Uri.parse("https://localtalk.mobi/communicator/api/v1/numbers"),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      'utoken':deviceId
    },
    body: json.encode(bodydata),
  );

  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}
Future<String> updateLocation(String token, userID, location) async {
  var responseData;
  final String url = "v1/user/setLocation/" + userID ;
  final client = new http.Client();
  final response = await client.post(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.AUTHORIZATION: 'Bearer ' + token
    },
    body: json.encode({"location": location}),
  );
  log(Constants.SERVER_URL + url);
  log(location);
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> getPrivacyPolicyRepo() async {
  var responseData;
  final String url = "v1/pages/privacy-policy";
  final client = new http.Client();
  final response = await client.get(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}

Future<String> getUserAgreementRepo() async {
  var responseData;
  final String url = "v1/pages/user-agreement";
  final client = new http.Client();
  final response = await client.get(
    Uri.parse(Constants.SERVER_URL + url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  if (response.statusCode == 200) {
    responseData = response.body;
  } else {
    throw new Exception(response.body);
  }
  return responseData;
}