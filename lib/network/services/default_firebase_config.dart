import 'package:firebase_core/firebase_core.dart';
import 'package:nb_utils/nb_utils.dart';

class DefaultFirebaseConfig {
  static String iosAppId = 'please add your ios app id';
  static String androidAppID = 'please add your android app id';

  static FirebaseOptions get platformOptions {
    if (isMobile)
      return FirebaseOptions(
        appId: isApple ? iosAppId : androidAppID,
        apiKey: 'please add your api key',
        projectId: 'please add your project id',
        messagingSenderId: 'please add your messaging sender id',
        storageBucket: 'please add your storage bucket',
      );
    else
      throw UnsupportedError('DefaultFirebaseOptions have not been configured for selected platform ');
  }
}
