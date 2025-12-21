import 'package:flutter/material.dart';
import 'package:kivicare_flutter/model/qualification_model.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class QualificationItemWidget extends StatelessWidget {
  final Qualification data;
  final bool showAdd;
  final Function() onEdit;

  const QualificationItemWidget({Key? key, this.showAdd = true, required this.data, required this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.degree.validate().isNotEmpty || data.university.validate().isNotEmpty)
      return Container(
        width: context.width(),
        height: 60,
        decoration: boxDecorationDefault(borderRadius: BorderRadius.circular(defaultRadius), color: context.cardColor),
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ic_graduation_cap.iconImage(size: 24, color: appSecondaryColor),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(data.degree.validate().toUpperCase(), style: boldTextStyle(size: 15)).expand(),
                if (data.university.validate().isNotEmpty)
                  ReadMoreText(data.university.validate().suffixText(value: data.year.toString().isNotEmpty ? " - ${data.year.toString().validate()}" : ''), style: secondaryTextStyle(), trimMode: TrimMode.Line, trimLines: 1),
              ],
            ).expand(),
            16.width,
            if (showAdd) ic_edit.iconImage(size: 22, color: context.iconColor, fit: BoxFit.cover).onTap(onEdit)
          ],
        ),
      );
    else
      return Offstage();
  }
}
