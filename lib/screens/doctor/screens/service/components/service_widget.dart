import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/service_duration_model.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class ServiceWidget extends StatelessWidget {
  final ServiceData data;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  List<DurationModel> durationList = getServiceDuration();

  ServiceWidget({required this.data, this.onEdit, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: context.width() / 2 - 24,
            child: Container(
              decoration: data.image.validate().isNotEmpty
                  ? boxDecorationDefault(
                      color: context.cardColor,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black54, BlendMode.multiply),
                        image: NetworkImage(
                          data.doctorList != null
                              ? data.doctorList.validate().isNotEmpty
                                  ? data.doctorList.validate()[data.doctorList.validate().indexWhere((element) => element.serviceImage.isEmptyOrNull)].serviceImage.validate()
                                  : data.image.validate()
                              : data.image.validate(),
                        ),
                      ),
                    )
                  : BoxDecoration(
                      color: appStore.isDarkModeOn ? context.cardColor : lightColors[Random.secure().nextInt(lightColors.length)],
                      shape: BoxShape.rectangle,
                      borderRadius: radius(),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDoctor()) 10.height,
                  if (isReceptionist() || isPatient()) 8.height,
                  Marquee(
                    child: Text(
                      data.name.validate().capitalizeEachWord(),
                      style: boldTextStyle(
                        size: 16,
                        color: data.image.validate().isNotEmpty
                            ? Colors.white
                            : appStore.isDarkModeOn
                                ? Colors.white
                                : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  8.height,
                  if (isDoctor() && data.clinicName.validate().isNotEmpty)
                    Marquee(
                      child: Text(data.clinicName.validate().capitalizeEachWord(),
                          style: boldTextStyle(
                            size: 14,
                            color: data.image.validate().isNotEmpty
                                ? Colors.white
                                : appStore.isDarkModeOn
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  if ((isReceptionist() || isPatient()) && data.doctorList.validate().isNotEmpty)
                    Text(
                      '${data.doctorList.validate().length} ${(data.doctorList.validate().length > 1) ? locale.lblDoctorsAvailable : locale.lblDoctorAvailable}',
                      style: secondaryTextStyle(
                          color: data.image.validate().isNotEmpty
                              ? Colors.white70
                              : appStore.isDarkModeOn
                                  ? Colors.white70
                                  : Colors.black54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if ((isReceptionist() || isPatient()) && data.doctorList.validate().isNotEmpty) 8.height,
                  if ((isReceptionist() || isPatient()) && data.doctorList.validate().isNotEmpty)
                    Row(
                      children: [
                        Stack(
                          alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                          children: List.generate(
                            data.doctorList.validate().length > 3 ? 4 : data.doctorList.validate().length,
                            (index) {
                              List<UserModel> doctorList = data.doctorList.validate();
                              const double avatarSize = 30;

                              // If showing +X container
                              if (index == 3) {
                                int extraCount = doctorList.length - 3;

                                return Container(
                                  height: avatarSize,
                                  width: avatarSize,
                                  margin: EdgeInsets.only(
                                    left: !isRTL ? index * 20 : 0,
                                    right: isRTL ? index * 20 : 0,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ImageBorder(
                                        height: avatarSize,
                                        width: avatarSize,
                                        src: '',
                                        nameInitial: '',
                                      ),
                                      Text(
                                        "+$extraCount",
                                        style: boldTextStyle(size: 10),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              UserModel userData = doctorList[index];
                              String image = userData.profileImage.validate();
                              return ImageBorder(
                                height: avatarSize,
                                width: avatarSize,
                                src: image,
                                nameInitial: userData.displayName.validate(value: 'D')[0],
                              ).paddingLeft(!isRTL ? (index == 0 ? 0 : index * 20) : 0).paddingRight(isRTL ? (index == 0 ? 0 : index * 20) : 0);
                            },
                          ),
                        ).expand(),
                      ],
                    )
                  else
                    // Charges + Duration + View Button Row
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              RichTextWidget(
                                list: [
                                  TextSpan(
                                    text: '${appStore.currencyPrefix.validate()} ',
                                    style: data.image.validate().isNotEmpty ? secondaryTextStyle(color: Colors.white70) : primaryTextStyle(size: 14),
                                  ),
                                  TextSpan(
                                    text: '${data.charges}${appStore.currencyPostfix}',
                                    style: data.image.validate().isNotEmpty ? secondaryTextStyle(color: Colors.white70) : primaryTextStyle(size: 14),
                                  ),
                                ],
                              ),
                              16.width,
                              if (data.duration != null && data.duration.validate() != '0')
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ic_timer.iconImage(color: appSecondaryColor, size: 16),
                                    2.width,
                                    Text(
                                      durationList
                                          .firstWhere(
                                            (element) => element.value == data.duration.toInt(),
                                            orElse: () => DurationModel(value: 0, label: 'N/A'),
                                          )
                                          .label
                                          .validate(),
                                      style: data.image.validate().isNotEmpty ? secondaryTextStyle(color: Colors.white70) : primaryTextStyle(size: 14),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ).paddingTop(3),
                ],
              ).paddingOnly(left: 12, right: 12, top: isDoctor() ? 28 : 0, bottom: 12),
            ),
          ),
          if (isDoctor() || isReceptionist()) ...[
            // Top Right (Status + Edit)
            Positioned(
              right: 8,
              top: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusWidget(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    status: data.status.validate(),
                    isServiceActivityStatus: true,
                  ).visible(isDoctor()),
                  4.width,
                  if (onEdit != null && isVisible(SharedPreferenceKey.kiviCareServiceEditKey))
                    InkWell(
                      onTap: onEdit,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: appPrimaryColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, size: 16, color: appPrimaryColor),
                      ),
                    ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
