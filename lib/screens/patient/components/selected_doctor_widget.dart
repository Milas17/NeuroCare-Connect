import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:nb_utils/nb_utils.dart';

class SelectedDoctorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationDefault(color: context.cardColor),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${locale.lblDoctor}: ', style: secondaryTextStyle()),
          8.height,
          appointmentAppStore.mDoctorSelected != null
              ? Marquee(
            child: Text("${appointmentAppStore.mDoctorSelected!.displayName.validate()}", style: boldTextStyle(size: 18)),
          )
              : Text('${locale.lblLoading} ${locale.lblDoctor}...', style: secondaryTextStyle()),
        ],
      ),
    );
  }
}