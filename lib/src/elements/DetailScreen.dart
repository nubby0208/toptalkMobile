import 'dart:async';
import 'package:easy_localization/src/public_ext.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';

class DetailScreen extends StatefulWidget {
  final String url;

  DetailScreen({Key key, @required this.url})
      : assert(url != null),
        super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Timer _timer;

  @override
  initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Stack(
          children: [

            Container(
              width:MediaQuery.of(context).size.width,
              height:MediaQuery.of(context).size.height,
              child :PhotoView(
               imageProvider: NetworkImage(widget.url),

              ),

            ),
            Positioned(
             left:50,right:50,
              bottom:20,
              child:GestureDetector(
              onTap: () {
                GallerySaver.saveImage(widget.url).then((bool success) {
                  setState(() {
                    showDialog(
                        context: context,
                        builder: (BuildContext builderContext) {
                          _timer = Timer(Duration(seconds: 2), () {
                            Navigator.of(context).pop();
                          });

                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: Center(child: Text('photosaved'.tr())),

                          );
                        }
                    ).then((val){
                      if (_timer.isActive) {
                        _timer.cancel();
                      }
                    });
                  });
                });
              },
              child: Container(
                width:100,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xff7452A8)),
                child: Text("save".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)).tr(),
              ),
            ),)

          ],
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}