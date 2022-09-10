import 'package:flutter/material.dart';
import 'package:locals/src/pages/change_password.dart';
import 'package:locals/src/pages/chat_rooms.dart';
import 'package:locals/src/pages/chat_screen.dart';
import 'package:locals/src/pages/language.dart';
import 'package:locals/src/pages/local_users.dart';
import 'package:locals/src/pages/nav_bar.dart';
import 'package:locals/src/pages/retrieve_password.dart';
import 'package:locals/src/pages/settings.dart';
import 'package:locals/src/pages/sign_in.dart';
import 'package:locals/src/pages/sign_up.dart';
import 'package:locals/src/pages/splash.dart';
import 'package:locals/src/pages/user_agreement.dart';

import 'src/models/route_argument.dart';
import 'src/pages/login.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case '/Splash':
        return MaterialPageRoute(builder: (_) => SplashWidget());
      case '/Login':
        return MaterialPageRoute(builder: (_) => LoginWidget());
      case '/SignIn':
        return MaterialPageRoute(builder: (_) => SignInWidget());
      case '/UserAgreement':
        return MaterialPageRoute(builder: (_) => UserAgreementWidget());
      case '/SignUp':
        return MaterialPageRoute(builder: (_) => SignUpWidget());
      case '/RetrievePassword':
        return MaterialPageRoute(builder: (_) => RetrievePasswordWidget());
      case '/NavBar':
        return MaterialPageRoute(builder: (_) => NavBarWidget( currentTab : args));
      case '/Language':
        return MaterialPageRoute(builder: (_) => LanguageWidget());
      case '/ChangePassword':
        return MaterialPageRoute(builder: (_) => ChangePasswordWidget(null));
      case '/Settings':
        return MaterialPageRoute(builder: (_) => SettingsWidget(null));
      case '/ChatRooms':
        return MaterialPageRoute(builder: (_) => ChatRoomsWidget());
      case '/ChatScreen':
        return MaterialPageRoute(builder: (_) => ChatScreenWidget( routeArgument: args,));
      case '/LocalUsers':
        return MaterialPageRoute(builder: (_) => LocalUsersChatWidget());
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return MaterialPageRoute(builder: (_) => Scaffold(body: SafeArea(child: Text('Route Error'))));
    }
  }
}
