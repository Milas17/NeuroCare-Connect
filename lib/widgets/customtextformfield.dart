import 'package:yourappname/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText, readOnly;
  final Icon? suffixIcon;
  final Function()? onSuffixIconPressed;
  final TextInputAction? textInputAction;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.readOnly,
    required this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.textInputAction
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 15, horizontal: 10), // Increased height
        labelStyle: GoogleFonts.roboto(
          fontSize: 16,
          color: black,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: black, width: 0.5),
        ),
        suffixIcon: suffixIcon != null
            ? IconButton(
                onPressed: onSuffixIconPressed,
                icon: suffixIcon!,
              )
            : null,
      ),
      style: GoogleFonts.roboto(
        textStyle: const TextStyle(
          fontSize: 18,
          color: black,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
      ),
    );
  }
}
