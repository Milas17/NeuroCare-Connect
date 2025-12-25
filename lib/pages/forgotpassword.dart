import 'package:yourappname/provider/forgotpasswordprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:yourappname/widgets/mytextformfield.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  final String viewFrom;
  const ForgotPassword(this.viewFrom, {super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late ProgressDialog prDialog;
  final _formKey = GlobalKey<FormState>();
  final mEmailController = TextEditingController();

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    super.initState();
  }

  @override
  void dispose() {
    mEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      appBar: Utils.myAppBarWithBack(context, "forgotpassword_title", true, true),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: "forgotpass_note",
                  multilanguage: true,
                  fontsize: Dimens.text16Size,
                  fontstyle: FontStyle.normal,
                  fontweight: FontWeight.normal,
                  textalign: TextAlign.start,
                  color: otherColor,
                ),
                const SizedBox(
                  height: 20,
                ),
                MyTextFormField(
                  mHint: emailAddressReq,
                  mController: mEmailController,
                  mObscureText: false,
                  mMaxLine: 1,
                  mHintTextColor: textTitleColor,
                  mTextColor: otherColor,
                  mkeyboardType: TextInputType.emailAddress,
                  mTextInputAction: TextInputAction.next,
                  mInputBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide:
                          const BorderSide(color: black, width: 0.5)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                  child: sendButton(),
                ),
              ],
            ),
          ),
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
      String email = mEmailController.text.toString().trim();

      if (email.isEmpty) {
        Utils.showToast(enterEmail);
      } else if (!EmailValidator.validate(email)) {
        Utils.showToast(enterValidEmail);
      } else {
        Utils.showProgress(context, prDialog);
        // doctor_forgot_password API call
        await forgotPasswordProvider.getForgotPassword(email);
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

  void clearTextFormField() {
    mEmailController.clear();
  }
}
