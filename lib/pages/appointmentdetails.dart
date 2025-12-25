import 'package:yourappname/pages/all_file_viewer/page/all_network_file_viewer_screen.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/pages/pdfviewpage.dart';
import 'package:yourappname/pages/videocall/page/videocallscreen.dart';
import 'package:yourappname/pages/writeprescription.dart';
import 'package:yourappname/provider/appointmentdetailprovider.dart';
import 'package:yourappname/provider/appointmentprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import '../utils/navigation_manager.dart';

class AppointmentDetails extends StatefulWidget {
  final String appoitnmentID;
  const AppointmentDetails(this.appoitnmentID, {super.key});

  @override
  State<AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
  ProgressDialog? prDialog;
  late AppointmentDetailProvider appointmentDetailProvider;
  late AppointmentProvider appointmentProvider;

  List<String> attachment = [];
  @override
  void initState() {
    appointmentDetailProvider =
        Provider.of<AppointmentDetailProvider>(context, listen: false);
    appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);
    appointmentDetailProvider.getAppointmentDetails(widget.appoitnmentID);
    prDialog = ProgressDialog(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      appBar: Utils.myAppBarWithBack(context, "appointment", true, true),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Consumer2<AppointmentDetailProvider, AppointmentProvider>(
            builder: (context, appointmentDetailProvider, appointmentProvider,
                child) {
              if (!appointmentDetailProvider.loading) {
                if (appointmentDetailProvider.appointmentModel.status == 200 &&
                    appointmentDetailProvider.appointmentModel.result != null) {
                  if ((appointmentDetailProvider
                              .appointmentModel.result?.length ??
                          0) >
                      0) {
                    if (appointmentDetailProvider
                                .appointmentModel.result?[0].attachment !=
                            null &&
                        appointmentDetailProvider
                                .appointmentModel.result?[0].attachment !=
                            "") {
                      attachment = appointmentDetailProvider
                              .appointmentModel.result?[0].attachment
                              ?.split(",") ??
                          [];
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // MyText(
                        //   text: ((appointmentDetailProvider.appointmentModel
                        //                   .result?[0].patientFullName
                        //                   .toString() ??
                        //               "")
                        //           .isNotEmpty)
                        //       ? (appointmentDetailProvider.appointmentModel
                        //               .result?[0].patientFullName
                        //               .toString() ??
                        //           "")
                        //       : guestPatient,
                        //   textalign: TextAlign.start,
                        //   color: grayDark,
                        //   maxline: 1,
                        //   fontsize: Dimens.text14Size,
                        //   fontstyle: FontStyle.normal,
                        //   fontweight: FontWeight.w500,
                        // ),
                        Card(
                          color: white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(8),
                                  shape: BoxShape.rectangle,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      clipBehavior: Clip.antiAlias,
                                      child: MyNetworkImage(
                                        imageUrl: appointmentDetailProvider
                                                .appointmentModel
                                                .result?[0]
                                                .patientImage ??
                                            Constant.userPlaceholder,
                                        fit: BoxFit.cover,
                                        imgHeight: 65,
                                        imgWidth: 65,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        color: transparent,
                                        padding: const EdgeInsets.only(
                                            left: 13, right: 13),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                MyText(
                                                  text: ((appointmentDetailProvider
                                                                  .appointmentModel
                                                                  .result?[0]
                                                                  .patientFullName
                                                                  .toString() ??
                                                              "")
                                                          .isNotEmpty)
                                                      ? (appointmentDetailProvider
                                                              .appointmentModel
                                                              .result?[0]
                                                              .patientFullName
                                                              .toString() ??
                                                          "")
                                                      : guestPatient,
                                                  textalign: TextAlign.start,
                                                  color: colorPrimaryDark,
                                                  maxline: 1,
                                                  fontsize: Dimens.text18Size,
                                                  fontstyle: FontStyle.normal,
                                                  fontweight: FontWeight.w500,
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 5, 10, 5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: appointmentDetailProvider
                                                                .appointmentModel
                                                                .result?[0]
                                                                .status
                                                                .toString() ==
                                                            "1"
                                                        ? pendingStatus.withValues(
                                                            alpha: 0.2)
                                                        : (appointmentDetailProvider
                                                                    .appointmentModel
                                                                    .result?[0]
                                                                    .status
                                                                    .toString() ==
                                                                "2"
                                                            ? approvedStatus.withValues(
                                                                alpha: 0.2)
                                                            : (appointmentDetailProvider
                                                                        .appointmentModel
                                                                        .result?[
                                                                            0]
                                                                        .status
                                                                        .toString() ==
                                                                    "3"
                                                                ? rejectedStatus.withValues(
                                                                    alpha: 0.2)
                                                                : appointmentDetailProvider
                                                                            .appointmentModel
                                                                            .result?[0]
                                                                            .status
                                                                            .toString() ==
                                                                        "4"
                                                                    ? otherColor.withValues(alpha: 0.2)
                                                                    : (appointmentDetailProvider.appointmentModel.result?[0].status.toString() == "5" ? approvedStatus.withValues(alpha: 0.2) : black))),
                                                  ),
                                                  child: MyText(
                                                    text: appointmentDetailProvider
                                                                .appointmentModel
                                                                .result?[0]
                                                                .status
                                                                .toString() ==
                                                            "1"
                                                        ? "pending"
                                                        : (appointmentDetailProvider
                                                                    .appointmentModel
                                                                    .result?[0]
                                                                    .status
                                                                    .toString() ==
                                                                "2"
                                                            ? "approved"
                                                            : (appointmentDetailProvider
                                                                        .appointmentModel
                                                                        .result?[
                                                                            0]
                                                                        .status
                                                                        .toString() ==
                                                                    "3"
                                                                ? "rejected"
                                                                : appointmentDetailProvider
                                                                            .appointmentModel
                                                                            .result?[
                                                                                0]
                                                                            .status
                                                                            .toString() ==
                                                                        "4"
                                                                    ? "absent"
                                                                    : (appointmentDetailProvider.appointmentModel.result?[0].status.toString() ==
                                                                            "5"
                                                                        ? "completed"
                                                                        : "-"))),
                                                    multilanguage: true,
                                                    textalign: TextAlign.start,
                                                    color: appointmentDetailProvider
                                                                .appointmentModel
                                                                .result?[0]
                                                                .status
                                                                .toString() ==
                                                            "1"
                                                        ? pendingStatus
                                                        : (appointmentDetailProvider
                                                                    .appointmentModel
                                                                    .result?[0]
                                                                    .status
                                                                    .toString() ==
                                                                "2"
                                                            ? approvedStatus
                                                            : (appointmentDetailProvider
                                                                        .appointmentModel
                                                                        .result?[
                                                                            0]
                                                                        .status
                                                                        .toString() ==
                                                                    "3"
                                                                ? rejectedStatus
                                                                : appointmentDetailProvider
                                                                            .appointmentModel
                                                                            .result?[
                                                                                0]
                                                                            .status
                                                                            .toString() ==
                                                                        "4"
                                                                    ? otherColor
                                                                    : (appointmentDetailProvider.appointmentModel.result?[0].status.toString() ==
                                                                            "5"
                                                                        ? approvedStatus
                                                                        : black))),
                                                    fontsize: Dimens.text12Size,
                                                    fontstyle: FontStyle.normal,
                                                    fontweight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                MyText(
                                                  text:
                                                      (appointmentDetailProvider
                                                              .appointmentModel
                                                              .result?[0]
                                                              .appointmentNo ??
                                                          "_"),
                                                  textalign: TextAlign.start,
                                                  color: grayDark,
                                                  fontsize: Dimens.text14Size,
                                                  maxline: 1,
                                                  fontstyle: FontStyle.normal,
                                                  fontweight: FontWeight.w500,
                                                ),
                                                if (appointmentDetailProvider
                                                            .appointmentModel
                                                            .result?[0]
                                                            .status
                                                            .toString() ==
                                                        "2" &&
                                                    appointmentDetailProvider
                                                            .appointmentModel
                                                            .result?[0]
                                                            .appointmentType
                                                            .toString() ==
                                                        "Online")
                                                  InkWell(
                                                    onTap: () {
                                                      _navigateToVideoCallScreen(
                                                        appointmentDetailProvider
                                                                .appointmentModel
                                                                .result?[0]
                                                                .roomId ??
                                                            "1",
                                                        appointmentDetailProvider
                                                                .appointmentModel
                                                                .result?[0]
                                                                .id
                                                                .toString() ??
                                                            "1",
                                                      );
                                                    },
                                                    child: const Icon(
                                                      Icons.call,
                                                      color: colorPrimary,
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 10, right: 10),
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                alignment: Alignment.topLeft,
                                decoration: BoxDecoration(
                                    color: lightBlue,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_rounded,
                                      color: colorPrimary,
                                      size: 25,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    MyText(
                                      text: Utils.formateDate(
                                          ((appointmentDetailProvider
                                                      .appointmentModel
                                                      .result?[0]
                                                      .date ??
                                                  ""))
                                              .toString()),
                                      fontsize: Dimens.text14Size,
                                      overflow: TextOverflow.ellipsis,
                                      maxline: 1,
                                      fontweight: FontWeight.w500,
                                      textalign: TextAlign.start,
                                      color: colorPrimaryDark,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: colorPrimary,
                                            size: 25,
                                          ),
                                          Flexible(
                                            child: MyText(
                                              text:
                                                  '  ${Utils.formateTime(((appointmentDetailProvider.appointmentModel.result?[0].startTime ?? "")))}-${Utils.formateTime(((appointmentDetailProvider.appointmentModel.result?[0].endTime ?? "")))}',
                                              fontsize: Dimens.text14Size,
                                              overflow: TextOverflow.ellipsis,
                                              maxline: 1,
                                              fontweight: FontWeight.w500,
                                              textalign: TextAlign.start,
                                              color: colorPrimaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Theme(
                                data: Theme.of(context)
                                    .copyWith(dividerColor: transparent),
                                child: ExpansionTile(
                                  collapsedIconColor: colorPrimaryDark,
                                  title: MyText(
                                    text: "details",
                                    multilanguage: true,
                                    fontsize: Dimens.text16Size,
                                    fontweight: FontWeight.w500,
                                    fontstyle: FontStyle.normal,
                                    textalign: TextAlign.start,
                                    color: colorPrimaryDark,
                                  ),
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: white,
                                        borderRadius: BorderRadius.circular(8),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          MyText(
                                            text: "patient_name",
                                            multilanguage: true,
                                            fontsize: Dimens.text12Size,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: otherLightColor,
                                          ),
                                          const SizedBox(height: 4),
                                          MyText(
                                            text: (appointmentDetailProvider
                                                        .appointmentModel
                                                        .result?[0]
                                                        .familyMemberType ==
                                                    0)
                                                ? (appointmentDetailProvider
                                                        .appointmentModel
                                                        .result?[0]
                                                        .patientFullName ??
                                                    '-')
                                                : (appointmentDetailProvider
                                                        .appointmentModel
                                                        .result?[0]
                                                        .relationPatientName ??
                                                    '-'),
                                            fontsize: Dimens.text14Size,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: textTitleColor,
                                          ),
                                          const SizedBox(height: 15),
                                          MyText(
                                            text: "contact_no",
                                            multilanguage: true,
                                            fontsize: Dimens.text12Size,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: otherLightColor,
                                          ),
                                          const SizedBox(height: 4),
                                          MyText(
                                            text: appointmentDetailProvider
                                                    .appointmentModel
                                                    .result?[0]
                                                    .patientMobileNumber ??
                                                '-',
                                            fontsize: Dimens.text14Size,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: textTitleColor,
                                          ),
                                          const SizedBox(height: 15),
                                          // Row(
                                          //   mainAxisSize: MainAxisSize.max,
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.start,
                                          //   crossAxisAlignment:
                                          //       CrossAxisAlignment.start,
                                          //   children: [
                                          //     Expanded(
                                          //       child: Column(
                                          //         mainAxisSize: MainAxisSize.min,
                                          //         mainAxisAlignment:
                                          //             MainAxisAlignment.start,
                                          //         crossAxisAlignment:
                                          //             CrossAxisAlignment.start,
                                          //         children: [
                                          //           MyText(
                                          //             text: "date",
                                          //             multilanguage: true,
                                          //             fontsize: Dimens.text12Size,
                                          //             fontweight:
                                          //                 FontWeight.normal,
                                          //             fontstyle: FontStyle.normal,
                                          //             textalign: TextAlign.start,
                                          //             color: otherLightColor,
                                          //           ),
                                          //           const SizedBox(height: 4),
                                          //           MyText(
                                          //             text: Utils.formateDate(
                                          //                 appointmentDetailProvider
                                          //                     .appointmentModel
                                          //                     .result![0]
                                          //                     .date
                                          //                     .toString()),
                                          //             fontsize: Dimens.text14Size,
                                          //             fontweight:
                                          //                 FontWeight.normal,
                                          //             maxline: 1,
                                          //             overflow:
                                          //                 TextOverflow.ellipsis,
                                          //             fontstyle: FontStyle.normal,
                                          //             textalign: TextAlign.start,
                                          //             color: textTitleColor,
                                          //           ),
                                          //         ],
                                          //       ),
                                          //     ),
                                          //     Expanded(
                                          //       child: Column(
                                          //         mainAxisSize: MainAxisSize.min,
                                          //         mainAxisAlignment:
                                          //             MainAxisAlignment.start,
                                          //         crossAxisAlignment:
                                          //             CrossAxisAlignment.start,
                                          //         children: [
                                          //           MyText(
                                          //             text: "time",
                                          //             multilanguage: true,
                                          //             fontsize: Dimens.text12Size,
                                          //             fontweight:
                                          //                 FontWeight.normal,
                                          //             fontstyle: FontStyle.normal,
                                          //             textalign: TextAlign.start,
                                          //             color: otherLightColor,
                                          //           ),
                                          //           const SizedBox(height: 4),
                                          //           MyText(
                                          //             text:
                                          //                 '${Utils.formateTime(appointmentDetailProvider.appointmentModel.result?[0].startTime ?? "")} - ${Utils.formateTime(appointmentDetailProvider.appointmentModel.result?[0].endTime ?? "")}',
                                          //             fontsize: Dimens.text14Size,
                                          //             maxline: 1,
                                          //             overflow:
                                          //                 TextOverflow.ellipsis,
                                          //             fontweight:
                                          //                 FontWeight.normal,
                                          //             fontstyle: FontStyle.normal,
                                          //             textalign: TextAlign.start,
                                          //             color: textTitleColor,
                                          //           ),
                                          //         ],
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          // const SizedBox(height: 15),
                                          MyText(
                                            text: "email_address",
                                            multilanguage: true,
                                            fontsize: Dimens.text12Size,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: otherLightColor,
                                          ),
                                          const SizedBox(height: 4),
                                          MyText(
                                            text: appointmentDetailProvider
                                                    .appointmentModel
                                                    .result?[0]
                                                    .patientEmail ??
                                                '-',
                                            fontsize: Dimens.text14Size,
                                            maxline: 1,
                                            overflow: TextOverflow.ellipsis,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: textTitleColor,
                                          ),
                                          const SizedBox(height: 15),
                                          MyText(
                                            text: "allergies_to_medicine",
                                            multilanguage: true,
                                            fontsize: Dimens.text12Size,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: otherLightColor,
                                          ),
                                          const SizedBox(height: 4),
                                          MyText(
                                            text: appointmentDetailProvider
                                                    .appointmentModel
                                                    .result?[0]
                                                    .allergiesToMedicine ??
                                                '-',
                                            fontsize: Dimens.text14Size,
                                            maxline: 3,
                                            overflow: TextOverflow.ellipsis,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: textTitleColor,
                                          ),
                                          const SizedBox(height: 15),
                                          MyText(
                                            text: "symptoms",
                                            multilanguage: true,
                                            fontsize: Dimens.text12Size,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: otherLightColor,
                                          ),
                                          const SizedBox(height: 4),
                                          MyText(
                                            text: appointmentDetailProvider
                                                    .appointmentModel
                                                    .result?[0]
                                                    .symptoms ??
                                                '-',
                                            fontsize: Dimens.text14Size,
                                            maxline: 2,
                                            overflow: TextOverflow.ellipsis,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: textTitleColor,
                                          ),
                                          const SizedBox(height: 15),
                                          MyText(
                                            text: "medicine_taken",
                                            multilanguage: true,
                                            fontsize: Dimens.text12Size,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: otherLightColor,
                                          ),
                                          const SizedBox(height: 4),
                                          MyText(
                                            text: appointmentDetailProvider
                                                    .appointmentModel
                                                    .result?[0]
                                                    .medicinesTaken
                                                    .toString() ??
                                                '-',
                                            fontsize: Dimens.text14Size,
                                            maxline: 2,
                                            overflow: TextOverflow.ellipsis,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: textTitleColor,
                                          ),
                                          const SizedBox(height: 15),
                                          MyText(
                                            text: "description",
                                            multilanguage: true,
                                            fontsize: Dimens.text12Size,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: otherLightColor,
                                          ),
                                          const SizedBox(height: 4),
                                          MyText(
                                            text: appointmentDetailProvider
                                                    .appointmentModel
                                                    .result?[0]
                                                    .notes
                                                    .toString() ??
                                                '-',
                                            multilanguage: false,
                                            fontsize: Dimens.text14Size,
                                            maxline: 5,
                                            overflow: TextOverflow.ellipsis,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: textTitleColor,
                                          ),
                                          const SizedBox(height: 15),
                                          MyText(
                                            text: "attachment",
                                            multilanguage: true,
                                            fontsize: Dimens.text12Size,
                                            fontweight: FontWeight.normal,
                                            fontstyle: FontStyle.normal,
                                            textalign: TextAlign.start,
                                            color: otherLightColor,
                                          ),
                                          const SizedBox(height: 4),
                                          attachment.isNotEmpty
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 15),
                                                  child: SizedBox(
                                                    height: 150,
                                                    child: ListView.separated(
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              _navigateToFullPhotoScreen(
                                                                  attachment[
                                                                      index]);
                                                            },
                                                            child: MyNetworkImage(
                                                                imgWidth: 100,
                                                                imageUrl:
                                                                    attachment[
                                                                        index],
                                                                fit: BoxFit
                                                                    .fill),
                                                          );
                                                        },
                                                        separatorBuilder:
                                                            (context, index) =>
                                                                const SizedBox(
                                                                  width: 20,
                                                                ),
                                                        itemCount:
                                                            attachment.length),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                          appointmentDetailProvider
                                                      .appointmentModel
                                                      .result?[0]
                                                      .status
                                                      .toString() ==
                                                  "1"
                                              ? Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          updateAppointmentStatus(
                                                              "3");
                                                        },
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  0, 10, 0, 10),
                                                          decoration: BoxDecoration(
                                                              color: rejectedStatus
                                                                  .withValues(
                                                                      alpha:
                                                                          0.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                          child: MyText(
                                                            text: "decline",
                                                            fontsize: Dimens
                                                                .text15Size,
                                                            multilanguage: true,
                                                            color:
                                                                rejectedStatus,
                                                            fontweight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          updateAppointmentStatus(
                                                              "2");
                                                        },
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  0, 10, 0, 10),
                                                          decoration: BoxDecoration(
                                                              color: approvedStatus
                                                                  .withValues(
                                                                      alpha:
                                                                          0.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                          child: MyText(
                                                            text: "accept",
                                                            fontsize: Dimens
                                                                .text15Size,
                                                            multilanguage: true,
                                                            color:
                                                                approvedStatus,
                                                            fontweight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox()
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Visibility(
                            visible: appointmentDetailProvider
                                        .appointmentModel.result?[0].status
                                        .toString() ==
                                    "2"
                                ? true
                                : false,
                            child: downalodPrescription(
                              appointmentDetailProvider
                                      .appointmentModel.result?[0].id
                                      .toString() ??
                                  "",
                              appointmentDetailProvider
                                      .appointmentModel.result?[0].appointmentNo
                                      .toString() ??
                                  "",
                              appointmentDetailProvider
                                      .appointmentModel.result?[0].patientId
                                      .toString() ??
                                  "",
                              appointmentDetailProvider.appointmentModel
                                      .result?[0].patientFullName
                                      .toString() ??
                                  "",
                              appointmentDetailProvider
                                      .appointmentModel.result?[0].patientImage
                                      .toString() ??
                                  "",
                              appointmentDetailProvider
                                      .appointmentModel.result?[0].date
                                      .toString() ??
                                  "",
                              appointmentDetailProvider
                                      .appointmentModel.result?[0].startTime
                                      .toString() ??
                                  "",
                              appointmentDetailProvider
                                      .appointmentModel.result?[0].symptoms
                                      .toString() ??
                                  "",
                              appointmentDetailProvider
                                      .appointmentModel.result?[0].status
                                      .toString() ??
                                  "",
                              appointmentDetailProvider
                                      .appointmentModel.result?[0].endTime
                                      .toString() ??
                                  "",
                              appointmentDetailProvider.appointmentModel
                                      .result?[0].patientFirebaseId
                                      .toString() ??
                                  "",
                            )),
                        Visibility(
                          visible: appointmentDetailProvider
                                      .appointmentModel.result?[0].status
                                      .toString() ==
                                  "5"
                              ? true
                              : false,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PdfViewPage(
                                          id: appointmentDetailProvider
                                              .appointmentModel.result?[0].id
                                              .toString(),
                                          title: appointmentDetailProvider
                                              .appointmentModel
                                              .result?[0]
                                              .doctorFullName
                                              .toString())));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: Constant.buttonHeight,
                              decoration: BoxDecoration(
                                color: colorPrimary,
                                borderRadius: BorderRadius.circular(5),
                                shape: BoxShape.rectangle,
                              ),
                              alignment: Alignment.center,
                              child: MyText(
                                text: "see_prescription",
                                multilanguage: true,
                                color: white,
                                textalign: TextAlign.center,
                                fontsize: Dimens.text16Size,
                                fontweight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  } else {
                    return const NoData(text: '');
                  }
                } else {
                  return const NoData(text: '');
                }
              } else {
                return detailsShimmer();
              }
            },
          ),
        ),
      ),
    );
  }

  _navigateToVideoCallScreen(String roomId, String appoinmentId) async {
    bool result = await Utils().requestPermissions(
        context, [Permission.camera, Permission.microphone]);
    // appointment_calling API
    appointmentProvider.appoinmentCalling(appoinmentId);
    if (result == true) {
      if (!mounted) return;
      await navigateToPage(
          context: context,
          route: VideoCallScreen(
              roomId: roomId, userId: "doctor_12${Constant.userID}"));
    } else {
      Utils.showToast("Please give nescessary permission");
    }
  }

  Widget downalodPrescription(id, aptNo, patientID, patientNAME, patientImage,
      dates, starttime, symtoms, status, endTime, doctorFirebaceID) {
    return Container(
      padding: const EdgeInsets.all(0),
      height: 245,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: MyImage(
              imagePath: 'download_prescriptionbg.png',
              height: 180,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
              top: 15,
              left: 20,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: "write",
                      multilanguage: true,
                      fontsize: Dimens.text24Size,
                      color: colorPrimary,
                      fontweight: FontWeight.w700,
                    ),
                    MyText(
                      text: "prescription_",
                      fontsize: Dimens.text24Size,
                      multilanguage: true,
                      color: colorPrimary,
                      fontweight: FontWeight.w700,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    MyText(
                      maxline: 3,
                      text:
                          "${Locales.string(context, "sentyouby")} ${appointmentDetailProvider.appointmentModel.result?[0].doctorFullName.toString() ?? ""}, ${Locales.string(context, "lastcheckupprescription")}",
                      fontsize: Dimens.text12Size,
                      color: textTitleColor,
                      fontweight: FontWeight.w500,
                    )
                  ],
                ),
              )),
          Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => WritePrescription(
                        id,
                        aptNo,
                        patientID,
                        patientNAME,
                        patientImage,
                        dates,
                        doctorFirebaceID,
                        starttime,
                        symtoms,
                        status,
                        endTime,
                      ),
                    ),
                  )
                      .then(
                    (value) {
                      appointmentDetailProvider
                          .getAppointmentDetails(widget.appoitnmentID);
                    },
                  );
                },
                child: Stack(children: [
                  MyImage(
                    width: MediaQuery.of(context).size.width,
                    imagePath: "downloadbg.png",
                    height: 80,
                  ),
                  Positioned.fill(
                    top: -20,
                    child: Align(
                      alignment: Alignment.center,
                      child: MyText(
                        maxline: 1,
                        text: "click_prescription",
                        multilanguage: true,
                        fontsize: Dimens.text14Size,
                        color: white,
                        fontweight: FontWeight.w500,
                      ),
                    ),
                  )
                ]),
              ))
        ],
      ),
    );
  }

  Widget detailsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomWidget.roundcorner(
          height: 15,
          width: 100,
        ),
        Card(
          color: white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(8),
                  shape: BoxShape.rectangle,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      clipBehavior: Clip.antiAlias,
                      child: const CustomWidget.roundcorner(
                        height: 65,
                        width: 65,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 13, right: 13),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CustomWidget.roundcorner(
                              height: 15,
                              width: 65,
                            ),
                            SizedBox(height: 10),
                            CustomWidget.roundcorner(
                              height: 12,
                              width: 65,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const CustomWidget.roundcorner(
                      height: 20,
                      width: 70,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                    color: lightBlue, borderRadius: BorderRadius.circular(4)),
                child: const Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: colorPrimary,
                      size: 25,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CustomWidget.roundcorner(
                      height: 15,
                      width: 50,
                    ),
                    Spacer(),
                    Icon(
                      Icons.access_time,
                      color: colorPrimary,
                      size: 25,
                    ),
                    Expanded(
                      child: CustomWidget.roundcorner(
                        height: 15,
                        width: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        CustomWidget.roundcorner(
          height: 200,
          width: MediaQuery.of(context).size.width,
        ),
      ],
    );
  }

  void updateAppointmentStatus(String status) async {
    printLog('appointmentID ==>> ${widget.appoitnmentID}');
    printLog('status ==>> $status');
    final detailProvider =
        Provider.of<AppointmentDetailProvider>(context, listen: false);

    // appoinment_status_update API call
    Utils.showProgress(context, prDialog);
    await detailProvider.updateAppoinmentStatus(widget.appoitnmentID, status);

    printLog('updateAppointmentStatus loading ==>> ${detailProvider.loading}');
    if (!detailProvider.loading) {
      printLog(
          'updateAppointmentStatus status ==>> ${detailProvider.successModel.status}');
      if (detailProvider.successModel.status == 200) {
        // Update Consumer
        await detailProvider.getAppointmentDetails(widget.appoitnmentID);

        prDialog?.hide();
        if (!mounted) return;
        Utils.showSnackbar(
            context, detailProvider.successModel.message ?? "", false);
      } else {
        prDialog?.hide();
        if (!mounted) return;
        Utils.showSnackbar(
            context, detailProvider.successModel.message ?? "", false);
      }
    }
  }

  _navigateToFullPhotoScreen(String url) async {
    await navigateToPage(context: context, route: NetworkFileViewer(url: url));
  }
}
