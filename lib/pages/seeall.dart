import 'package:yourappname/pages/appointmentdetails.dart';
import 'package:yourappname/pages/chatscreen.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/pages/reschedule.dart';
import 'package:yourappname/pages/seereview.dart';
import 'package:yourappname/provider/seeallprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/shimmerutils.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ep.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class SeeAll extends StatefulWidget {
  final String type;
  const SeeAll({super.key, required this.type});

  @override
  State<SeeAll> createState() => _SeeAllState();
}

class _SeeAllState extends State<SeeAll> {
  SharedPre sharePref = SharedPre();
  late ScrollController _scrollController;
  late SeeallProvider appointmentProvider;
  ProgressDialog? prDialog;

  @override
  void initState() {
    appointmentProvider = Provider.of<SeeallProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    prDialog = ProgressDialog(context);

    getApi(0);

    super.initState();
  }

  @override
  void dispose() {
    appointmentProvider.clearProvider();
    super.dispose();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (appointmentProvider.pendingcurrentPage ?? 0) <
            (appointmentProvider.pendingtotalPage ?? 0)) {
      await appointmentProvider.setLoadMore(true);
      await getApi((appointmentProvider.pendingcurrentPage ?? 0));
    }
  }

  getApi(pageNo) {
    if (widget.type == "pending_appointments") {
      appointmentProvider.getPendingAppointment((pageNo + 1).toString());
    } else if (widget.type == "today_appointments") {
      appointmentProvider.getTodayAppointment((pageNo + 1).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.myAppBar(context, appointments),
      body: Container(
        margin: const EdgeInsets.only(top: 14),
        child: widget.type == "pending_appointments"
            ? pendingAppintment()
            : todayAppintment(),
      ),
    );
  }

  Widget pendingAppintment() {
    return Consumer<SeeallProvider>(
      builder: (context, appointmentProvider, child) {
        if (appointmentProvider.loading &&
            appointmentProvider.loadmore == false) {
          return apoointMentShimmer();
        } else {
          if (appointmentProvider.appointmentModel.status == 200 &&
              appointmentProvider.appointmentModel.result != null) {
            if ((appointmentProvider.pendingAppointmentList?.length ?? 0) > 0) {
              return SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount:
                          appointmentProvider.pendingAppointmentList?.length ??
                              0,
                      itemBuilder: (BuildContext context, int position) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: const EdgeInsets.only(top: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              printLog("Item Clicked!");
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AppointmentDetails(
                                    appointmentProvider
                                            .pendingAppointmentList?[position]
                                            .id
                                            .toString() ??
                                        "",
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: <Widget>[
                                Card(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 15, 10, 15),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            tileMode: TileMode.clamp,
                                            colors: [
                                              colorPrimary.withValues(
                                                  alpha: 0.3),
                                              colorPrimary.withValues(
                                                  alpha: 0.2),
                                              colorPrimary.withValues(
                                                  alpha: 0.1),
                                              transparent,
                                              transparent,
                                            ],
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              clipBehavior: Clip.antiAlias,
                                              child: MyNetworkImage(
                                                imageUrl: appointmentProvider
                                                        .pendingAppointmentList?[
                                                            position]
                                                        .patientProfileImage
                                                        .toString() ??
                                                    Constant.userPlaceholder,
                                                fit: BoxFit.cover,
                                                imgHeight: 65,
                                                imgWidth: 65,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  MyText(
                                                    text: appointmentProvider
                                                            .pendingAppointmentList?[
                                                                position]
                                                            .patientName ??
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      MyText(
                                                        text: appointmentProvider
                                                                    .pendingAppointmentList?[
                                                                        position]
                                                                    .appointmentType
                                                                    .toString() ==
                                                                "1"
                                                            ? "online_visit"
                                                            : "physical_visit",
                                                        fontsize:
                                                            Dimens.text13Size,
                                                        fontweight:
                                                            FontWeight.w600,
                                                        multilanguage: true,
                                                        textalign:
                                                            TextAlign.start,
                                                        color:
                                                            grayDark.withValues(
                                                                alpha: 0.8),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Container(
                                                        width: 4,
                                                        height: 4,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: otherColor,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: MyText(
                                                          maxline: 1,
                                                          text: appointmentProvider
                                                                  .pendingAppointmentList?[
                                                                      position]
                                                                  .symptoms ??
                                                              "",
                                                          fontsize:
                                                              Dimens.text13Size,
                                                          fontweight:
                                                              FontWeight.w600,
                                                          textalign:
                                                              TextAlign.start,
                                                          color: grayDark
                                                              .withValues(
                                                                  alpha: 0.8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                10, 5, 10, 5),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: appointmentProvider
                                                                            .pendingAppointmentList?[
                                                                                position]
                                                                            .status
                                                                            .toString() ==
                                                                        "1"
                                                                    ? pendingStatus
                                                                        .withValues(
                                                                            alpha:
                                                                                0.15)
                                                                    : (appointmentProvider.pendingAppointmentList?[position].status.toString() ==
                                                                            "2"
                                                                        ? completedStatus.withValues(
                                                                            alpha:
                                                                                0.2)
                                                                        : (appointmentProvider.pendingAppointmentList?[position].status.toString() ==
                                                                                "3"
                                                                            ? rejectedStatus.withValues(alpha: 0.5)
                                                                            : appointmentProvider.pendingAppointmentList?[position].status.toString() == "4"
                                                                                ? otherColor.withValues(alpha: 0.5)
                                                                                : (appointmentProvider.pendingAppointmentList?[position].status.toString() == "5" ? completedStatus.withValues(alpha: 0.2) : black.withValues(alpha: 0.3)))),
                                                                borderRadius: BorderRadius.circular(8)),
                                                        child: MyText(
                                                          text: appointmentProvider
                                                                      .pendingAppointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "1"
                                                              ? "pending"
                                                              : (appointmentProvider
                                                                          .pendingAppointmentList?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "2"
                                                                  ? "approved"
                                                                  : (appointmentProvider
                                                                              .pendingAppointmentList?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "3"
                                                                      ? "rejected"
                                                                      : appointmentProvider.pendingAppointmentList?[position].status.toString() ==
                                                                              "4"
                                                                          ? "absent"
                                                                          : (appointmentProvider.pendingAppointmentList?[position].status.toString() == "5"
                                                                              ? "completed"
                                                                              : "-"))),
                                                          multilanguage: true,
                                                          fontsize:
                                                              Dimens.text12Size,
                                                          fontweight:
                                                              FontWeight.w600,
                                                          textalign:
                                                              TextAlign.start,
                                                          color: appointmentProvider
                                                                      .pendingAppointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "1"
                                                              ? pendingStatus
                                                              : (appointmentProvider
                                                                          .pendingAppointmentList?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "2"
                                                                  ? completedStatus
                                                                  : (appointmentProvider
                                                                              .pendingAppointmentList?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "3"
                                                                      ? rejectedStatus
                                                                      : appointmentProvider.pendingAppointmentList?[position].status.toString() ==
                                                                              "4"
                                                                          ? otherColor
                                                                          : (appointmentProvider.pendingAppointmentList?[position].status.toString() == "5"
                                                                              ? completedStatus
                                                                              : black))),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: MyText(
                                                          text:
                                                              '${Utils.formateTime(appointmentProvider.pendingAppointmentList?[position].startTime ?? "")} - ${Utils.formateTime(appointmentProvider.pendingAppointmentList?[position].endTime ?? "")}',
                                                          fontsize:
                                                              Dimens.text13Size,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxline: 1,
                                                          fontweight:
                                                              FontWeight.w500,
                                                          textalign:
                                                              TextAlign.start,
                                                          color: grayDark,
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
                                          height: 20,
                                        ),
                                        appointmentProvider
                                                    .pendingAppointmentList?[
                                                        position]
                                                    .status
                                                    .toString() ==
                                                "1"
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        updateAppointmentStatus(
                                                            "3", position);
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
                                                                    alpha: 0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        child: MyText(
                                                          text: "decline",
                                                          fontsize:
                                                              Dimens.text15Size,
                                                          multilanguage: true,
                                                          color: rejectedStatus,
                                                          fontweight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        updateAppointmentStatus(
                                                            "2", position);
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
                                                                    alpha: 0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        child: MyText(
                                                          text: "accept",
                                                          fontsize:
                                                              Dimens.text15Size,
                                                          multilanguage: true,
                                                          color: approvedStatus,
                                                          fontweight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : appointmentProvider
                                                        .pendingAppointmentList?[
                                                            position]
                                                        .status
                                                        .toString() ==
                                                    "3"
                                                ? const SizedBox.shrink()
                                                : appointmentProvider
                                                            .pendingAppointmentList?[
                                                                position]
                                                            .status
                                                            .toString() ==
                                                        "2"
                                                    ? Row(
                                                        children: [
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            Chatscreen(
                                                                              toUserName: appointmentProvider.pendingAppointmentList?[position].patientName.toString() ?? "",
                                                                              toChatId: appointmentProvider.pendingAppointmentList?[position].patientFirebaseId.toString() ?? "",
                                                                              profileImg: appointmentProvider.pendingAppointmentList?[position].patientProfileImage.toString() ?? "",
                                                                              bioData: "",
                                                                            )));
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        20,
                                                                        10,
                                                                        20,
                                                                        10),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color:
                                                                            colorPrimary),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Iconify(
                                                                      Ep.chat_line_round,
                                                                      color:
                                                                          colorPrimary,
                                                                      size: 22,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    MyText(
                                                                      color:
                                                                          colorPrimary,
                                                                      text:
                                                                          "chat",
                                                                      fontsize:
                                                                          Dimens
                                                                              .text15Size,
                                                                      multilanguage:
                                                                          true,
                                                                      fontweight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxline:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textalign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal,
                                                                    ),
                                                                  ],
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
                                                                Utils.showToast(
                                                                    videocallfeaturenotavailable);
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10,
                                                                        10,
                                                                        10,
                                                                        10),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color:
                                                                            colorPrimary),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Iconify(
                                                                      Ph.phone_call_light,
                                                                      color:
                                                                          colorPrimary,
                                                                      size: 22,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Flexible(
                                                                      child:
                                                                          MyText(
                                                                        color:
                                                                            colorPrimary,
                                                                        text:
                                                                            "call",
                                                                        fontsize:
                                                                            Dimens.text15Size,
                                                                        multilanguage:
                                                                            true,
                                                                        fontweight:
                                                                            FontWeight.w500,
                                                                        maxline:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        textalign:
                                                                            TextAlign.center,
                                                                        fontstyle:
                                                                            FontStyle.normal,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : appointmentProvider
                                                                .pendingAppointmentList?[
                                                                    position]
                                                                .status
                                                                .toString() ==
                                                            "5"
                                                        ? Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          10,
                                                                          20,
                                                                          10),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              colorPrimary),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: MyText(
                                                                    color:
                                                                        colorPrimary,
                                                                    text:
                                                                        "view_details",
                                                                    fontsize: Dimens
                                                                        .text15Size,
                                                                    multilanguage:
                                                                        true,
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w500,
                                                                    maxline: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    textalign:
                                                                        TextAlign
                                                                            .center,
                                                                    fontstyle:
                                                                        FontStyle
                                                                            .normal,
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
                                                                            builder: (context) =>
                                                                                SeeReview(doctorId: int.parse(Constant.userID.toString()))));
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .fromLTRB(
                                                                            20,
                                                                            10,
                                                                            20,
                                                                            10),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            width:
                                                                                1,
                                                                            color:
                                                                                colorPrimary),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child:
                                                                        MyText(
                                                                      color:
                                                                          colorPrimary,
                                                                      text:
                                                                          "see_review",
                                                                      fontsize:
                                                                          Dimens
                                                                              .text15Size,
                                                                      multilanguage:
                                                                          true,
                                                                      fontweight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxline:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textalign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        : appointmentProvider
                                                                    .pendingAppointmentList?[
                                                                        position]
                                                                    .status
                                                                    .toString() ==
                                                                "6"
                                                            ? Row(
                                                                children: <Widget>[
                                                                  Expanded(
                                                                      child:
                                                                          InkWell(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => Reschedule(
                                                                                    appointmentID: appointmentProvider.pendingAppointmentList?[position].id.toString(),
                                                                                    doctorID: appointmentProvider.pendingAppointmentList?[position].doctorId.toString(),
                                                                                  ))).then(
                                                                        (value) async {
                                                                          await getApi((appointmentProvider.pendingcurrentPage ??
                                                                              0));
                                                                        },
                                                                      );
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          10,
                                                                          20,
                                                                          10),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10),
                                                                          border: Border.all(
                                                                              color: colorPrimaryDark,
                                                                              width: 1)),
                                                                      child:
                                                                          MyText(
                                                                        text:
                                                                            "reschedule",
                                                                        multilanguage:
                                                                            true,
                                                                        color:
                                                                            colorPrimaryDark,
                                                                        fontsize:
                                                                            Dimens.text14Size,
                                                                        fontweight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  )),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          InkWell(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => AppointmentDetails(appointmentProvider.pendingAppointmentList?[position].id.toString() ?? "")));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          10,
                                                                          20,
                                                                          10),
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              colorPrimaryDark,
                                                                          borderRadius: BorderRadius.circular(
                                                                              10),
                                                                          border: Border.all(
                                                                              color: colorPrimaryDark,
                                                                              width: 1)),
                                                                      child:
                                                                          MyText(
                                                                        text:
                                                                            "join_session",
                                                                        multilanguage:
                                                                            true,
                                                                        color:
                                                                            white,
                                                                        fontsize:
                                                                            Dimens.text14Size,
                                                                        fontweight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  )),
                                                                ],
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
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
                                              text: Utils.formateDate(
                                                  (appointmentProvider
                                                              .pendingAppointmentList?[
                                                                  position]
                                                              .date ??
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
                      },
                    ),
                    Consumer<SeeallProvider>(
                      builder: (context, viewallprovider, child) {
                        if (viewallprovider.loadmore) {
                          return Utils.pageLoader();
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const NoData(text: '');
            }
          } else {
            return const NoData(text: '');
          }
        }
      },
    );
  }

  Widget todayAppintment() {
    return Consumer<SeeallProvider>(
      builder: (context, appointmentProvider, child) {
        if (appointmentProvider.todayLoading &&
            appointmentProvider.loadmore == false) {
          return apoointMentShimmer();
        } else {
          if (appointmentProvider.todayAppointmentModel.status == 200 &&
              appointmentProvider.todayAppointmentModel.result != null) {
            if ((appointmentProvider.todayAppointmentList?.length ?? 0) > 0) {
              return SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(10),
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount:
                          appointmentProvider.todayAppointmentList?.length ?? 0,
                      itemBuilder: (BuildContext context, int position) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: const EdgeInsets.only(top: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              printLog("Item Clicked!");
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AppointmentDetails(
                                    appointmentProvider
                                            .todayAppointmentList?[position].id
                                            .toString() ??
                                        "",
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: <Widget>[
                                Card(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 12, 15, 12),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            tileMode: TileMode.clamp,
                                            colors: [
                                              colorPrimary.withValues(
                                                  alpha: 0.3),
                                              colorPrimary.withValues(
                                                  alpha: 0.2),
                                              colorPrimary.withValues(
                                                  alpha: 0.1),
                                              transparent,
                                              transparent,
                                            ],
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                              clipBehavior: Clip.antiAlias,
                                              child: MyNetworkImage(
                                                imageUrl: appointmentProvider
                                                        .todayAppointmentList?[
                                                            position]
                                                        .patientProfileImage
                                                        .toString() ??
                                                    Constant.userPlaceholder,
                                                fit: BoxFit.cover,
                                                imgHeight: 65,
                                                imgWidth: 65,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  MyText(
                                                    text: appointmentProvider
                                                            .todayAppointmentList?[
                                                                position]
                                                            .patientName ??
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
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      MyText(
                                                        text: appointmentProvider
                                                                    .todayAppointmentList?[
                                                                        position]
                                                                    .appointmentType
                                                                    .toString() ==
                                                                "1"
                                                            ? "online_visit"
                                                            : "physical_visit",
                                                        fontsize:
                                                            Dimens.text13Size,
                                                        fontweight:
                                                            FontWeight.w600,
                                                        multilanguage: true,
                                                        textalign:
                                                            TextAlign.start,
                                                        color:
                                                            grayDark.withValues(
                                                                alpha: 0.8),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Container(
                                                        width: 4,
                                                        height: 4,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: otherColor,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: MyText(
                                                          maxline: 1,
                                                          text: appointmentProvider
                                                                  .todayAppointmentList?[
                                                                      position]
                                                                  .symptoms ??
                                                              "",
                                                          fontsize:
                                                              Dimens.text13Size,
                                                          fontweight:
                                                              FontWeight.w600,
                                                          textalign:
                                                              TextAlign.start,
                                                          color: grayDark
                                                              .withValues(
                                                                  alpha: 0.8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                10, 5, 10, 5),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: appointmentProvider
                                                                            .todayAppointmentList?[
                                                                                position]
                                                                            .status
                                                                            .toString() ==
                                                                        "1"
                                                                    ? pendingStatus
                                                                        .withValues(
                                                                            alpha:
                                                                                0.15)
                                                                    : (appointmentProvider.todayAppointmentList?[position].status.toString() ==
                                                                            "2"
                                                                        ? completedStatus.withValues(
                                                                            alpha:
                                                                                0.2)
                                                                        : (appointmentProvider.todayAppointmentList?[position].status.toString() ==
                                                                                "3"
                                                                            ? rejectedStatus.withValues(alpha: 0.5)
                                                                            : appointmentProvider.todayAppointmentList?[position].status.toString() == "4"
                                                                                ? otherColor.withValues(alpha: 0.5)
                                                                                : (appointmentProvider.todayAppointmentList?[position].status.toString() == "5" ? completedStatus.withValues(alpha: 0.2) : black.withValues(alpha: 0.3)))),
                                                                borderRadius: BorderRadius.circular(8)),
                                                        child: MyText(
                                                          text: appointmentProvider
                                                                      .todayAppointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "1"
                                                              ? "pending"
                                                              : (appointmentProvider
                                                                          .todayAppointmentList?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "2"
                                                                  ? "approved"
                                                                  : (appointmentProvider
                                                                              .todayAppointmentList?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "3"
                                                                      ? "rejected"
                                                                      : appointmentProvider.todayAppointmentList?[position].status.toString() ==
                                                                              "4"
                                                                          ? "absent"
                                                                          : (appointmentProvider.todayAppointmentList?[position].status.toString() == "5"
                                                                              ? "completed"
                                                                              : "-"))),
                                                          multilanguage: true,
                                                          fontsize:
                                                              Dimens.text12Size,
                                                          fontweight:
                                                              FontWeight.w600,
                                                          textalign:
                                                              TextAlign.start,
                                                          color: appointmentProvider
                                                                      .todayAppointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "1"
                                                              ? pendingStatus
                                                              : (appointmentProvider
                                                                          .todayAppointmentList?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "2"
                                                                  ? completedStatus
                                                                  : (appointmentProvider
                                                                              .todayAppointmentList?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "3"
                                                                      ? rejectedStatus
                                                                      : appointmentProvider.todayAppointmentList?[position].status.toString() ==
                                                                              "4"
                                                                          ? otherColor
                                                                          : (appointmentProvider.todayAppointmentList?[position].status.toString() == "5"
                                                                              ? completedStatus
                                                                              : black))),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: MyText(
                                                          text:
                                                              '${Utils.formateTime(appointmentProvider.todayAppointmentList?[position].startTime ?? "")} - ${Utils.formateTime(appointmentProvider.todayAppointmentList?[position].endTime ?? "")}',
                                                          fontsize:
                                                              Dimens.text13Size,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxline: 1,
                                                          fontweight:
                                                              FontWeight.w500,
                                                          textalign:
                                                              TextAlign.start,
                                                          color: grayDark,
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
                                          height: 20,
                                        ),
                                        appointmentProvider
                                                    .todayAppointmentList?[
                                                        position]
                                                    .status
                                                    .toString() ==
                                                "1"
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        updateAppointmentStatus(
                                                            "3", position);
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
                                                                    alpha: 0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        child: MyText(
                                                          text: "decline",
                                                          fontsize:
                                                              Dimens.text15Size,
                                                          multilanguage: true,
                                                          color: rejectedStatus,
                                                          fontweight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        updateAppointmentStatus(
                                                            "2", position);
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
                                                                    alpha: 0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8)),
                                                        child: MyText(
                                                          text: "accept",
                                                          fontsize:
                                                              Dimens.text15Size,
                                                          multilanguage: true,
                                                          color: approvedStatus,
                                                          fontweight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : appointmentProvider
                                                        .todayAppointmentList?[
                                                            position]
                                                        .status
                                                        .toString() ==
                                                    "3"
                                                ? const SizedBox.shrink()
                                                : appointmentProvider
                                                            .todayAppointmentList?[
                                                                position]
                                                            .status
                                                            .toString() ==
                                                        "2"
                                                    ? Row(
                                                        children: [
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            Chatscreen(
                                                                              toUserName: appointmentProvider.todayAppointmentList?[position].patientName.toString() ?? "",
                                                                              toChatId: appointmentProvider.todayAppointmentList?[position].patientFirebaseId.toString() ?? "",
                                                                              profileImg: appointmentProvider.todayAppointmentList?[position].patientProfileImage.toString() ?? "",
                                                                              bioData: "",
                                                                            )));
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        20,
                                                                        10,
                                                                        20,
                                                                        10),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color:
                                                                            colorPrimary),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Iconify(
                                                                      Ep.chat_line_round,
                                                                      color:
                                                                          colorPrimary,
                                                                      size: 22,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    MyText(
                                                                      color:
                                                                          colorPrimary,
                                                                      text:
                                                                          "chat",
                                                                      fontsize:
                                                                          Dimens
                                                                              .text15Size,
                                                                      multilanguage:
                                                                          true,
                                                                      fontweight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxline:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textalign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal,
                                                                    ),
                                                                  ],
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
                                                                Utils.showToast(
                                                                    videocallfeaturenotavailable);
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                padding:
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10,
                                                                        10,
                                                                        10,
                                                                        10),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width:
                                                                            1,
                                                                        color:
                                                                            colorPrimary),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Iconify(
                                                                      Ph.phone_call_light,
                                                                      color:
                                                                          colorPrimary,
                                                                      size: 22,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Flexible(
                                                                      child:
                                                                          MyText(
                                                                        color:
                                                                            colorPrimary,
                                                                        text:
                                                                            "call",
                                                                        fontsize:
                                                                            Dimens.text15Size,
                                                                        multilanguage:
                                                                            true,
                                                                        fontweight:
                                                                            FontWeight.w500,
                                                                        maxline:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        textalign:
                                                                            TextAlign.center,
                                                                        fontstyle:
                                                                            FontStyle.normal,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : appointmentProvider
                                                                .todayAppointmentList?[
                                                                    position]
                                                                .status
                                                                .toString() ==
                                                            "5"
                                                        ? Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          10,
                                                                          20,
                                                                          10),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              colorPrimary),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: MyText(
                                                                    color:
                                                                        colorPrimary,
                                                                    text:
                                                                        "view_details",
                                                                    fontsize: Dimens
                                                                        .text15Size,
                                                                    multilanguage:
                                                                        true,
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w500,
                                                                    maxline: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    textalign:
                                                                        TextAlign
                                                                            .center,
                                                                    fontstyle:
                                                                        FontStyle
                                                                            .normal,
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
                                                                            builder: (context) =>
                                                                                SeeReview(doctorId: int.parse(Constant.userID.toString()))));
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .fromLTRB(
                                                                            20,
                                                                            10,
                                                                            20,
                                                                            10),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            width:
                                                                                1,
                                                                            color:
                                                                                colorPrimary),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child:
                                                                        MyText(
                                                                      color:
                                                                          colorPrimary,
                                                                      text:
                                                                          "see_review",
                                                                      fontsize:
                                                                          Dimens
                                                                              .text15Size,
                                                                      multilanguage:
                                                                          true,
                                                                      fontweight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxline:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textalign:
                                                                          TextAlign
                                                                              .center,
                                                                      fontstyle:
                                                                          FontStyle
                                                                              .normal,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        : appointmentProvider
                                                                    .todayAppointmentList?[
                                                                        position]
                                                                    .status
                                                                    .toString() ==
                                                                "6"
                                                            ? Row(
                                                                children: <Widget>[
                                                                  // CupertinoButton(
                                                                  //   minSize: double.minPositive,
                                                                  //   padding: EdgeInsets.zero,
                                                                  //   child: MySvgAssetsImg(
                                                                  //     imageName: "tick_green.svg",
                                                                  //     fit: BoxFit.cover,
                                                                  //     imgHeight: 25,
                                                                  //     imgWidth: 25,
                                                                  //   ),
                                                                  //   onPressed: () {
                                                                  //     updateAppointmentStatus("2");
                                                                  //   },
                                                                  // ),
                                                                  Expanded(
                                                                      child:
                                                                          InkWell(
                                                                    onTap: () {
                                                                      // updateAppointmentStatus("2");
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => Reschedule(
                                                                                    appointmentID: appointmentProvider.todayAppointmentList?[position].id.toString(),
                                                                                    doctorID: appointmentProvider.todayAppointmentList?[position].doctorId.toString(),
                                                                                  ))).then(
                                                                        (value) async {
                                                                          await getApi((appointmentProvider.pendingcurrentPage ??
                                                                              0));
                                                                        },
                                                                      );
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          10,
                                                                          20,
                                                                          10),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10),
                                                                          border: Border.all(
                                                                              color: colorPrimaryDark,
                                                                              width: 1)),
                                                                      child:
                                                                          MyText(
                                                                        text:
                                                                            "reschedule",
                                                                        multilanguage:
                                                                            true,
                                                                        color:
                                                                            colorPrimaryDark,
                                                                        fontsize:
                                                                            Dimens.text14Size,
                                                                        fontweight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  )),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  // CupertinoButton(
                                                                  //   minSize: double.minPositive,
                                                                  //   padding: EdgeInsets.zero,
                                                                  //   child: MySvgAssetsImg(
                                                                  //     imageName: "cross_red.svg",
                                                                  //     fit: BoxFit.cover,
                                                                  //     imgHeight: 25,
                                                                  //     imgWidth: 25,
                                                                  //   ),
                                                                  //   onPressed: () {
                                                                  //     updateAppointmentStatus("3");
                                                                  //   },
                                                                  // ),
                                                                  Expanded(
                                                                      child:
                                                                          InkWell(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => AppointmentDetails(appointmentProvider.todayAppointmentList?[position].id.toString() ?? "")));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          40,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          10,
                                                                          20,
                                                                          10),
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              colorPrimaryDark,
                                                                          borderRadius: BorderRadius.circular(
                                                                              10),
                                                                          border: Border.all(
                                                                              color: colorPrimaryDark,
                                                                              width: 1)),
                                                                      child:
                                                                          MyText(
                                                                        text:
                                                                            "join_session",
                                                                        multilanguage:
                                                                            true,
                                                                        color:
                                                                            white,
                                                                        fontsize:
                                                                            Dimens.text14Size,
                                                                        fontweight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  )),
                                                                ],
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
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
                                              text: Utils.formateDate(
                                                  (appointmentProvider
                                                              .todayAppointmentList?[
                                                                  position]
                                                              .date ??
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
                      },
                    ),
                    Consumer<SeeallProvider>(
                      builder: (context, viewallprovider, child) {
                        if (viewallprovider.loadmore) {
                          return Utils.pageLoader();
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const NoData(text: '');
            }
          } else {
            return const NoData(text: '');
          }
        }
      },
    );
  }

  void updateAppointmentStatus(String status, position) async {
    printLog(
        'appointmentID ==>> ${appointmentProvider.todayAppointmentList?[position].id}');
    printLog('status ==>> $status');

    Utils.showProgress(context, prDialog);

    await appointmentProvider.updateAppoinmentStatus(
        appointmentProvider.todayAppointmentList?[position].id, status);
    printLog(
        'updateAppointmentStatus loadingUpdate ==>> ${appointmentProvider.loadingUpdate}');

    if (!appointmentProvider.loadingUpdate) {
      printLog(
          'updateAppointmentStatus status ==>> ${appointmentProvider.successModel.status}');
      if (appointmentProvider.successModel.status == 200) {
        prDialog?.hide();
        // Update Other Consumer
        appointmentProvider.todayAppointmentList?[position].status =
            int.parse(status);
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

  Widget apoointMentShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 18, right: 18),
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => const SizedBox(width: 3),
      itemCount: 10,
      itemBuilder: (BuildContext context, int position) {
        return ShimmerUtils.appointmentList(context);
      },
    );
  }

  void updatePendingAppointmentStatus(String status, position) async {
    printLog(
        'appointmentID ==>> ${appointmentProvider.pendingAppointmentList?[position].id}');
    printLog('status ==>> $status');

    Utils.showProgress(context, prDialog);

    await appointmentProvider.updateAppoinmentStatus(
        appointmentProvider.pendingAppointmentList?[position].id, status);
    printLog(
        'updateAppointmentStatus loadingUpdate ==>> ${appointmentProvider.loadingUpdate}');

    if (!appointmentProvider.loadingUpdate) {
      printLog(
          'updateAppointmentStatus status ==>> ${appointmentProvider.successModel.status}');
      if (appointmentProvider.successModel.status == 200) {
        prDialog?.hide();
        // Update Other Consumer
        appointmentProvider.pendingAppointmentList?[position].status =
            int.parse(status);
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
