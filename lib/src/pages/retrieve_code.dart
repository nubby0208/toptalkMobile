import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/gestures.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/HexColor.dart';
import '../repository/user_repository.dart' as userRepo;
import 'retrieve_new_password.dart';
import 'package:easy_localization/src/public_ext.dart';


class RetrieveCodeWidget extends StatefulWidget {
  String email;
  int code;
  String user_id;

  RetrieveCodeWidget(this.email, this.code, this.user_id);
  @override
  _RetrieveCodeWidgetState createState() => _RetrieveCodeWidgetState();
}

class _RetrieveCodeWidgetState extends StateMVC<RetrieveCodeWidget> {
  UserController _con;
  TextEditingController codeController = TextEditingController();
  _RetrieveCodeWidgetState() : super(UserController()) {
    _con = controller;
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context)
  {

    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
          backgroundColor: Color(0xffE9DFF8),
        key: _con.scaffoldKey,
        // resizeToAvoidBottomPadding: false,
        body:  Stack(
          children: [
            headBox(),
            mainContent()
          ],
        )
      ),
    );
  }

  Widget headBox()
  {
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
          Text("retrieve_password", textAlign: TextAlign.center, maxLines: 1,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)).tr(),
        ],
      ),
    );
  }
  Widget mainContent()
  {
    return Container(
      width: config.App(context).appWidth(100),
      margin: EdgeInsets.only(top: config.App(context).appWidth(23)),
      padding: EdgeInsets.symmetric(horizontal: config.App(context).appWidth(7), vertical: 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Colors.white
      ),
      child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 160,),
              TextFormField(
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                    hintText: "  " "code".tr(),
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
                controller: codeController,
              ),
              SizedBox(height: 40,),
              Text("verify", textAlign: TextAlign.center, maxLines: 1,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xff7452A8).withOpacity(0.5))).tr(),

              SizedBox(height: 100,),

              GestureDetector(
                onTap: () => {
                  if(codeController.text.trim().length != 0){
                    if(codeController.text.trim() == widget.code.toString()){
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => RetrieveNewPasswordWidget(widget.user_id)))
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('matchnot').tr(),
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
                },
                child: Container(
                  width: config.App(context).appWidth(100),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xff7452A8)
                  ),
                  child: Text("next", textAlign: TextAlign.center, maxLines: 1,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)).tr(),
                ),
              ),
              GestureDetector(
                onTap: () async => {
                  widget.code = await _con.resendMail(widget.email)
                },
                child: Container(
                  width: config.App(context).appWidth(100),
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white
                  ),
                  child: Text("resend", textAlign: TextAlign.center, maxLines: 1,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xff7452A8))).tr(),
                ),
              ),
            ],
          )
        ],
      )
    );
  }
}
