import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:locals/src/models/setting.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/gestures.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/HexColor.dart';
import 'package:easy_localization/src/public_ext.dart';
import '../repository/user_repository.dart' as userRepo;
import '../repository/settings_repository.dart' as settingRepo;
class SignInWidget extends StatefulWidget {
  @override
  _SignInWidgetState createState() => _SignInWidgetState();
}

class _SignInWidgetState extends StateMVC<SignInWidget> {
  UserController _con;

  _SignInWidgetState() : super(UserController()) {
    _con = controller;
  }

  List<bool> isSelected = [];

  @override
  void initState() {
    isSelected = [true, false];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: Helper
            .of(context).onWillPop,
        child: Scaffold(
            backgroundColor: Color(0xffE9DFF8),
            key: _con.scaffoldKey,
            // resizeToAvoidBottomPadding: false,
            body: Stack(
              children: [
                headBox(),
                mainContent(),
              ],
            )
        ),
      ),

    );
  }

  Widget headBox() {
    return Padding(
      padding: EdgeInsets.only(top: config.App(context).appWidth(12),
          left: config.App(context).appWidth(7),
          right: config.App(context).appWidth(7)),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text("sign_in", textAlign: TextAlign.center, maxLines: 1,
              style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)).tr(),


          Container(
            height: 30,
            child: ToggleButtons(
              borderColor: Colors.deepPurple,
              fillColor: Colors.deepPurple,
              borderWidth: 1,
              selectedBorderColor: Colors.deepPurple,
              selectedColor: Colors.white,
              borderRadius: BorderRadius.circular(5),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'English',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    '中文',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < isSelected.length; i++) {
                    isSelected[i] = i == index;
                  }
                  if (isSelected.first == true) {
                    context.locale = const Locale('en', 'US');
                  } else {
                    context.locale = const Locale('zh', 'CH');
                  }
                });
              },
              isSelected: isSelected,
            ),
          ),
        ],
      ),
    );
  }

  Widget progress = Container(
    padding: EdgeInsets.symmetric(vertical: 15),
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      backgroundColor: Colors.green,
      strokeWidth: 7,
    ),
  );

  Widget mainContent() {
    return Container(
        width: config.App(context).appWidth(100),
        margin: EdgeInsets.only(top: config.App(context).appWidth(23)),
        padding: EdgeInsets.symmetric(
            horizontal: config.App(context).appWidth(7), vertical: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: Colors.white
        ),
        child: MediaQuery.removePadding(context: context, removeTop: true,
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(height: 20,),
                        // Text(S.of(context).here, textAlign: TextAlign.center, maxLines: 1,
                        //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black)),
                        // Text(S.of(context).welcome_back + " !", textAlign: TextAlign.center, maxLines: 1,
                        //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black)),

                        SizedBox(height: 50,),
                        TextFormField(
                          style: TextStyle(color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                              hintText: "  " + "account".tr(),
                              hintStyle: TextStyle(color: Color(0xff959595),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                //  when the TextFormField in unfocused
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(
                                    0xff9496DE)),
                                //  when the TextFormField in focused
                              ),
                              border: UnderlineInputBorder(
                              )
                          ),
                          onChanged: (v) {
                            _con.accountnumber = v;
                          },
                          controller: _con.numberController,
                        ),
                        SizedBox(height: 40,),
                        TextFormField(
                          style: TextStyle(color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                          obscureText: _con.passwordShow,
                          controller: _con.passwordController,
                          decoration: InputDecoration(
                              suffixIcon: _con.passwordShow ? InkWell(
                                onTap: () {
                                  _con.hidePassword();
                                },
                                child: Icon(CupertinoIcons.eye, color: Color(
                                    0xff959595),),
                              ) : InkWell(onTap: () {
                                _con.showPassword();
                              },
                                child: Icon(CupertinoIcons.eye_slash,
                                  color: Color(0xff959595),),
                              ),
                              hintText: "  " + "password".tr(),
                              hintStyle: TextStyle(color: Color(0xff959595),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                //  when the TextFormField in unfocused
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(
                                    0xff9496DE)),
                                //  when the TextFormField in focused
                              ),
                              border: UnderlineInputBorder(
                              )
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 20,),
                        GestureDetector(
                          onTap:(){
                            Navigator.of(context).pushNamed('/SignUp');

                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child:  RichText(
                              text: new TextSpan(text: "dont_have_an_account".tr(),
                                  style:TextStyle(color: Color(0xff959595),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                  children: [
                                    TextSpan(text:'sign_up_now'.tr(),style:
                                    TextStyle(color:Color(0xff7452A8),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400) )
                                  ]),
                            )

                            //
                            // Row(
                            //   children: [
                            //
                            //     InkWell(
                            //       onTap: () {
                            //       },
                            //       child: Text(
                            //           "dont_have_an_account", textAlign: TextAlign.center,
                            //           maxLines: 1,
                            //           style: TextStyle(color: Color(0xff959595),
                            //               fontSize: 18,
                            //               fontWeight: FontWeight.w400)).tr(),
                            //     )
                            //   ],
                            // ),
                          ),
                        ),
                        // SizedBox(height: 20,),
                        // Padding(
                        //   padding: EdgeInsets.symmetric(horizontal: 10),
                        //   child: Row(
                        //     children: [
                        //       Text("forgot_password", textAlign: TextAlign
                        //           .center, maxLines: 1,
                        //           style: TextStyle(fontSize: 12,
                        //               fontWeight: FontWeight.w400,
                        //               color: Color(0xff909090))).tr(),
                        //       SizedBox(width: 10,),
                        //       InkWell(
                        //         onTap: () {
                        //           Navigator.of(context).pushNamed(
                        //               '/RetrievePassword');
                        //         },
                        //         child: Text("retrieve_password",
                        //             textAlign: TextAlign.center, maxLines: 1,
                        //             style: TextStyle(fontSize: 12,
                        //                 fontWeight: FontWeight.w400,
                        //                 color: Color(0xff9496DE))).tr(),
                        //       )
                        //     ],
                        //   ),
                        // ),
                        SizedBox(height: 70,),
                        GestureDetector(
                          onTap:(){
                            Navigator.of(context).pushNamed('/UserAgreement');

                          },
                          child: Container(
                            width: config.App(context).appWidth(63),
                            child: RichText(
                              text: new TextSpan(text: "sign_in_description".tr(),
                                  style: TextStyle( color: Color(0xff909090) , fontSize: 12, fontWeight: FontWeight.w400),
                                  children: [
                                  TextSpan(text:'user_agreement'.tr(),style:
                                  TextStyle( color: Color(0xff7452A8) , fontSize: 12, fontWeight: FontWeight.w400) )
                                  ]),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        _con.loading ? progress : GestureDetector(
                          onTap: () =>
                          {

                            if(_con.accountnumber != '' &&
                                _con.passwordController.text.length != 0)
                              {
                                _con.login()
                              }
                            else
                              {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("credential").tr(),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('close').tr())
                                        ],
                                      );
                                    })
                              }
                          },
                          child: Container(
                            width: config.App(context).appWidth(32),
                            padding: EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xff7452A8)
                            ),
                            child: Text("sign_in", textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)).tr(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 70,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(S.of(context).enter_chatroom_as, textAlign: TextAlign.center, maxLines: 1,
                        //     style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: Color(0xff7452A8))),
                        // SizedBox(height: 50,),
                        // Row(
                        //   children: [
                        //     Container(
                        //       width: config.App(context).appWidth(8),
                        //       height: config.App(context).appWidth(8),
                        //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        //       decoration: BoxDecoration(
                        //           color: Color(0xffEEEFFF),
                        //           shape: BoxShape.circle
                        //       ),
                        //       child: Center(
                        //         child: Image.asset('assets/img/facebook_icon.png', fit: BoxFit.fitWidth,),
                        //       ),
                        //     ),
                        //     SizedBox(width: 30,),
                        //     Container(
                        //       width: config.App(context).appWidth(8),
                        //       height: config.App(context).appWidth(8),
                        //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        //       decoration: BoxDecoration(
                        //           color: Color(0xffEEEFFF),
                        //           shape: BoxShape.circle
                        //       ),
                        //       child: Center(
                        //         child: Image.asset('assets/img/instagram_icon.png', fit: BoxFit.fitWidth,),
                        //       ),
                        //     ),
                        //     SizedBox(width: 30,),
                        //     Container(
                        //       width: config.App(context).appWidth(8),
                        //       height: config.App(context).appWidth(8),
                        //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        //       decoration: BoxDecoration(
                        //           color: Color(0xffEEEFFF),
                        //           shape: BoxShape.circle
                        //       ),
                        //       child: Center(
                        //         child: Image.asset('assets/img/twiter_icon.png', fit: BoxFit.fitWidth,),
                        //       ),
                        //     ),
                        //     SizedBox(width: 30,),
                        //     Container(
                        //       width: config.App(context).appWidth(8),
                        //       height: config.App(context).appWidth(8),
                        //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        //       decoration: BoxDecoration(
                        //           color: Color(0xffEEEFFF),
                        //           shape: BoxShape.circle
                        //       ),
                        //       child: Center(
                        //         child: Image.asset('assets/img/p_icon.png', fit: BoxFit.fitWidth,),
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Expanded(child: Container(
                        //       padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        //       decoration: BoxDecoration(
                        //           border: Border.all(
                        //               color: Color(0xff9496DE), width: 2
                        //           ),
                        //           borderRadius: BorderRadius.circular(10)
                        //       ),
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Text(S.of(context).visitor, textAlign: TextAlign.center, maxLines: 1,
                        //               style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xff9496DE))),
                        //           SizedBox(width: 10,),
                        //           Image.asset('assets/img/male.png' , height: 24, fit: BoxFit.fitHeight,)
                        //         ],
                        //       ),
                        //     ),),
                        //     SizedBox(width:  20,),
                        //     Expanded(child: Container(
                        //       padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        //       decoration: BoxDecoration(
                        //           border: Border.all(
                        //               color: Color(0xff9496DE), width: 2
                        //           ),
                        //           borderRadius: BorderRadius.circular(10)
                        //       ),
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Text(S.of(context).visitor, textAlign: TextAlign.center, maxLines: 1,
                        //               style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xff9496DE))),
                        //           SizedBox(width: 10,),
                        //           Image.asset('assets/img/woman.png' , height: 24, fit: BoxFit.fitHeight,)
                        //         ],
                        //       ),
                        //     ))
                        //   ],
                        // ),
                        SizedBox(height: 60,),
                      ],
                    )


                  ],
                ),
              ],
            )
        )
    );
  }
}
/*
* valueListenable: settingRepo.setting,
          builder: (context, Setting _setting, _) {
            return MaterialApp(
              locale: _setting.mobileLanguage.value,
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,*/