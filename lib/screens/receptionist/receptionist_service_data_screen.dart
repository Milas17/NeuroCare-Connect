import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ReceptionistServiceDataScreen extends StatefulWidget {
  final ServiceData serviceData;

  ReceptionistServiceDataScreen({required this.serviceData});

  @override
  _ReceptionistServiceDataScreenState createState() => _ReceptionistServiceDataScreenState();
}

class _ReceptionistServiceDataScreenState extends State<ReceptionistServiceDataScreen> {
  UserModel? selectedDoctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "View Service",
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Category
            AppTextField(
              controller: TextEditingController(text: widget.serviceData.type.validate()),
              readOnly: true,
              decoration: inputDecoration(
                context: context,
                labelText: locale.lblCategory,
              ),
              textFieldType: TextFieldType.OTHER,
            ),
            16.height,

            /// Service Name
            AppTextField(
              controller: TextEditingController(text: widget.serviceData.name.validate()),
              readOnly: true,
              decoration: inputDecoration(
                context: context,
                labelText: locale.lblServiceName,
                suffixIcon: ic_services.iconImage(size: 10, color: context.iconColor).paddingAll(14),
              ),
              textFieldType: TextFieldType.OTHER,
            ),
            16.height,

            /// Select Doctor (count)
            AppTextField(
              controller: TextEditingController(
                text: "${widget.serviceData.doctorList?.length ?? 0} ${locale.lblDoctorsAvailable}",
              ),
              readOnly: true,
              decoration: inputDecoration(
                context: context,
                labelText: locale.lblDoctor,
                suffixIcon: ic_user.iconImage(size: 10, color: context.iconColor).paddingAll(14),
              ),
              textFieldType: TextFieldType.OTHER,
            ),
            12.height,

            /// Note before doctors
            Text(
              "Note: To view Charges, Duration and other fields, tap on a doctor.",
              style: secondaryTextStyle(color: Colors.red),
            ),
            16.height,

            /// Doctor Chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.serviceData.doctorList
                      ?.map(
                        (e) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDoctor = e;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedDoctor?.doctorId == e.doctorId ? context.primaryColor.withOpacity(0.2) : context.cardColor,
                              borderRadius: radius(20),
                              border: Border.all(color: context.dividerColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.person, size: 16, color: context.iconColor),
                                4.width,
                                Text(
                                  '${locale.lblDr}${e.displayName.validate().split(' ').first}',
                                  style: primaryTextStyle(color: context.iconColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList() ??
                  [],
            ),

            24.height,

            /// Doctor Details Section (Only if selectedDoctor is not null)
            if (selectedDoctor != null) ...[
              Divider(thickness: 1),
              16.height,
              Text(
                "${locale.lblDr}${selectedDoctor!.displayName.validate().split(' ').first} Details",
                style: boldTextStyle(size: 18),
              ),
              16.height,

              /// Charges
              AppTextField(
                controller: TextEditingController(text: selectedDoctor!.charges.validate()),
                readOnly: true,
                decoration: inputDecoration(
                  context: context,
                  labelText: locale.lblCharges,
                  suffixIcon: ic_dollar_icon.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                ),
                textFieldType: TextFieldType.OTHER,
              ),
              16.height,

              /// Duration
              AppTextField(
                controller: TextEditingController(text: "${selectedDoctor!.duration.validate()} min"),
                readOnly: true,
                decoration: inputDecoration(
                  context: context,
                  labelText: locale.lblDuration,
                  suffixIcon: Icon(Icons.timer, color: context.iconColor, size: 18),
                ),
                textFieldType: TextFieldType.OTHER,
              ),
              16.height,

              /// Multi selection
              AppTextField(
                controller: TextEditingController(
                  text: selectedDoctor!.multiple == true ? locale.lblYes : locale.lblNo,
                ),
                readOnly: true,
                decoration: inputDecoration(
                  context: context,
                  labelText: locale.lblAllowMultiSelectionWhileBooking,
                ),
                textFieldType: TextFieldType.OTHER,
              ),
              16.height,

              /// Status
              AppTextField(
                controller: TextEditingController(
                  text: selectedDoctor!.status.getBoolInt() ? locale.lblActive : locale.lblInActive,
                ),
                readOnly: true,
                decoration: inputDecoration(
                  context: context,
                  labelText: locale.lblStatus,
                ),
                textFieldType: TextFieldType.OTHER,
              ),
              16.height,

              /// Telemed
              AppTextField(
                controller: TextEditingController(
                  text: selectedDoctor!.isTelemed == true ? locale.lblYes : locale.lblNo,
                ),
                readOnly: true,
                decoration: inputDecoration(
                  context: context,
                  labelText: locale.lblTelemedService,
                ),
                textFieldType: TextFieldType.OTHER,
              ),
              24.height,
            ],
          ],
        ),
      ),
    );
  }
}
