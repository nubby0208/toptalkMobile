import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/l10n.dart';
import 'route_generator.dart';
import 'src/models/setting.dart';
import 'src/repository/settings_repository.dart' as settingRepo;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  runApp( EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CH'),
      ],
      path: 'assets/translation', // <-- change the path of the translation files
      fallbackLocale: const Locale('en', 'US'),
      child: MyApp()));
}
Future<void> backgroundhandler(RemoteMessage message) async
{
  log(message.data.toString());
  log(message.notification.title);

}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();
FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((event) {
log(event.notification.title);
    });
    FirebaseMessaging.instance.getToken().then((value) {
      String token = value;

      log("------token"+token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: settingRepo.setting,
        builder: (context, Setting _setting, _) {
          return  MaterialApp(
              navigatorKey: settingRepo.navigatorKey,
              initialRoute: '/Splash',
              onGenerateRoute: RouteGenerator.generateRoute,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
          );
        });
  }
}
//