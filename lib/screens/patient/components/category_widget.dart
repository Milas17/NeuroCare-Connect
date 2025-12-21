import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/cached_image_widget../../../model/service_model.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryWidget extends StatelessWidget {
  final ServiceData data;

  final bool hideMoreButton;

  CategoryWidget({Key? key, required this.data, this.hideMoreButton = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: context.width() / 2 - 24,
      decoration: data.image.validate().isNotEmpty
          ? boxDecorationDefault(
              color: context.cardColor,
              image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.multiply),
                image: NetworkImage(
                  data.image.validate(),
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
          Text(
            data.name.validate().capitalizeEachWord(),
            textAlign: TextAlign.start,
            style: boldTextStyle(
                size: 14,
                color: data.image.validate().isNotEmpty
                    ? Colors.white
                    : appStore.isDarkModeOn
                        ? Colors.white
                        : Colors.black),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          8.height,
          if (data.doctorList.validate().length > 0)
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
          8.height,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min, // prevents Row from expanding infinitely
              children: [
                Stack(
                  alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  children: List.generate(
                    data.doctorList.validate().length > 3 ? 4 : data.doctorList.validate().length,
                    (index) {
                      List<UserModel> doctorList = data.doctorList.validate();
                      const double avatarSize = 30;

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
                              Text("+$extraCount", style: boldTextStyle(size: 10)),
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
