import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class ViewServiceDataScreen extends StatelessWidget {
  final ServiceData serviceData;

  ViewServiceDataScreen({required this.serviceData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblService,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Service Image with card style
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(16),
              decoration: boxDecorationDefault(
                borderRadius: radius(12),
                color: context.cardColor,
                boxShadow: defaultBoxShadow(),
              ),
              child: Column(
                children: [
                  ImageBorder(
                    src: serviceData.image.validate(),
                    height: 120,
                    width: 120,
                  ),
                  12.height,
                  Text(serviceData.name.validate(), style: boldTextStyle(size: 18)),
                  4.height,
                  Text(serviceData.clinicName.validate(), style: secondaryTextStyle(size: 14)),
                ],
              ),
            ),
            24.height,

            // Details List
            detailTile(Icons.category, locale.lblCategory, serviceData.type.validate(), context),
            detailTile(Icons.monetization_on, locale.lblCharges, "\$${serviceData.charges.validate()}", context),
            detailTile(Icons.timer, locale.lblDuration, "${serviceData.duration.validate()} min", context),
            detailTile(Icons.check_circle, locale.lblAllowMultiSelectionWhileBooking, serviceData.multiple == true ? locale.lblYes : locale.lblNo, context),

            // Status with Badge
            statusTile(
              Icons.verified,
              locale.lblSetStatus,
              serviceData.status == "1" ? locale.lblActive : locale.lblInActive,
              serviceData.status == "1",
              context,
            ),

            detailTile(Icons.video_call, locale.lblIsThisATelemedService, serviceData.isTelemed == true ? locale.lblYes : locale.lblNo, context),
          ],
        ),
      ),
    );
  }

  /// Normal Detail Tile
  Widget detailTile(IconData icon, String label, String value, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(14),
      decoration: boxDecorationDefault(
        borderRadius: radius(12),
        color: context.cardColor,
        boxShadow: defaultBoxShadow(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 22),
          12.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: secondaryTextStyle()),
              4.height,
              Text(value, style: boldTextStyle(size: 16)),
            ],
          ).expand(),
        ],
      ),
    );
  }

  /// Status Tile with colored badge
  Widget statusTile(IconData icon, String label, String value, bool isActive, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(14),
      decoration: boxDecorationDefault(
        borderRadius: radius(12),
        color: context.cardColor,
        boxShadow: defaultBoxShadow(),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          12.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: secondaryTextStyle()),
              6.height,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                  borderRadius: radius(20),
                ),
                child: Text(
                  value,
                  style: boldTextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    size: 14,
                  ),
                ),
              ),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
