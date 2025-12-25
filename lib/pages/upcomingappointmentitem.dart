import 'package:yourappname/model/appointmentmodel.dart';
import 'package:yourappname/pages/appointmentdetails.dart';
import 'package:yourappname/pages/reschedule.dart';
import 'package:yourappname/pages/seereview.dart';
import 'package:yourappname/provider/appointmentprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class UpcomingAppointmentItem extends StatefulWidget {
  final AppointmentModel appointmentModel;
  final int position;

  const UpcomingAppointmentItem(this.appointmentModel, this.position,
      {super.key});

  @override
  State<UpcomingAppointmentItem> createState() =>
      _UpcomingAppointmentItemState();
}

class _UpcomingAppointmentItemState extends State<UpcomingAppointmentItem> {
  late AppointmentProvider appointmentProvider;
  ProgressDialog? prDialog;
  SharedPre sharePref = SharedPre();
  late bool isPending;
  dynamic appointStatus, statusColor;

  @override
  void initState() {
    appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);
    isPending = false;
    appointStatus = "pending";
    statusColor = pendingStatus;
    prDialog = ProgressDialog(context);

    printLog(
        "status =========> ${widget.appointmentModel.result?[widget.position].status}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          printLog("Item Clicked!");
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AppointmentDetails(widget
                        .appointmentModel.result?[widget.position].id
                        .toString() ??
                    "")),
          );
        },
        child: Stack(
          children: <Widget>[
            Card(
              clipBehavior: Clip.antiAlias,
              elevation: 3,
              color: white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        tileMode: TileMode.clamp,
                        colors: [
                          colorPrimary.withValues(alpha: 0.1),
                          white,
                          white,
                          white,
                          white
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft)),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(width: 2, color: colorAccent),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: MyNetworkImage(
                              imageUrl: widget
                                      .appointmentModel
                                      .result![widget.position]
                                      .patientProfileImage ??
                                  Constant.userPlaceholder,
                              fit: BoxFit.cover,
                              imgHeight: 65,
                              imgWidth: 65,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              MyText(
                                text: widget.appointmentModel
                                        .result![widget.position].patientName ??
                                    "",
                                fontsize: Dimens.text17Size,
                                fontweight: FontWeight.w600,
                                textalign: TextAlign.start,
                                color: textTitleColor,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: MyText(
                                      maxline: 1,
                                      text: widget
                                              .appointmentModel
                                              .result?[widget.position]
                                              .symptoms ??
                                          "",
                                      fontsize: Dimens.text14Size,
                                      fontweight: FontWeight.w400,
                                      textalign: TextAlign.start,
                                      color: otherLightColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: otherLightColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  MyText(
                                    text: widget
                                                .appointmentModel
                                                .result?[widget.position]
                                                .appointmentType
                                                .toString() ==
                                            "1"
                                        ? "online_visit"
                                        : "physical_visit",
                                    fontsize: Dimens.text13Size,
                                    overflow: TextOverflow.ellipsis,
                                    multilanguage: true,
                                    maxline: 1,
                                    fontweight: FontWeight.w600,
                                    textalign: TextAlign.start,
                                    color: otherLightColor,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: widget
                                                  .appointmentModel
                                                  .result?[widget.position]
                                                  .status
                                                  .toString() ==
                                              "1"
                                          ? pendingStatus.withValues(alpha: 0.2)
                                          : (widget
                                                      .appointmentModel
                                                      .result?[widget.position]
                                                      .status
                                                      .toString() ==
                                                  "2"
                                              ? approvedStatus.withValues(
                                                  alpha: 0.2)
                                              : (widget.appointmentModel.result?[widget.position].status
                                                          .toString() ==
                                                      "3"
                                                  ? rejectedStatus.withValues(
                                                      alpha: 0.2)
                                                  : widget
                                                              .appointmentModel
                                                              .result?[widget
                                                                  .position]
                                                              .status
                                                              .toString() ==
                                                          "4"
                                                      ? otherColor.withValues(
                                                          alpha: 0.2)
                                                      : (widget
                                                                  .appointmentModel
                                                                  .result?[widget.position]
                                                                  .status
                                                                  .toString() ==
                                                              "5"
                                                          ? approvedStatus.withValues(alpha: 0.2)
                                                          : black))),
                                    ),
                                    child: MyText(
                                      text: widget
                                                  .appointmentModel
                                                  .result?[widget.position]
                                                  .status
                                                  .toString() ==
                                              "1"
                                          ? "pending"
                                          : (widget
                                                      .appointmentModel
                                                      .result?[widget.position]
                                                      .status
                                                      .toString() ==
                                                  "2"
                                              ? "approved"
                                              : (widget
                                                          .appointmentModel
                                                          .result?[
                                                              widget.position]
                                                          .status
                                                          .toString() ==
                                                      "3"
                                                  ? "rejected"
                                                  : widget
                                                              .appointmentModel
                                                              .result?[widget
                                                                  .position]
                                                              .status
                                                              .toString() ==
                                                          "4"
                                                      ? "absent"
                                                      : (widget
                                                                  .appointmentModel
                                                                  .result?[widget
                                                                      .position]
                                                                  .status
                                                                  .toString() ==
                                                              "5"
                                                          ? "completed"
                                                          : "-"))),
                                      multilanguage: true,
                                      fontsize: Dimens.text13Size,
                                      fontweight: FontWeight.w600,
                                      textalign: TextAlign.start,
                                      color: widget
                                                  .appointmentModel
                                                  .result?[widget.position]
                                                  .status
                                                  .toString() ==
                                              "1"
                                          ? pendingStatus
                                          : (widget
                                                      .appointmentModel
                                                      .result?[widget.position]
                                                      .status
                                                      .toString() ==
                                                  "2"
                                              ? approvedStatus
                                              : (widget
                                                          .appointmentModel
                                                          .result?[
                                                              widget.position]
                                                          .status
                                                          .toString() ==
                                                      "3"
                                                  ? rejectedStatus
                                                  : widget
                                                              .appointmentModel
                                                              .result?[widget
                                                                  .position]
                                                              .status
                                                              .toString() ==
                                                          "4"
                                                      ? otherColor
                                                      : (widget
                                                                  .appointmentModel
                                                                  .result?[widget
                                                                      .position]
                                                                  .status
                                                                  .toString() ==
                                                              "5"
                                                          ? approvedStatus
                                                          : black))),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.topLeft,
                                      child: MyText(
                                        text:
                                            '${(widget.appointmentModel.result?[widget.position].startTime ?? "")} - ${(widget.appointmentModel.result?[widget.position].endTime ?? "")}',
                                        fontsize: Dimens.text13Size,
                                        overflow: TextOverflow.ellipsis,
                                        maxline: 1,
                                        fontweight: FontWeight.w500,
                                        textalign: TextAlign.start,
                                        color: textTitleColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    widget.appointmentModel.result?[widget.position].status
                                .toString() ==
                            "1"
                        ? Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    updateAppointmentStatus("3");
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    decoration: BoxDecoration(
                                        color: rejectedStatus.withValues(
                                            alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: MyText(
                                      text: "decline",
                                      fontsize: Dimens.text15Size,
                                      multilanguage: true,
                                      color: rejectedStatus,
                                      fontweight: FontWeight.w500,
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
                                    updateAppointmentStatus("2");
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    decoration: BoxDecoration(
                                        color: approvedStatus.withValues(
                                            alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: MyText(
                                      text: "accept",
                                      fontsize: Dimens.text15Size,
                                      multilanguage: true,
                                      color: approvedStatus,
                                      fontweight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : widget.appointmentModel.result?[widget.position]
                                    .status
                                    .toString() ==
                                "3"
                            ? const SizedBox.shrink()
                            : widget.appointmentModel.result?[widget.position]
                                        .status
                                        .toString() ==
                                    "5"
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 10, 20, 10),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color: colorPrimary),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: MyText(
                                            color: colorPrimary,
                                            text: "view_details",
                                            fontsize: Dimens.text15Size,
                                            multilanguage: true,
                                            fontweight: FontWeight.w500,
                                            maxline: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textalign: TextAlign.center,
                                            fontstyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => SeeReview(
                                                        doctorId: int.parse(
                                                            Constant.userID
                                                                .toString()))));
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 10, 20, 10),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: colorPrimary),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: MyText(
                                              color: colorPrimary,
                                              text: "see_review",
                                              fontsize: Dimens.text15Size,
                                              multilanguage: true,
                                              fontweight: FontWeight.w500,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textalign: TextAlign.center,
                                              fontstyle: FontStyle.normal,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : widget.appointmentModel
                                            .result?[widget.position].status
                                            .toString() ==
                                        "6"
                                    ? Row(
                                        children: <Widget>[
                                          Expanded(
                                              child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Reschedule(
                                                            appointmentID: widget
                                                                .appointmentModel
                                                                .result?[widget
                                                                    .position]
                                                                .id
                                                                .toString(),
                                                            doctorID: widget
                                                                .appointmentModel
                                                                .result?[widget
                                                                    .position]
                                                                .doctorId
                                                                .toString(),
                                                          )));
                                            },
                                            child: Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 10, 20, 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: colorPrimaryDark,
                                                      width: 1)),
                                              child: MyText(
                                                text: "reschedule",
                                                multilanguage: true,
                                                color: colorPrimaryDark,
                                                fontsize: Dimens.text14Size,
                                                fontweight: FontWeight.w500,
                                              ),
                                            ),
                                          )),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                              child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AppointmentDetails(
                                                            widget
                                                                    .appointmentModel
                                                                    .result?[widget
                                                                        .position]
                                                                    .id
                                                                    .toString() ??
                                                                "",
                                                          )));
                                            },
                                            child: Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      20, 10, 20, 10),
                                              decoration: BoxDecoration(
                                                  color: colorPrimaryDark,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: colorPrimaryDark,
                                                      width: 1)),
                                              child: MyText(
                                                text: "join_session",
                                                multilanguage: true,
                                                color: white,
                                                fontsize: Dimens.text14Size,
                                                fontweight: FontWeight.w500,
                                              ),
                                            ),
                                          )),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            Positioned(
                top: 0,
                right: 0,
                child: Stack(
                  children: [
                    MyImage(
                      imagePath: "polygon.png",
                      height: 70,
                      width: 80,
                    ),
                    Positioned(
                      top: 10,
                      right: 0,
                      child: SizedBox(
                        width: 60,
                        child: MyText(
                          text: Utils.formateDate((widget.appointmentModel
                                      .result?[widget.position].date ??
                                  "")
                              .toString()),
                          fontsize: Dimens.text12Size,
                          maxline: 2,
                          multilanguage: false,
                          color: grayDark,
                          fontweight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  void updateAppointmentStatus(String status) async {
    printLog(
        'appointmentID ==>> ${widget.appointmentModel.result?[widget.position].id}');
    printLog('status ==>> $status');

    Utils.showProgress(context, prDialog);

    await appointmentProvider.updateAppoinmentStatus(
        widget.appointmentModel.result?[widget.position].id, status);
    printLog(
        'updateAppointmentStatus loadingUpdate ==>> ${appointmentProvider.loadingUpdate}');

    if (!appointmentProvider.loadingUpdate) {
      printLog(
          'updateAppointmentStatus status ==>> ${appointmentProvider.successModel.status}');
      if (appointmentProvider.successModel.status == 200) {
        prDialog?.hide();
        // Update Other Consumer
        await appointmentProvider.getAppointmentList();
        if (!mounted) return;
        Utils.showSnackbar(
            context, appointmentProvider.successModel.message ?? "", false);
      } else {
        prDialog?.hide();
        if (!mounted) return;
        Utils.showSnackbar(
            context, appointmentProvider.successModel.message ?? "", false);
      }
    }
  }
}
