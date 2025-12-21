import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_flutter/main.dart';

class SelectedClinicComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationDefault(color: context.cardColor),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${locale.lblClinic}: ', style: secondaryTextStyle()),
          8.height,
          appointmentAppStore.mClinicSelected != null
              ? Marquee(
            child: Text("${appointmentAppStore.mClinicSelected!.name.validate()}", style: boldTextStyle(size: 18)),
          )
              : Text('${locale.lblLoading} ${locale.lblClinic}...', style: secondaryTextStyle()),
        ],
      ),
    );
  }
}