import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class MyTextFormField extends StatelessWidget {
  final String mHint;
  final bool? mObscureText;
  final TextEditingController? mController;
  final TextInputType? mkeyboardType;
  final TextInputAction? mTextInputAction;
  final List<dynamic>? mInputFormatters;
  final InputBorder? mInputBorder;
  final Color? mTextColor;
  final Color? mHintTextColor;
  final String? mInitialValue;
  final TextAlign? mTextAlign;
  final int? mMaxLine;
  final int? mMaxLength;
  final bool? mReadOnly;
  final FocusNode? mFocusNode;
  final ValueChanged<String>? onChanged; 

  const MyTextFormField({
    super.key,
    required this.mHint,
    this.mObscureText = false,
    this.mController,
    this.mkeyboardType,
    this.mTextInputAction,
    this.mInputFormatters,
    this.mInputBorder,
    this.mHintTextColor,
    this.mInitialValue,
    this.mTextColor,
    this.mTextAlign,
    this.mMaxLine = 1,
    this.mMaxLength,
    this.mReadOnly = false,
    this.mFocusNode, 
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: mController,
      focusNode: mFocusNode, 
      keyboardType: mkeyboardType,
      textInputAction: mTextInputAction,
      inputFormatters: mInputFormatters?.cast(),
      obscureText: mObscureText ?? false,
      maxLength: mMaxLength,
      initialValue: mInitialValue,
      maxLines: mMaxLine,
      readOnly: mReadOnly ?? false,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: mHint,
        hintStyle: GoogleFonts.roboto(
          fontSize: 16,
          color: mHintTextColor,
          fontWeight: FontWeight.normal,
        ),
        border: mInputBorder,
      ),
      style: GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: 16,
          color: mTextColor,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
