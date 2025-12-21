import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/main.dart';

import 'package:kivicare_flutter/screens/auth/screens/edit_profile_screen.dart';
import 'package:kivicare_flutter/screens/dashboard/screens/common_settings_screen.dart';
import 'package:kivicare_flutter/screens/patient/screens/patient_clinic_selection_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/extensions/widget_extentions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class EditProfileComponent extends StatefulWidget {
  final VoidCallback? refreshCallback;

  EditProfileComponent({this.refreshCallback});

  @override
  State<EditProfileComponent> createState() => _EditProfileComponentState();
}

class _EditProfileComponentState extends State<EditProfileComponent> {
  bool get showClinic {
    // if (isReceptionist() || isPatient() ) {
    //   return isVisible(SharedPreferenceKey.kiviCarePatientClinicVisibleKey);
    // } else {
    //   return false;
    // }
    return isVisible(SharedPreferenceKey.kiviCarePatientClinicVisibleKey);
  }

  bool get showEdit {
    if (isPatient() || isDoctor())
      return isVisible(SharedPreferenceKey.kiviCarePatientProfileKey);
    else
      return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                if (userStore.profileImage.validate().isNotEmpty)
                  GradientBorder(
                    borderRadius: 65,
                    padding: 2,
                    gradient: LinearGradient(colors: [viewLineColor, viewLineColor]),
                    child: CachedImageWidget(
                      url: userStore.profileImage.validate(),
                      height: 65,
                      circle: true,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  PlaceHolderWidget(
                    shape: BoxShape.circle,
                    height: 65,
                    width: 65,
                    border: Border.all(color: context.dividerColor, width: 2),
                    alignment: Alignment.center,
                    child: Text(
                      userStore.firstName.validate(value: '')[0].capitalizeFirstLetter(),
                      style: boldTextStyle(color: Colors.black, size: 20),
                    ),
                  ),
                if (showEdit)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: appPrimaryColor,
                        boxShape: BoxShape.circle,
                        border: Border.all(color: white, width: 3),
                      ),
                      child: Image.asset(ic_edit, height: 16, width: 16, color: Colors.white),
                    ),
                  )
              ],
            ),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getRoleWiseName(name: "${userStore.firstName.validate()} ${userStore.lastName.validate()}"),
                  style: boldTextStyle(size: titleTextSize),
                ),
                2.height,
                Text(userStore.userEmail.validate(), style: secondaryTextStyle()),
              ],
            ).expand(),
            ic_settings
                .iconImageColored(
                  color: appStore.isDarkModeOn ? Colors.white : appSecondaryColor,
                )
                .paddingAll(14)
                .appOnTap(() {
              CommonSettingsScreen().launch(
                context,
                duration: Duration(milliseconds: 600),
                pageRouteAnimation: pageAnimation,
              );
            })
          ],
        ).appOnTap(
          () {
            if (showEdit)
              EditProfileScreen()
                  .launch(
                context,
                duration: Duration(milliseconds: 600),
                pageRouteAnimation: pageAnimation,
              )
                  .then((value) {
                widget.refreshCallback?.call();
              });
          },
        ),
        if (showClinic)
          Divider(
            height: 30,
            color: context.dividerColor,
          ),
        if (showClinic)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ic_clinicPlaceHolder.iconImageColored(size: 26),
                      Text(userStore.userClinicName.validate(), style: primaryTextStyle()).expand(),
                      if (userStore.userClinic?.status.validate().isNotEmpty ?? false)
                        StatusWidget(
                          status: userStore.userClinic?.status.validate() ?? '',
                          isClinicStatus: true,
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        )
                    ],
                  ),
                  if (userStore.userClinicAddress.validate().isNotEmpty) 6.height,
                  if (userStore.userClinicAddress.validate().isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        PatientClinicSelectionScreen(
                          callback: () {
                            widget.refreshCallback?.call();
                          },
                        ).launch(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ic_location.iconImage(size: 18).paddingOnly(top: 4, bottom: 4),
                          4.width,
                          Expanded(
                            child: Marquee(
                              direction: Axis.horizontal,
                              child: Text(
                                userStore.userClinicAddress.validate(),
                                style: secondaryTextStyle(),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Change Clinic",
                                style: secondaryTextStyle(color: context.primaryColor),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: context.primaryColor,
                                size: 16,
                              )
                            ],
                          )
                        ],
                      ).paddingLeft(4),
                    )
                ],
              ).expand(),
            ],
          ).paddingSymmetric(vertical: 8),
      ],
    );
  }
}
