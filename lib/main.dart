import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:yourappname/pages/splash.dart';
import 'package:yourappname/provider/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_locales/flutter_locales.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GeneralProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroCare Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Splash(),
    );
  }
}