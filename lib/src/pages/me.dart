import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as pathh;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:locals/src/controllers/setting_controller.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:locals/src/pages/change_password.dart';
import 'package:locals/src/pages/change_nickname.dart';
import 'package:locals/src/pages/change_gender.dart';
import 'package:locals/src/pages/settings.dart';
import 'package:locals/src/utils/constants.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/gestures.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/HexColor.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/src/public_ext.dart';


class MeWidget extends StatefulWidget {
  @override
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  MeWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _MeWidgetState createState() => _MeWidgetState();
}

class _MeWidgetState extends StateMVC<MeWidget> {
  SettingController _con;
  final ImagePicker _picker = ImagePicker();

  _MeWidgetState() : super(SettingController()) {
    _con = controller;
  }

  Future<void> ChangeImage(PickedFile file) async {

    File compressedfile =await testCompressAndGetFile(file.path);
    String fileName = compressedfile.path
        .split('/')
        .last;
    FormData data = FormData.fromMap({
      "img": await MultipartFile.fromFile(
        compressedfile.path,
        filename: fileName,
      ),
    });

    Dio dio = new Dio();

    dio.post(Constants.SERVER_URL + 'v1/user/img/' + _con.jsonResponse['data']['_id'], data: data,
      options: Options(
        headers: {
          HttpHeaders.AUTHORIZATION: 'Bearer ' +  _con.jsonResponse['data']['token']// set content-length
        },
      ),)
        .then((response) {
      var result = jsonDecode(response.toString());
      if (result['error'] == false) {
        print('data');
        print(result['data']);
        setState(() {
          _con.jsonResponse['data']['avatarUrl'] = result['data'];
        });
      }
    })
        .catchError((error) => print(error));
  }

  @override
  void initState() {
    super.initState();
    _con.init();
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
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
          backgroundColor: Color(0xffE9DFF8),
        key: _con.scaffoldKey,
        // resizeToAvoidBottomPadding: false,
        body:  Stack(
          children: [
            headBox(),
            _con.loading ? progress: mainContent()
          ],
        )
      ),
    );
  }

  Widget headBox() {
    return Padding(
      padding: EdgeInsets.only(top: config.App(context).appWidth(12), left: config.App(context).appWidth(7)),
      child: Row(
        children: [
          // Icon(Icons.arrow_back_ios_rounded, size: 24, color: Colors.black,),
          // SizedBox(width: 50,),
          Text("my_account", textAlign: TextAlign.center, maxLines: 1,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
        ],
      ),
    );
  }
  Future<File> testCompressAndGetFile(String path) async {

    String extension=path.toString().split('.').last;
    String fileName = path.split('/').last;
    log(pathh.basenameWithoutExtension(fileName));

    String dir = pathh.dirname(path); //get directory
    String targetfile=dir+"/"+pathh.basenameWithoutExtension(fileName)+"."+"min"+"."+extension;

    var result = await FlutterImageCompress.compressAndGetFile(path,targetfile,
      quality: 58,

    );
    return result;
  }

  Widget mainContent() {
    return Container(
      width: config.App(context).appWidth(100),
      margin: EdgeInsets.only(top: config.App(context).appWidth(23)),
      padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(7), vertical: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Colors.white
      ),
      child: MediaQuery.removePadding(context: context,
          removeTop: true,
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  Stack(
                    children: [
                      Container(
                        width: config.App(context).appWidth(32),
                        height: config.App(context).appWidth(32),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xffC4C4C4).withOpacity(0.55),
                          image: DecorationImage(
                            image: Image.network(Constants.SERVER_URL+ "v1/user/img-src/" + _con.jsonResponse['data']['avatarUrl']).image,
                            fit: BoxFit.cover,
                          )
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: config.App(context).appWidth(24), top: config.App(context).appWidth(24)),
                          child: InkWell(
                            onTap: (){
                              showDialog(context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Container(
                                        height: 140,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                PickedFile image = await _picker.getImage(
                                                    source: ImageSource.camera
                                                );
                                                if (image != null)
                                                  ChangeImage(
                                                      image);

                                                Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                height:50,
                                                width:50,
                                                decoration:BoxDecoration(
                                                  color:Color(0xff9496DE) ,
                                                  borderRadius:BorderRadius.circular(5)
                                          ,border: Border.all(color: Color(0xff9496DE),width:2)),

                                                child: Icon(Icons.camera_alt,color:Colors.white,size:30),
                                            )),
                                            SizedBox(width:20,),
                                            GestureDetector(
                                                onTap: () async {
                                                  PickedFile image = await _picker
                                                      .getImage(
                                                      source: ImageSource.gallery
                                                  );
                                                  if (image != null) ChangeImage(
                                                      image);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  height:50,
                                                  width:50,
                                                  decoration:BoxDecoration(
                                                      color:Color(0xff9496DE) ,
                                                      borderRadius:BorderRadius.circular(5)
                                                      ,border: Border.all(color: Color(0xff9496DE),width:2)),

                                                  child: Icon(Icons.photo,color:Colors.white,size:30,),
                                                )),


                                          ],
                                        ),
                                      ),

                                    );
                                  }
                              );
                            },
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Color(0xff9496DE)
                              ),
                              child: Icon(Icons.camera_enhance_rounded, size: 16, color: Colors.white,),
                            ),
                          )
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_con.jsonResponse['data']['name'],
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                      Image.asset(_con.jsonResponse['data']['gender'] == 0 ? 'assets/img/man.png': (_con.jsonResponse['data']['gender'] == 1? 'assets/img/woman.png': 'assets/img/shop_icon.png'), height: 30, fit: BoxFit.fitHeight,)
                    ],
                  ),
                  SizedBox(height: 20,),
                  Text(_con.jsonResponse['data']['email'].toUpperCase(),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black)),
                  SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.hand_thumbsup_fill, color: Color(0xff9496DE),size: 20,),
                      SizedBox(width: 10,),
                      Container(
                        height: 20, width: 1, color: Color(0xffE3E3E3),
                      ),
                      SizedBox(width: 10,),
                      Text(_con.jsonResponse['data']['like'].toString(),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                      SizedBox(width: 30,),
                      Icon(CupertinoIcons.hand_thumbsdown, color: Color(0xffD7443E),size: 20,),
                      SizedBox(width: 10,),
                      Container(
                        height: 20, width: 1, color: Color(0xffE3E3E3),
                      ),
                      SizedBox(width: 10,),
                      Text(_con.jsonResponse['data']['dislike'].toString(),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  // SizedBox(height: 30,),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         Container(
                  //           width: config.App(context).appWidth(7),
                  //           height: config.App(context).appWidth(7),
                  //           decoration: BoxDecoration(
                  //               shape: BoxShape.circle, color: Color(0xffE0E0F6).withOpacity(0.55)
                  //           ),
                  //           child: Center(
                  //             child: Image.asset('assets/img/language_icon.png', width: 16, fit: BoxFit.fitWidth,),
                  //           ),
                  //         ),
                  //         SizedBox(width: 20,),
                  //         Text(S.of(context).language,
                  //             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
                  //       ],
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.of(context).pushNamed('/Language');
                  //       },
                  //       child: Container(
                  //         padding: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                  //         decoration: BoxDecoration(
                  //             color: Color(0xffEAEAEA), borderRadius: BorderRadius.circular(5)
                  //         ),
                  //         child: Icon(Icons.arrow_forward_ios_rounded, size: 24, color: Color(0xff9496DE)),
                  //       ),
                  //     )
                  //   ],
                  // ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: config.App(context).appWidth(7),
                            height: config.App(context).appWidth(7),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Color(0xffE0E0F6).withOpacity(0.55)
                            ),
                            child: Center(
                              child: Image.asset('assets/img/gender_icon.png', width: 16, fit: BoxFit.fitWidth,),
                            ),
                          ),
                          SizedBox(width: 20,),
                          Text("my_gender",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
                        ],
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ChangeGenderWidget(_con.jsonResponse)));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                          decoration: BoxDecoration(
                              color: Color(0xffEAEAEA), borderRadius: BorderRadius.circular(5)
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded, size: 24, color: Color(0xff9496DE)),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: config.App(context).appWidth(7),
                            height: config.App(context).appWidth(7),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Color(0xffE0E0F6).withOpacity(0.55)
                            ),
                            child: Center(
                              child: Image.asset('assets/img/nick_icon.png', width: 16, fit: BoxFit.fitWidth,),
                            ),
                          ),
                          SizedBox(width: 20,),
                          Text("change_nickname",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
                        ],
                      ),
                     GestureDetector(
                       onTap: (){
                         Navigator.of(context).push(MaterialPageRoute(
                             builder: (_) => ChangeNickNameWidget(_con.jsonResponse)));
                       },
                       child:  Container(
                         padding: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                         decoration: BoxDecoration(
                             color: Color(0xffEAEAEA), borderRadius: BorderRadius.circular(5)
                         ),
                         child: Icon(Icons.arrow_forward_ios_rounded, size: 24, color: Color(0xff9496DE)),
                       ),
                     )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: config.App(context).appWidth(7),
                            height: config.App(context).appWidth(7),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Color(0xffE0E0F6).withOpacity(0.55)
                            ),
                            child: Center(
                              child: Image.asset('assets/img/lock_icon.png', width: 16, fit: BoxFit.fitWidth,),
                            ),
                          ),
                          SizedBox(width: 20,),
                          Text("change_password",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ChangePasswordWidget(_con.jsonResponse)));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                          decoration: BoxDecoration(
                              color: Color(0xffEAEAEA), borderRadius: BorderRadius.circular(5)
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded, size: 24, color: Color(0xff9496DE)),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: config.App(context).appWidth(7),
                            height: config.App(context).appWidth(7),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Color(0xffE0E0F6).withOpacity(0.55)
                            ),
                            child: Center(
                              child: Image.asset('assets/img/setting_icon.png', width: 16, fit: BoxFit.fitWidth,),
                            ),
                          ),
                          SizedBox(width: 20,),
                          Text("settings",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => SettingsWidget(_con.jsonResponse)));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
                          decoration: BoxDecoration(
                              color: Color(0xffEAEAEA), borderRadius: BorderRadius.circular(5)
                          ),
                          child: Icon(Icons.arrow_forward_ios_rounded, size: 24, color: Color(0xff9496DE)),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          _con.signOut();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(width: 2, color: Color(0xffFF1313))
                          ),
                          child: Row(
                            children: [
                              Image.asset('assets/img/sign_out_icon.png' , width: 26, fit: BoxFit.fitWidth,),
                              SizedBox(width: 10,),
                              Text("sign_out",
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xffFF1313))).tr(),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 40,),
                ],
              )
            ],
          ))
    );
  }
}
