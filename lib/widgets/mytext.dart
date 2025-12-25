import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class MyText extends StatelessWidget {
  String text;
  double? fontsize;
  dynamic fontweight,
      fontstyle,
      color,
      textalign,
      maxline,
      overflow,
      letterspacing;
  bool? multilanguage;
  final int? type; // Added type field

  MyText({
    super.key,
    required this.text,
    this.fontsize,
    this.fontweight,
    this.fontstyle,
    this.color,
    this.textalign,
    this.maxline,
    this.overflow,
    this.letterspacing,
    this.multilanguage,
    this.type,
  });

  // Method to select the font style based on type
  TextStyle _getFontStyle() {
    return (type == 2)
        ? GoogleFonts.domine(
            textStyle: TextStyle(
              fontSize: fontsize,
              color: color,
              fontWeight: fontweight,
              fontStyle: fontstyle,
              letterSpacing: letterspacing,
            ),
          )
        : GoogleFonts.manrope(
            textStyle: TextStyle(
              fontSize: fontsize,
              color: color,
              fontWeight: fontweight,
              fontStyle: fontstyle,
              letterSpacing: letterspacing,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return (multilanguage != null && multilanguage == true)
        ? LocaleText(text,
            textAlign: textalign,
            maxLines: maxline,
            overflow: overflow,
            style: _getFontStyle())
        : Text(text,
            textAlign: textalign,
            maxLines: maxline,
            overflow: overflow,
            style: _getFontStyle());
  }
}
