import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locals/src/models/numbermodel.dart';
import 'package:locals/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/src/public_ext.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/HexColor.dart';
import '../repository/user_repository.dart' as userRepo;



class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  UserController _con;
  bool istapped=false;
  int indexx=1;
  int tapped=-1;
  String devicetoken;
  String choosnumber="0";
  final List<numbermodel> listofnumbers = [];

  _SignUpWidgetState() : super(
      UserController()) {
      _con = controller;
  }

  @override
  void initState()
  {
    startLoadMore(indexx);
    super.initState();
    FirebaseMessaging.instance.getToken().then((value) {
      devicetoken = value;

      log("------token" + devicetoken);
    });
  }
  void startLoadMore(int indexxx) async {
    setState(() {
      listofnumbers.clear();
    });
    var jsonResponse = await _con.getallnumbers(indexxx);
    final data = jsonResponse['data'] as List;
    setState(() {
      listofnumbers.addAll(data.map((e) => numbermodel.fromMap(e)).toList());
if(listofnumbers.length>0)
  {
    _con.loading=false;
  }
    });

    }
    //
    // if(_listMessages.length > 0){
    //   setState(_refreshController.loadComplete);
    // } else {
    //   _refreshController.loadNoData();
    // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffE9DFF8),
      key: _con.scaffoldKey,
      // resizeToAvoidBottomPadding: false,
      body:  Stack(
        children: [
          headBox(),


          mainContent()
        ],
      )
    );
  }

  Widget headBox() {
    return Padding(
      padding: EdgeInsets.only(top: config.App(context).appWidth(12), left: config.App(context).appWidth(7)),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.asset('assets/img/back_icon.png', width: config.App(context).appWidth(5), fit: BoxFit.fitWidth,),
          ),
          SizedBox(width: 50,),
          Text("registration_login",
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black))
              .tr(),],
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
      padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(7), vertical: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Colors.white
      ),
      child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Row(children: <Widget>[
              //   Expanded(
              //     child: new Container(
              //         child: Divider(
              //           color: Color(0xff7452A8), thickness: 2,
              //         )),
              //   ),
              //   Container(
              //     width: config.App(context).appWidth(8),
              //     height: config.App(context).appWidth(8),
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle, color: Color(0xff7452A8)
              //     ),
              //     child: Center(
              //       child: Text(S.of(context).or, textAlign: TextAlign.center, maxLines: 1,
              //           style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
              //     ),
              //   ),
              //   Expanded(
              //     child: new Container(
              //         child: Divider(
              //           color: Color(0xff7452A8), thickness: 2,
              //         )),
              //   ),
              // ]),
              //
              // SizedBox(height: 30,),
              // TextFormField(
              //   style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
              //   decoration: InputDecoration(
              //       hintText: "  " + S.of(context).email,
              //       hintStyle: TextStyle(color: Color(0xff959595), fontSize: 18, fontWeight: FontWeight.w400),
              //       enabledBorder: UnderlineInputBorder(
              //         borderSide: BorderSide(color: Colors.grey),
              //         //  when the TextFormField in unfocused
              //       ) ,
              //       focusedBorder: UnderlineInputBorder(
              //         borderSide: BorderSide(color: Color(0xff9496DE)),
              //         //  when the TextFormField in focused
              //       ) ,
              //       border: UnderlineInputBorder(
              //       )
              //   ),
              //   controller: _con.emailController,
              //   keyboardType: TextInputType.emailAddress,
              // ),
              // SizedBox(height: 10,),
              // verificationCodeWidget(),
              Center(child: Text(
           "pick",
        style: TextStyle(
            color: Color(0xff7452A8),
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ).tr()),
              SizedBox(
                height: 20,
              ),

              GridView.builder(
                shrinkWrap:true,
                itemCount: listofnumbers.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing:10,
                    crossAxisSpacing:10,
                    childAspectRatio: 4.7,
                    crossAxisCount: 2 ),
                itemBuilder: (BuildContext context, int index) {
                  if(index==7)
                    {
                      return InkWell(
                        onTap: () {
                          indexx++;
                          startLoadMore(indexx);
log(indexx.toString());
                        },
                        child: Container(
                          height: 40,
                          width: 150,
                          decoration: BoxDecoration(color: Color(0xff7452A8),),
                          child: Center(child: Text("more", style: TextStyle(color: Colors.white, fontSize: 19),).tr()),
                        ),
                      );
                    }
                  else{
                    return  InkWell(

                      onTap: () {
                        setState(() {

                          tapped=index;
_con.assignednumber=listofnumbers[index].number;
log(_con.assignednumber.toString());
                        });

                      },
                      child: Container(
                        height: 40,
                        width: 150,
                        decoration: BoxDecoration(
                          border: Border.all(width:2,color:tapped==index ?Colors.deepPurple:Colors.transparent),
                            color:listofnumbers[index].isAssigned==false ? Colors.green.shade50:Colors.grey),
                        child: Center(child: Text("${listofnumbers[index].number}", style: TextStyle(
                            color: Color(0xff959595), fontSize: 20),)),
                      ),
                    );
                  }

                },
              ),



              SizedBox(
                height: 20,
              ),

              TextFormField(
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                obscureText: _con.passwordShow,
                decoration: InputDecoration(
                    suffixIcon: _con.passwordShow ? InkWell(
                      onTap: () {
                        _con.hidePassword();
                      },
                      child: Icon(CupertinoIcons.eye, color: Color(0xff959595),),
                    ) : InkWell(onTap: () {_con.showPassword();},
                      child: Icon(CupertinoIcons.eye_slash, color: Color(0xff959595),),
                    ),
                    hintText: "character".tr(),
                    hintStyle: TextStyle(color: Color(0xff959595), fontSize: 18, fontWeight: FontWeight.w400),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      //  when the TextFormField in unfocused
                    ) ,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff9496DE)),
                      //  when the TextFormField in focused
                    ) ,
                    border: UnderlineInputBorder(
                    )
                ),
                keyboardType: TextInputType.text,
                controller: _con.passwordController,
              ),
              // SizedBox(height: 15,),
              // TextFormField(
              //   style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
              //   decoration: InputDecoration(
              //       hintText: "  " + S.of(context).nick_name,
              //       hintStyle: TextStyle(color: Color(0xff959595), fontSize: 18, fontWeight: FontWeight.w400),
              //       enabledBorder: UnderlineInputBorder(
              //         borderSide: BorderSide(color: Colors.grey),
              //         //  when the TextFormField in unfocused
              //       ) ,
              //       focusedBorder: UnderlineInputBorder(
              //         borderSide: BorderSide(color: Color(0xff9496DE)),
              //         //  when the TextFormField in focused
              //       ) ,
              //       border: UnderlineInputBorder(
              //       )
              //   ),
              //   keyboardType: TextInputType.text,
              //   controller: _con.nameController,
              // ),

              SizedBox(height: 40,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            _con.maleCheckHandle();
                          },
                          child: Icon( _con.maleCheck ? CupertinoIcons.checkmark_square :Icons.check_box_outline_blank_rounded,
                            color: Color(0xff9496DE), size: 25,),
                        ),
                        // Icon(CupertinoIcons.checkmark_square, color: Color(0xff9496DE), size: 25,),
                        SizedBox(width: 10,),
                        Image.asset('assets/img/male.png', height: 25, fit: BoxFit.fitHeight,)
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            _con.femaleCheckHandle();
                          },
                          child: Icon( _con.femaleCheck ? CupertinoIcons.checkmark_square :Icons.check_box_outline_blank_rounded,
                            color: Color(0xff9496DE), size: 25,),
                        ),
                        // Icon(CupertinoIcons.checkmark_square, color: Color(0xff9496DE), size: 25,),
                        SizedBox(width: 10,),
                        Image.asset('assets/img/woman.png', height: 25, fit: BoxFit.fitHeight,)
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     InkWell(
                    //       onTap: () {
                    //         _con.businessCheckHandle();
                    //       },
                    //       child: Icon( _con.businessCheck ? CupertinoIcons.checkmark_square :Icons.check_box_outline_blank_rounded,
                    //         color: Color(0xff9496DE), size: 25,),
                    //     ),
                    //     // Icon(CupertinoIcons.checkmark_square, color: Color(0xff9496DE), size: 25,),
                    //     SizedBox(width: 10,),
                    //     Image.asset('assets/img/shop_icon.png', height: 25, fit: BoxFit.fitHeight,)
                    //   ],
                    // )
                  ],
                ),
              ),
              SizedBox(height: 50,),
              Text(
                "screenshot",
                style: TextStyle(
                    color: Color(0xff909090),
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ).tr(),
              SizedBox(height: 10,),
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
              SizedBox(height: 10,),

              _con.loading? progress:
              GestureDetector(
                onTap: () => {
                  if(_con.assignednumber !="0" && _con.passwordController.text.length != 0) {
                    if( _con.passwordController.text.length >= 8)
                      {
                      if(_con.femaleCheck || _con.maleCheck || _con.businessCheck){

                      _con.register(devicetoken)
                      }
                      else{
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
                      }

                    else
                      {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("failure").tr(),
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
                  }
                  else{
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
                  width: config.App(context).appWidth(100),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xff7452A8)
                  ),
                  child: Text("finish_register", textAlign: TextAlign.center, maxLines: 1,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)).tr(),
                ),
              ),
            ],
          )
        ],
      )
    );
  }

  Widget verificationCodeWidget() {
    return Container(
        width: config.App(context).appWidth(100),
        padding: EdgeInsets.symmetric( vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => {
                if(_con.emailController.text.trim().length != 0){
                  _con.sendRegisterVerification()
                }

              },
              child: Container(
                width: config.App(context).appWidth(100),
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xff7452A8)
                ),
                child: Text("Verify Email Address", textAlign: TextAlign.center, maxLines: 1,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            SizedBox(height: 10,),
            Text("You will receive an email containing the verification code.",
                textAlign: TextAlign.left, maxLines: 3,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87.withOpacity(0.5))),
            SizedBox(height: 10,),
            TextFormField(
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                  hintText: "  " + S.of(context).verification_code,
                  hintStyle: TextStyle(color: Color(0xff959595), fontSize: 18, fontWeight: FontWeight.w400),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    //  when the TextFormField in unfocused
                  ) ,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff9496DE)),
                    //  when the TextFormField in focused
                  ) ,
                  border: UnderlineInputBorder(
                  )
              ),
              keyboardType: TextInputType.text,
              controller: _con.verificationCodeController,
            ),
            SizedBox(height: 10,),
          ],
        )
    );
  }
}
