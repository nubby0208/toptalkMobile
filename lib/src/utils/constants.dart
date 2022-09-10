//created by Hatem Ragap
class Constants {
  static const ADMIN_EMAIL = "admin@admin.com";

  static const PORT = 4000;
  // static const IP ='10.10.10.225'; //only change this by your IPv4 Address
  static const IP ='10.10.11.143'; //only change this by your IPv4 Address
  // static const SERVER_URL = 'https://localtalk.mobi/communicator/api/';
  static const SERVER_URL = 'http://10.10.11.143:4000/api/';
  static const SERVER_IMAGE_URL = 'http://$IP:$PORT/';
  static const USERS_PROFILES_URL = 'http://$IP:$PORT/uploads/users_profile_img/';
  static const USERS_POSTS_IMAGES = 'http://$IP:$PORT/uploads/users_posts_img/';
  static const USERS_MESSAGES_IMAGES = 'http://$IP:$PORT/uploads/users_messages_img/';
  static const PUBLIC_ROOMS_IMAGES = 'http://$IP:$PORT/uploads/public_chat_rooms/';
  // static const SOCKET_URL = 'https://localtalk-mobi.herokuapp.com';
  static const SOCKET_URL = 'http://10.10.11.143:4000';



  // Go To https://apps.admob.com/ to get your app id and create banners and Interstitial

  static const ADMOB_APP_ID_ANDROID = 'ca-app-pub-9468403851841120~5538535749';
  static const ADMOB_APP_ID_IOS = 'ca-app-pub-3940256099942544~1458002511';

  static const InterstitialAdUnitIdAndroid = 'ca-app-pub-9468403851841120/2509935776';
  static const InterstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';

  static const BannerAdUnitIdAndroid = 'ca-app-pub-9468403851841120/2253896859';
  static const BannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';

  static var userresponse;


}
