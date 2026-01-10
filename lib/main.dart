import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yourappname/pages/splash.dart';
import 'package:yourappname/pages/videocall/provider/videocallprovider.dart';
import 'package:yourappname/pages/videocall/service/my_video_call_notification_handler.dart';
import 'package:yourappname/provider/addmedicineprovider.dart';
import 'package:yourappname/provider/addworkslotprovider.dart';
import 'package:yourappname/provider/appointmentdetailprovider.dart';
import 'package:yourappname/provider/appointmentprovider.dart';
import 'package:yourappname/provider/chatprovider.dart';
import 'package:yourappname/provider/commentprovider.dart';
import 'package:yourappname/provider/feedbackprovider.dart';
import 'package:yourappname/provider/forgotpasswordprovider.dart';
import 'package:yourappname/provider/historyprovider.dart';
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/listofappointmentprovider.dart';
import 'package:yourappname/provider/notificationprovider.dart';
import 'package:yourappname/provider/editprofileprovider.dart';
import 'package:yourappname/provider/patienthistoryprovider.dart';
import 'package:yourappname/provider/rescheduleprovider.dart';
import 'package:yourappname/provider/seeallprovider.dart';
import 'package:yourappname/provider/writeprescriptionprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/pushnotificationservice.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/all_file_viewer/provider/file_viewer_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    printLog("Handling a background message: ${message.messageId}");
    printLog('Message data: ${message.data}');
    printLog('Message notification: ${message.notification?.title}');
    printLog('Message notification: ${message.notification?.body}');
  }
}

@pragma('vm:entry-point')
Future<void> setVideoCallHandler() async {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

Future<void> main() async {
  // 1. On initialise les composants de base
  WidgetsFlutterBinding.ensureInitialized();

  // 2. On lance l'application IMMÉDIATEMENT sans attendre (pas de await ici)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GeneralProvider()),
        ChangeNotifierProvider(create: (context) => AddMedicineProvider()),
        ChangeNotifierProvider(create: (context) => AddWorkSlotProvider()),
        ChangeNotifierProvider(
            create: (context) => AppointmentDetailProvider()),
        ChangeNotifierProvider(create: (context) => AppointmentProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => CommentProvider()),
        ChangeNotifierProvider(create: (context) => FeedbackProvider()),
        ChangeNotifierProvider(create: (context) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(
            create: (context) => ListOfAppointmentProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => EditProfileProvider()),
        ChangeNotifierProvider(create: (context) => PatientHistoryProvider()),
        ChangeNotifierProvider(create: (context) => RescheduleProvider()),
        ChangeNotifierProvider(create: (context) => SeeAllProvider()),
        ChangeNotifierProvider(
            create: (context) => WritePrescriptionProvider()),
        ChangeNotifierProvider(create: (context) => VideoCallProvider()),
        ChangeNotifierProvider(create: (context) => FileViewerProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // 3. On lance les services lourds en arrière-plan (sans bloquer le démarrage)
  try {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((_) => print("DEBUG: Firebase prêt !"));
    
    Locales.init(['en', 'ar', 'hi']).then((_) => print("DEBUG: Langues prêtes !"));
  } catch (e) {
    print("DEBUG: Erreur d'initialisation ignorée : $e");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //DeepLink
  late final AppLinks _appLinks;

  @override
  void initState() {
    //Saved UserID in Constant for Future use
    _initDeepLinks();

    Utils.getUserId();
    selectlanguage();

    // configLocalNotification();
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: colorPrimaryDark));
    // _requestPermissions();
    super.initState();
  }

  // Future<void> _requestPermissions() async {
  //   if (Platform.isIOS || Platform.isMacOS) {
  //     await flutterLocalNotificationsPlugin
  //         .resolvePlatformSpecificImplementation<
  //             IOSFlutterLocalNotificationsPlugin>()
  //         ?.requestPermissions(
  //           alert: true,
  //           badge: true,
  //           sound: true,
  //         );
  //     await flutterLocalNotificationsPlugin
  //         .resolvePlatformSpecificImplementation<
  //             MacOSFlutterLocalNotificationsPlugin>()
  //         ?.requestPermissions(
  //           alert: true,
  //           badge: true,
  //           sound: true,
  //         );
  //   }
  // }

  Future<void> selectlanguage() async {
    SharedPre sharedPre = SharedPre();
    String? selectedLanguage = await sharedPre.read("language_code");
    if (selectedLanguage == null || selectedLanguage == "") {
      await sharedPre.save('language_code', 'en');
    }
  }

  //DeepLink Init
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // App launched by link
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // App opened again with a link
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
  }

  @override
  void dispose() {
    super.dispose();
    //VideoCallBackgroundService.stopForegroundService();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
        debugShowCheckedModeBanner: false,
        home: const Splash(),
      ),
    );
  }

  // void configLocalNotification() {
  //   AndroidInitializationSettings initializationSettingsAndroid =
  //       const AndroidInitializationSettings('app_icon');
  //   DarwinInitializationSettings initializationSettingsIOS =
  //       const DarwinInitializationSettings();
  //   InitializationSettings initializationSettings = InitializationSettings(
  //       android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  //   flutterLocalNotificationsPlugin.initialize(
  //     initializationSettings,
  //   );
  // }

  // What to do when the user opens/taps on a notification
  // void _handleNotificationOpened(OSNotificationClickEvent result) {
  //   /* 
  //    1-appointment, 2-comment, 3-following, 
  //    4-Case Update, 5-Court Date, 6-Upload Document */

  //   printLog(
  //       "setNotificationOpenedHandler type ===> ${result.notification.additionalData?['type']}");
  //   printLog(
  //       "setNotificationOpenedHandler employee_id ===> ${result.notification.additionalData?['employee_id']}");
  //   printLog(
  //       "setNotificationOpenedHandler client_id ===> ${result.notification.additionalData?['client_id']}");
  //   printLog(
  //       "setNotificationOpenedHandler appointment_id ===> ${result.notification.additionalData?['appointment_id']}");

  //   int? notiType = result.notification.additionalData?['type'] ?? 0;
  //   String? employeeID =
  //       result.notification.additionalData?['employee_id'].toString() ?? "";
  //   String? clientID =
  //       result.notification.additionalData?['client_id'].toString() ?? "";
  //   String? appointmentID =
  //       result.notification.additionalData?['appointment_id'].toString() ?? "";
  //   printLog("notiType =====> $notiType");
  //   printLog("employeeID =====> $employeeID");
  //   printLog("clientID =====> $clientID");
  //   printLog("appointmentID =====> $appointmentID");
  // }


}
