import 'package:yourappname/pages/appointmentdetails.dart';
import 'package:yourappname/pages/chatscreen.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/pages/reschedule.dart';
import 'package:yourappname/pages/seereview.dart';
import 'package:yourappname/provider/listofappointmentprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/shimmerutils.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ep.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class ListOfAppointment extends StatefulWidget {
  final String patientID;
  const ListOfAppointment(this.patientID, {super.key});

  @override
  State<ListOfAppointment> createState() => _ListOfAppointmentState();
}

class _ListOfAppointmentState extends State<ListOfAppointment> {
  late ScrollController _scrollController;
  ProgressDialog? prDialog;
  late ListOfAppointmentProvider listOfAppointmentProvider;

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    printLog("patientID =======> ${widget.patientID}");
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    listOfAppointmentProvider =
        Provider.of<ListOfAppointmentProvider>(context, listen: false);
    getData(0);
    super.initState();
  }

  getData(pageNo) async {
    await listOfAppointmentProvider.getPatientAppointment(
        widget.patientID, (pageNo + 1).toString());
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (listOfAppointmentProvider.currentPage ?? 0) <
            (listOfAppointmentProvider.totalPage ?? 0)) {
      await listOfAppointmentProvider.setLoadMore(true);
      await getData(listOfAppointmentProvider.currentPage ?? 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.myAppBarWithBack(context, "all_appointment", true, true),
      body: SizedBox(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const SizedBox(height: 15),
              todayAppintment(),
            ],
          ),
        ),
      ),
    );
  }

  Widget todayAppintment() {
    return Consumer<ListOfAppointmentProvider>(
      builder: (context, listOfAppointmentProvider, child) {
        if (listOfAppointmentProvider.loading &&
            listOfAppointmentProvider.loadmore == false) {
          return apoointMentListShimmer();
        } else {
          if (listOfAppointmentProvider.listOfAppointmentModel.status == 200 &&
              listOfAppointmentProvider.appointmentList != null &&
              (listOfAppointmentProvider.appointmentList?.length ?? 0) > 0) {
            return Column(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount:
                      listOfAppointmentProvider.appointmentList?.length ?? 0,
                  itemBuilder: (BuildContext context, int position) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          printLog("Item Clicked!");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => AppointmentDetails(
                                    listOfAppointmentProvider
                                            .appointmentList?[position].id
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        tileMode: TileMode.clamp,
                                        colors: [
                                          colorPrimary.withValues(alpha: 0.3),
                                          colorPrimary.withValues(alpha: 0.2),
                                          colorPrimary.withValues(alpha: 0.1),
                                          transparent,
                                          transparent,
                                        ],
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft)),
                                child: Column(
                                  children: [
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: colorAccent,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                            child: MyNetworkImage(
                                              imageUrl: listOfAppointmentProvider
                                                      .appointmentList?[
                                                          position]
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              MyText(
                                                text: listOfAppointmentProvider
                                                        .appointmentList?[
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
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  MyText(
                                                    text: listOfAppointmentProvider
                                                                .appointmentList?[
                                                                    position]
                                                                .appointmentType
                                                                .toString() ==
                                                            "1"
                                                        ? "online_visit"
                                                        : "physical_visit",
                                                    fontsize: Dimens.text13Size,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxline: 1,
                                                    multilanguage: true,
                                                    fontweight: FontWeight.w600,
                                                    textalign: TextAlign.start,
                                                    color: otherLightColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Container(
                                                    width: 4,
                                                    height: 4,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: otherLightColor,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Expanded(
                                                    child: MyText(
                                                      text: listOfAppointmentProvider
                                                              .appointmentList?[
                                                                  position]
                                                              .symptoms ??
                                                          "",
                                                      fontsize:
                                                          Dimens.text14Size,
                                                      maxline: 1,
                                                      fontweight:
                                                          FontWeight.w400,
                                                      textalign:
                                                          TextAlign.start,
                                                      color: otherLightColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 5, 10, 5),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: listOfAppointmentProvider
                                                                  .appointmentList?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "1"
                                                          ? pendingStatus
                                                              .withValues(
                                                                  alpha: 0.2)
                                                          : (listOfAppointmentProvider
                                                                      .appointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "2"
                                                              ? approvedStatus
                                                                  .withValues(
                                                                      alpha:
                                                                          0.2)
                                                              : (listOfAppointmentProvider
                                                                          .appointmentList?[position]
                                                                          .status
                                                                          .toString() ==
                                                                      "3"
                                                                  ? rejectedStatus.withValues(alpha: 0.2)
                                                                  : listOfAppointmentProvider.appointmentList?[position].status.toString() == "4"
                                                                      ? otherColor.withValues(alpha: 0.2)
                                                                      : (listOfAppointmentProvider.appointmentList?[position].status.toString() == "5" ? approvedStatus.withValues(alpha: 0.2) : black))),
                                                    ),
                                                    child: MyText(
                                                      text: listOfAppointmentProvider
                                                                  .appointmentList?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "1"
                                                          ? "pending"
                                                          : (listOfAppointmentProvider
                                                                      .appointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "2"
                                                              ? "approved"
                                                              : (listOfAppointmentProvider
                                                                          .appointmentList?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "3"
                                                                  ? "rejected"
                                                                  : listOfAppointmentProvider
                                                                              .appointmentList?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "4"
                                                                      ? "absent"
                                                                      : (listOfAppointmentProvider.appointmentList?[position].status.toString() ==
                                                                              "5"
                                                                          ? "completed"
                                                                          : "-"))),
                                                      multilanguage: true,
                                                      fontsize:
                                                          Dimens.text13Size,
                                                      fontweight:
                                                          FontWeight.w600,
                                                      textalign:
                                                          TextAlign.start,
                                                      color: listOfAppointmentProvider
                                                                  .appointmentList?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "1"
                                                          ? pendingStatus
                                                          : (listOfAppointmentProvider
                                                                      .appointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "2"
                                                              ? approvedStatus
                                                              : (listOfAppointmentProvider
                                                                          .appointmentList?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "3"
                                                                  ? rejectedStatus
                                                                  : listOfAppointmentProvider
                                                                              .appointmentList?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "4"
                                                                      ? otherColor
                                                                      : (listOfAppointmentProvider.appointmentList?[position].status.toString() ==
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
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: MyText(
                                                        text:
                                                            '${Utils.formateTime(listOfAppointmentProvider.appointmentList?[position].startTime ?? "")} - ${Utils.formateTime(listOfAppointmentProvider.appointmentList?[position].endTime ?? "")}',
                                                        fontsize:
                                                            Dimens.text13Size,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxline: 1,
                                                        fontweight:
                                                            FontWeight.w500,
                                                        textalign:
                                                            TextAlign.start,
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
                                    listOfAppointmentProvider
                                                .appointmentList?[position]
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
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 10, 0, 10),
                                                    decoration: BoxDecoration(
                                                        color: rejectedStatus
                                                            .withValues(
                                                                alpha: 0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
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
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 10, 0, 10),
                                                    decoration: BoxDecoration(
                                                        color: approvedStatus
                                                            .withValues(
                                                                alpha: 0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
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
                                        : listOfAppointmentProvider
                                                    .appointmentList?[position]
                                                    .status
                                                    .toString() ==
                                                "3"
                                            ? const SizedBox.shrink()
                                            : listOfAppointmentProvider
                                                        .appointmentList?[
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
                                                                    builder:
                                                                        (context) =>
                                                                            Chatscreen(
                                                                              toUserName: listOfAppointmentProvider.appointmentList?[position].patientName.toString() ?? "",
                                                                              toChatId: listOfAppointmentProvider.appointmentList?[position].patientFirebaseId.toString() ?? "",
                                                                              profileImg: listOfAppointmentProvider.appointmentList?[position].patientProfileImage.toString() ?? "",
                                                                              bioData: "",
                                                                            )));
                                                          },
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
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
                                                            alignment: Alignment
                                                                .center,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                        colorPrimary),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
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
                                                                  text: "chat",
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
                                                            width:
                                                                MediaQuery.of(
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
                                                            alignment: Alignment
                                                                .center,
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                        colorPrimary),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
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
                                                                  child: MyText(
                                                                    color:
                                                                        colorPrimary,
                                                                    text:
                                                                        "call",
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
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : listOfAppointmentProvider
                                                            .appointmentList?[
                                                                position]
                                                            .status
                                                            .toString() ==
                                                        "5"
                                                    ? Row(
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              width:
                                                                  MediaQuery.of(
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
                                                                  border: Border
                                                                      .all(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              colorPrimary),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
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
                                                                        builder:
                                                                            (context) =>
                                                                                SeeReview(doctorId: int.parse(Constant.userID.toString()))));
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
                                                                child: MyText(
                                                                  color:
                                                                      colorPrimary,
                                                                  text:
                                                                      "see_review",
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
                                                          )
                                                        ],
                                                      )
                                                    : listOfAppointmentProvider
                                                                .appointmentList?[
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
                                                                                appointmentID: listOfAppointmentProvider.appointmentList?[position].id.toString(),
                                                                                doctorID: listOfAppointmentProvider.appointmentList?[position].doctorId.toString(),
                                                                              ))).then(
                                                                    (value) async {
                                                                      await getData(
                                                                          listOfAppointmentProvider.currentPage ??
                                                                              0);
                                                                    },
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .fromLTRB(
                                                                          20,
                                                                          10,
                                                                          20,
                                                                          10),
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      border: Border.all(
                                                                          color:
                                                                              colorPrimaryDark,
                                                                          width:
                                                                              1)),
                                                                  child: MyText(
                                                                    text:
                                                                        "reschedule",
                                                                    multilanguage:
                                                                        true,
                                                                    color:
                                                                        colorPrimaryDark,
                                                                    fontsize: Dimens
                                                                        .text14Size,
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              )),
                                                              const SizedBox(
                                                                width: 20,
                                                              ),
                                                              Expanded(
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                AppointmentDetails(listOfAppointmentProvider.appointmentList?[position].id.toString() ?? ""),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: 40,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .fromLTRB(
                                                                            20,
                                                                            10,
                                                                            20,
                                                                            10),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          colorPrimaryDark,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      border: Border.all(
                                                                          color:
                                                                              colorPrimaryDark,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    child:
                                                                        MyText(
                                                                      text:
                                                                          "join_session",
                                                                      multilanguage:
                                                                          true,
                                                                      color:
                                                                          white,
                                                                      fontsize:
                                                                          Dimens
                                                                              .text14Size,
                                                                      fontweight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
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
                                            (listOfAppointmentProvider
                                                        .appointmentList?[
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
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Consumer<ListOfAppointmentProvider>(
                  builder: (context, viewallprovider, child) {
                    if (viewallprovider.loadmore) {
                      return Utils.pageLoader();
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            );
          } else {
            return const NoData(text: '');
          }
        }
      },
    );
  }

  Widget apoointMentListShimmer() {
    return AlignedGridView.count(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        mainAxisSpacing: 14,
        crossAxisCount: 1,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (BuildContext context, int position) {
          return ShimmerUtils.appointmentList(context);
        });
  }

  void updateAppointmentStatus(String status, index) async {
    printLog(
        'appointmentID ==>> ${listOfAppointmentProvider.appointmentList?[index].id}');
    printLog('status ==>> $status');

    Utils.showProgress(context, prDialog);

    await listOfAppointmentProvider.updateAppoinmentStatus(
        listOfAppointmentProvider.appointmentList?[index].id, status);
    listOfAppointmentProvider.appointmentList?[index].status =
        int.parse(status);
    printLog(
        'updateAppointmentStatus loadingUpdate ==>> ${listOfAppointmentProvider.loading}');

    if (!listOfAppointmentProvider.loading) {
      printLog(
          'updateAppointmentStatus status ==>> ${listOfAppointmentProvider.successModel.status}');
      if (listOfAppointmentProvider.successModel.status == 200) {
        prDialog?.hide();

        if (!mounted) return;

        if (!mounted) return;
        Utils.showSnackbar(
            context, listOfAppointmentProvider.successModel.message ?? "", false);
      } else {
        prDialog?.hide();
        if (!mounted) return;
        Utils.showSnackbar(
            context, listOfAppointmentProvider.successModel.message ?? "", false);
      }
    }
  }
}
