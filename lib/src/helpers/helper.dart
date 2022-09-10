import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../helpers/HexColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../generated/l10n.dart';
import '../elements/CircularLoadingWidget.dart';
import '../repository/settings_repository.dart';

class Helper {
  BuildContext context;
  DateTime currentBackPressTime;
  static Color  baseColor = HexColor("#111214");
  static Color  baseDisabledColor = HexColor("##7F7F7F");
  static Color  baseTextColor = Colors.white;
  static Color  inputColor = HexColor("#474747");
  static Color  activeTextColor = HexColor("#232323");
  static Color  inactiveTextColor = HexColor("#848484");

  Helper.of(BuildContext _context) {
    this.context = _context;
  }

  // for mapping data retrieved form json array
  static getData(Map<String, dynamic> data) {
    return data['data'] ?? [];
  }

  static int getIntData(Map<String, dynamic> data) {
    return (data['data'] as int) ?? 0;
  }

  static bool getBoolData(Map<String, dynamic> data) {
    return (data['data'] as bool) ?? false;
  }

  static getObjectData(Map<String, dynamic> data) {
    return data['data'] ?? new Map<String, dynamic>();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }


  static List<Icon> getStarsList(double rate, {double size = 18}) {
    var list = <Icon>[];
    list = List.generate(rate.floor(), (index) {
      return Icon(Icons.star, size: size, color: Color(0xFFFFB24D));
    });
    if (rate - rate.floor() > 0) {
      list.add(Icon(Icons.star_half, size: size, color: Color(0xFFFFB24D)));
    }
    list.addAll(List.generate(5 - rate.floor() - (rate - rate.floor()).ceil(), (index) {
      return Icon(Icons.star_border, size: size, color: Color(0xFFFFB24D));
    }));
    return list;
  }

  static Widget getPrice(double myPrice, BuildContext context, {TextStyle style, String zeroPlaceholder = '-'}) {
    if (style != null) {
      style = style.merge(TextStyle(fontSize: style.fontSize + 2));
    }
    try {
      if (myPrice == 0) {
        return Text('-', style: style ?? Theme.of(context).textTheme.subtitle1);
      }
      return RichText(
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
        text: setting.value?.currencyRight != null && setting.value?.currencyRight == false
            ? TextSpan(
                text: setting.value?.defaultCurrency,
                style: style == null
                    ? Theme.of(context).textTheme.subtitle1.merge(
                          TextStyle(fontWeight: FontWeight.w400, fontSize: Theme.of(context).textTheme.subtitle1.fontSize - 6),
                        )
                    : style.merge(TextStyle(fontWeight: FontWeight.w400, fontSize: style.fontSize - 6)),
                children: <TextSpan>[
                  TextSpan(text: myPrice.toStringAsFixed(setting.value?.currencyDecimalDigits) ?? '', style: style ?? Theme.of(context).textTheme.subtitle1),
                ],
              )
            : TextSpan(
                text: myPrice.toStringAsFixed(setting.value?.currencyDecimalDigits) ?? '',
                style: style ?? Theme.of(context).textTheme.subtitle1,
                children: <TextSpan>[
                  TextSpan(
                    text: setting.value?.defaultCurrency,
                    style: style == null
                        ? Theme.of(context).textTheme.subtitle1.merge(
                              TextStyle(fontWeight: FontWeight.w400, fontSize: Theme.of(context).textTheme.subtitle1.fontSize - 6),
                            )
                        : style.merge(TextStyle(fontWeight: FontWeight.w400, fontSize: style.fontSize - 6)),
                  ),
                ],
              ),
      );
    } catch (e) {
      return Text('');
    }
  }


  static String getDistance(double distance, String unit) {
    String _unit = setting.value.distanceUnit;
    if (_unit == 'km') {
      distance *= 1.60934;
    }
    return distance != null ? distance.toStringAsFixed(2) + " " + unit : "";
  }
  

  static OverlayEntry overlayLoader(context) {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: Theme.of(context).primaryColor,
          child: CircularLoadingWidget(height: 200),
        ),
      );
    });
    return loader;
  }

  static hideLoader(OverlayEntry loader) {
    Timer(Duration(milliseconds: 500), () {
      try {
        loader?.remove();
      } catch (e) {}
    });
  }

  static String limitString(String text, {int limit = 24, String hiddenText = "..."}) {
    return text.substring(0, min<int>(limit, text.length)) + (text.length > limit ? hiddenText : '');
  }

  static String getCreditCardNumber(String number) {
    String result = '';
    if (number != null && number.isNotEmpty && number.length == 16) {
      result = number.substring(0, 4);
      result += ' ' + number.substring(4, 8);
      result += ' ' + number.substring(8, 12);
      result += ' ' + number.substring(12, 16);
    }
    return result;
  }

  static Uri getUri(String path) {
    // String _path = Uri.parse(GlobalConfiguration().getValue('base_url')).path;
    // if (!_path.endsWith('/')) {
    //   _path += '/';
    // }
    // Uri uri = Uri(
    //     scheme: Uri.parse(GlobalConfiguration().getValue('base_url')).scheme,
    //     host: Uri.parse(GlobalConfiguration().getValue('base_url')).host,
    //     port: Uri.parse(GlobalConfiguration().getValue('base_url')).port,
    //     path: _path + path);
    Uri uri = Uri();
    return uri;
  }

  Color getColorFromHex(String hex) {
    if (hex.contains('#')) {
      return Color(int.parse(hex.replaceAll("#", "0xFF")));
    } else {
      return Color(int.parse("0xFF" + hex));
    }
  }

  static BoxFit getBoxFit(String boxFit) {
    switch (boxFit) {
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'fit_height':
        return BoxFit.fitHeight;
      case 'fit_width':
        return BoxFit.fitWidth;
      case 'none':
        return BoxFit.none;
      case 'scale_down':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  static AlignmentDirectional getAlignmentDirectional(String alignmentDirectional) {
    switch (alignmentDirectional) {
      case 'top_start':
        return AlignmentDirectional.topStart;
      case 'top_center':
        return AlignmentDirectional.topCenter;
      case 'top_end':
        return AlignmentDirectional.topEnd;
      case 'center_start':
        return AlignmentDirectional.centerStart;
      case 'center':
        return AlignmentDirectional.topCenter;
      case 'center_end':
        return AlignmentDirectional.centerEnd;
      case 'bottom_start':
        return AlignmentDirectional.bottomStart;
      case 'bottom_center':
        return AlignmentDirectional.bottomCenter;
      case 'bottom_end':
        return AlignmentDirectional.bottomEnd;
      default:
        return AlignmentDirectional.bottomEnd;
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      // Fluttertoast.showToast(msg: S.of(context).tapAgainToLeave);
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }

  String trans(String text) {
    switch (text) {
      case "App\\Notifications\\StatusChangedOrder":
        return S.of(context).user;
      case "App\\Notifications\\NewOrder":
        return S.of(context).user;
      case "km":
        return S.of(context).user;
      case "mi":
        return S.of(context).user;
      default:
        return "";
    }
  }
}
