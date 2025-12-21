import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/network/auth_repository.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController oldPassCont = TextEditingController();
  TextEditingController newPassCont = TextEditingController();
  TextEditingController confNewPassCont = TextEditingController();

  FocusNode newPassFocus = FocusNode();
  FocusNode confPassFocus = FocusNode();

  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
  }

  void submit() async {
    appStore.setLoading(true);

    Map<String, dynamic> req = {
      'old_password': oldPassCont.text.trim(),
      'new_password': newPassCont.text.trim(),
    };

    await changePasswordAPI(req).then((value) async {
      appStore.setLoading(false);
      setValue(PASSWORD, newPassCont.text.trim());
      setValue(USER_PASSWORD, newPassCont.text.trim());
      finish(context);
      toast(value.message);

      Map<String, dynamic> loginReq = {
        'username': getStringAsync(USER_NAME),
        'password': newPassCont.text.trim(),
      };

      await loginAPI(loginReq).then((value) {}).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
        throw e;
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    getDisposeStatusBarColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(locale.lblChangePassword, textColor: Colors.white, systemUiOverlayStyle: defaultSystemUiOverlayStyle(context)),
      body: InternetConnectivityWidget(
        retryCallback: () => setState,
        child: Stack(
          children: [
            Form(
              key: formKey,
              autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
              child: AnimatedScrollView(
                listAnimationType: ListAnimationType.None,
                padding: EdgeInsets.all(16),
                children: [
                  AppTextField(
                    controller: oldPassCont,
                    textFieldType: TextFieldType.PASSWORD,
                    decoration: inputDecoration(context: context, labelText: locale.lblOldPassword),
                    nextFocus: newPassFocus,
                    suffixPasswordVisibleWidget: ic_showPassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                    suffixPasswordInvisibleWidget: ic_hidePassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                    textStyle: primaryTextStyle(),
                    obscureText: true,
                    validator: (String? value) {
                      if (value!.isEmpty) return locale.lblFieldIsRequired;
                      if (value.length < passwordLengthGlobal) return locale.lblPasswordLengthMessage + ' $passwordLengthGlobal';
                      return null;
                    },
                  ),
                  16.height,
                  AppTextField(
                    controller: newPassCont,
                    textFieldType: TextFieldType.PASSWORD,
                    decoration: inputDecoration(context: context, labelText: locale.lblNewPassword),
                    focus: newPassFocus,
                    suffixPasswordVisibleWidget: ic_showPassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                    suffixPasswordInvisibleWidget: ic_hidePassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                    nextFocus: confPassFocus,
                    textStyle: primaryTextStyle(),
                    obscureText: true,
                    validator: (value) {
                      RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                      if (value.validate().isEmpty) {
                        return locale.lblFieldIsRequired;
                      }
                      if (value.validate() == oldPassCont.text.trim()) {
                        return locale.lblOldAndNewPassword;
                      }
                      if (!regex.hasMatch(value.validate())) {
                        return locale.lblPasswordMustBeStrong;
                      }
                      return null;
                    },
                  ),
                  16.height,
                  AppTextField(
                    controller: confNewPassCont,
                    textFieldType: TextFieldType.PASSWORD,
                    decoration: inputDecoration(context: context, labelText: locale.lblConfirmPassword),
                    focus: confPassFocus,
                    textInputAction: TextInputAction.done,
                    textStyle: primaryTextStyle(),
                    suffixPasswordVisibleWidget: ic_showPassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                    suffixPasswordInvisibleWidget: ic_hidePassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                    obscureText: true,
                    validator: (String? value) {
                      if (value!.isEmpty) return locale.lblFieldIsRequired;
                      if (value.trim() != newPassCont.text.trim()) return locale.lblBothPasswordMatched;
                      return null;
                    },
                    onFieldSubmitted: (s) {},
                  ),
                  30.height,
                  AppButton(
                    text: locale.lblSubmit,
                    textStyle: boldTextStyle(color: textPrimaryDarkColor),
                    width: context.width(),
                    onTap: () {
                      hideKeyboard(context);

                      if (appStore.demoEmails.any((e) => e.toString() == userStore.userEmail)) {
                        toast(locale.lblDemoUserPasswordNotChanged);
                      } else {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          showConfirmDialogCustom(
                            primaryColor: appPrimaryColor,
                            context,
                            dialogType: DialogType.CONFIRMATION,
                            title: locale.lblDoYouWantToChangeThePassword,
                            onAccept: (p0) {
                              ifNotTester(context, () {
                                submit();
                              });
                            },
                          );
                        } else {
                          isFirstTime = false;
                          setState(() {});
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading).center())
          ],
        ),
      ),
    );
  }
}
