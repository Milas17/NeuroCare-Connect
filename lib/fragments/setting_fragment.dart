import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/common_shop_setting_component.dart';
import 'package:kivicare_flutter/components/doctor_recentionist_general_setting_component.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/network/auth_repository.dart';
import 'package:kivicare_flutter/screens/auth/components/edit_profile_component.dart';
import 'package:kivicare_flutter/screens/auth/screens/sign_in_screen.dart';
import 'package:kivicare_flutter/screens/patient/components/general_setting_component.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

class SettingFragment extends StatefulWidget {
  @override
  _SettingFragmentState createState() => _SettingFragmentState();
}

class _SettingFragmentState extends State<SettingFragment> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              final req = {
                "username": userStore.userEmail!,
                "password": appStore.password,
              };

              await loginAPI(req).then((value) {
                if (value == null) {
                  toast(locale.lblSessionDeleted);
                  SignInScreen().launch(context, isNewTask: true); // redirect with nb_utils
                } else {
                  setState(() {});
                }
              }).catchError((e) {
                toast(e.toString());
                SignInScreen().launch(context, isNewTask: true); // redirect with nb_utils
              });
            },
            child: AnimatedScrollView(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 60),
              listAnimationType: ListAnimationType.None,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditProfileComponent(refreshCallback: () {
                  setState(() {});
                }),
                Divider(
                  height: isReceptionist() || isPatient() ? 30 : 40,
                  color: context.dividerColor,
                ),
                Text(locale.lblGeneralSetting, textAlign: TextAlign.center, style: secondaryTextStyle()),
                16.height,
                if (isPatient()) GeneralSettingComponent(callBack: () => setState(() {})),
                if (isDoctor() || isReceptionist()) DoctorReceptionistGeneralSettingComponent(),
                CommonShopSettingComponent().visible(appStore.wcNonce.validate().isNotEmpty),
                Column(
                  children: [
                    Divider(
                      height: 24,
                      color: context.dividerColor,
                    ),
                    TextButton(
                      onPressed: () {
                        showConfirmDialogCustom(
                          context,
                          primaryColor: primaryColor,
                          negativeText: locale.lblCancel,
                          positiveText: locale.lblYes,
                          onAccept: (c) async {
                            appStore.setLoading(true);

                            await logout().catchError((e) {
                              appStore.setLoading(false);
                              throw e;
                            }).whenComplete(() {
                              appStore.setLoading(false);
                            });
                          },
                          title: locale.lblDoYouWantToLogout,
                        );
                      },
                      child: Text(
                        locale.lblLogOut,
                        style: primaryTextStyle(color: primaryColor, weight: FontWeight.bold),
                      ),
                    ).center(),
                  ],
                ).visible(appStore.wcNonce.validate().isNotEmpty)
              ],
            ),
          ),
        ),
        Positioned(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  showConfirmDialogCustom(
                    context,
                    primaryColor: primaryColor,
                    negativeText: locale.lblCancel,
                    positiveText: locale.lblYes,
                    onAccept: (c) async {
                      appStore.setLoading(true);
                      await logout().catchError((e) {
                        appStore.setLoading(false);
                        throw e;
                      });
                    },
                    title: locale.lblDoYouWantToLogout,
                  );
                },
                child: Text(
                  locale.lblLogOut,
                  style: primaryTextStyle(color: zoomColor),
                ),
              ).center(),
            ],
          ),
          bottom: 0,
          left: 16,
          right: 16,
        ).visible(appStore.wcNonce.validate().isEmpty),
        Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading))
      ],
    );
  }
}
