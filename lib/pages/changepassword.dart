import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../provider/forgotpasswordprovider.dart';
import '../utils/colors.dart';
import '../utils/constant.dart';
import '../utils/utils.dart';
import '../widgets/mytext.dart';
import '../widgets/mytextformfield.dart';

class ChangePassword extends StatefulWidget {
  final String viewFrom;
  const ChangePassword(this.viewFrom, {super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late ProgressDialog prDialog;
  final _formKey = GlobalKey<FormState>();
  final passwordcontroller = TextEditingController();
  final confirmpasswordcontroller = TextEditingController();
  final currentpasswordcontroller = TextEditingController();

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    super.initState();
  }

  @override
  void dispose() {
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      appBar: Utils.myAppBarWithBack(context, Constant.appName, false, true),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  MyText(
                    text: "change_password",
                    multilanguage: true,
                    fontsize: Dimens.text24Size,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w600,
                    textalign: TextAlign.left,
                    color: colorPrimaryDark,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyTextFormField(
                    mHint: enterCurrentPassword,
                    mController: currentpasswordcontroller,
                    mObscureText: false,
                    mMaxLine: 1,
                    mHintTextColor: textTitleColor,
                    mTextColor: otherColor,
                    mkeyboardType: TextInputType.visiblePassword,
                    mTextInputAction: TextInputAction.next,
                    mInputBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: black, width: 0.5)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyTextFormField(
                    mHint: passwordReq,
                    mController: passwordcontroller,
                    mObscureText: false,
                    mMaxLine: 1,
                    mHintTextColor: textTitleColor,
                    mTextColor: otherColor,
                    mkeyboardType: TextInputType.visiblePassword,
                    mTextInputAction: TextInputAction.next,
                    mInputBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: black, width: 0.5)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyTextFormField(
                    mHint: confirpasswordReq,
                    mController: confirmpasswordcontroller,
                    mObscureText: false,
                    mMaxLine: 1,
                    mHintTextColor: textTitleColor,
                    mTextColor: otherColor,
                    mkeyboardType: TextInputType.visiblePassword,
                    mTextInputAction: TextInputAction.done,
                    mInputBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: black, width: 0.5)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                child: sendButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sendButton() {
    return InkWell(
      focusColor: colorPrimary,
      onTap: () => validateFormData(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: Constant.buttonHeight,
        decoration: Utils.primaryDarkButton(),
        alignment: Alignment.center,
        child: MyText(
          text: "send",
          multilanguage: true,
          color: white,
          textalign: TextAlign.center,
          fontsize: Dimens.text16Size,
          fontweight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget goToLogin() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: RichText(
        text: TextSpan(
          text: alreadyHaveAccount,
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              color: otherLightColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
          ),
          children: <TextSpan>[
            TextSpan(
              text: loginFSpace.toUpperCase(),
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  color: colorPrimaryDark,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                ),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pop();
                },
            ),
          ],
        ),
      ),
    );
  }

  void validateFormData() async {
    final forgotPasswordProvider =
        Provider.of<ForgotPasswordProvider>(context, listen: false);
    final isValidForm = _formKey.currentState!.validate();
    printLog("isValidForm => $isValidForm");
    // Validate returns true if the form is valid, or false otherwise.
    if (isValidForm) {
      String currentPassword = currentpasswordcontroller.text.toString().trim();
      String password = passwordcontroller.text.toString().trim();
      String confirmpassword = confirmpasswordcontroller.text.toString().trim();

      if (currentPassword.isEmpty) {
        Utils.showToast(enterPassword);
      } else if (password.isEmpty) {
        Utils.showToast(enterConfirmPassword);
      } else if (confirmpassword.isEmpty) {
        Utils.showToast(enterConfirmPassword);
      } else if (confirmpassword != password) {
        Utils.showToast(enterrightpassword);
      } else {
        Utils.showProgress(context, prDialog);
        await changePassword(confirmpassword);
        // doctor_forgot_password API call
        await forgotPasswordProvider.getChangePassword(
            currentPassword, password, confirmpassword);
        if (!forgotPasswordProvider.loading) {
          // Hide Progress Dialog
          prDialog.hide();

          if (!mounted) return;
          Utils.showSnackbar(
              context, "${forgotPasswordProvider.successModel.message}", false);
          if (forgotPasswordProvider.successModel.status == 200) {
            clearTextFormField();
            if (!mounted) return;
            Navigator.of(context).pop();
          }
        }
      }
    }
  }

  Future<void> changePassword(String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Print the user's email address
        String? email = user.email;
        printLog("User email: $email");

        // Update the user's password
        await user.updatePassword(newPassword);
        printLog("Password updated successfully");
      } catch (e) {
        printLog("Error updating password: $e");
      }
    } else {
      printLog("No user is currently signed in.");
    }
  }

  void clearTextFormField() {
    passwordcontroller.clear();
    confirmpasswordcontroller.clear();
  }
}
