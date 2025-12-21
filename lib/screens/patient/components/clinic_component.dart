import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/clinic_details_model.dart';
import 'package:kivicare_flutter/model/clinic_list_model.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/network/clinic_repository.dart';
import 'package:kivicare_flutter/network/doctor_repository.dart';
import 'package:kivicare_flutter/screens/doctor/screens/ClinicDetailScreen.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_flutter/utils/extensions/widget_extentions.dart';

import 'package:kivicare_flutter/components/status_widget.dart';

import 'html_widget.dart';

class ClinicComponent extends StatefulWidget {
  final Clinic clinicData;
  final bool isCheck;
  final Function(bool)? onTap;

  ClinicComponent({required this.clinicData, this.onTap, this.isCheck = false});

  @override
  State<ClinicComponent> createState() => _ClinicComponentState();
}

class _ClinicComponentState extends State<ClinicComponent> {
  bool isLastPage = false;

  bool showClear = false;

  int page = 1;
  List<UserModel> doctorList = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: context.width() / 2 - 24,
          padding: EdgeInsets.only(top: 32, right: 16, left: 16),
          decoration: boxDecorationDefault(color: context.cardColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              28.height,
              Marquee(
                child: HtmlWidget(postContent: widget.clinicData.name.validate()),
                animationDuration: Duration(milliseconds: 400),
                pauseDuration: Duration(milliseconds: 100),
              ),
              4.height,
              TextIcon(
                spacing: 4,
                prefix: ic_location.iconImage(size: 16).paddingAll(4),
                text: [
                  widget.clinicData.address.validate(),
                  widget.clinicData.city.validate(),
                  widget.clinicData.country.validate(),
                  widget.clinicData.postalCode.validate(),
                ].where((element) => element.isNotEmpty).join(", "),
                maxLine: 2, // allow wrapping if too long
                expandedText: true,
                useMarquee: true,
                textStyle: secondaryTextStyle(),
              ),
              28.height,
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          left: 12,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.clinicData.profileImage.validate().isNotEmpty)
                CachedImageWidget(
                  url: widget.clinicData.profileImage.validate(),
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRect(8)
              else
                ic_clinicPlaceHolder.iconImageColored(height: 40, width: 40).cornerRadiusWithClipRRect(8),
              16.width.expand(),
              StatusWidget(
                status: widget.clinicData.status.validate(),
                isClinicStatus: true,
                borderRadius: radius(),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 8,
          right: 12,
          child: Container(
            padding: EdgeInsets.zero,
            decoration: boxDecorationDefault(shape: BoxShape.circle, color: widget.isCheck ? Colors.green : context.cardColor, border: Border.all(width: 2, color: Colors.green)),
            child: widget.isCheck ? Icon(Icons.check, color: Colors.white, size: 16) : Container(padding: EdgeInsets.all(widget.isCheck ? 0 : 8), decoration: boxDecorationDefault(shape: BoxShape.circle, color: context.cardColor)),
          ).appOnTap(
            () {
              widget.onTap!.call(!widget.isCheck);
            },
          ),
        )
      ],
    ).appOnTap(
      () async {
        ClinicDetailsModel? clinicDetail = await getClinicDetailsAPI(clinicId: widget.clinicData.id!);
        (await getDoctorListWithPagination(
          doctorList: doctorList,
          clinicId: widget.clinicData.id.toInt(),
          page: page,
          lastPageCallback: (b) => isLastPage = b,
        ).whenComplete(() {
          appStore.setLoading(false);

          setState(() {});
        }).catchError((e) {
          appStore.setLoading(false);
          setState(() {});
          throw e;
        }));
        ClinicDetailScreen(clinic: clinicDetail,).launch(context);
      },
    );
  }
}
