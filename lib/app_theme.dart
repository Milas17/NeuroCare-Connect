import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class AppTheme {
  //
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, outlineVariant: borderColor),
      scaffoldBackgroundColor: scaffoldColorLight,
      fontFamily: GoogleFonts.roboto().fontFamily,
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: appSecondaryColor, foregroundColor: Colors.white),
      useMaterial3: true,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.white),
      iconTheme: IconThemeData(color: iconColor),
      textTheme: GoogleFonts.robotoTextTheme(),
      unselectedWidgetColor: Colors.black,
      dividerColor: borderColor,
      radioTheme: RadioThemeData(visualDensity: VisualDensity.compact, fillColor: WidgetStatePropertyAll(primaryColor)),
      cardColor: cardColor,
      appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark, statusBarColor: Colors.white)),
      timePickerTheme: TimePickerThemeData(shape: RoundedRectangleBorder(borderRadius: radius())),
      dialogTheme: DialogThemeData(shape: dialogShape(), backgroundColor: Colors.white),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
        backgroundColor: Colors.white,
      ),
      pageTransitionsTheme: PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }

  static ThemeData get darkTheme => ThemeData(
        primarySwatch: createMaterialColor(primaryColor),
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, outlineVariant: borderColor),
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        ),
        scaffoldBackgroundColor: scaffoldColorDark,
        fontFamily: GoogleFonts.roboto().fontFamily,
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: appSecondaryColor, foregroundColor: Colors.white),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: scaffoldSecondaryDark),
        iconTheme: IconThemeData(color: Colors.white),
        textTheme: GoogleFonts.robotoTextTheme(),
        unselectedWidgetColor: Colors.white60,
        bottomSheetTheme: BottomSheetThemeData(
          shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
          backgroundColor: scaffoldSecondaryDark,
        ),
        useMaterial3: true,
        dividerColor: Colors.white12,
        cardColor: scaffoldSecondaryDark,
        dialogTheme: DialogThemeData(shape: dialogShape(), backgroundColor: scaffoldSecondaryDark),
        pageTransitionsTheme: PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
      );
}