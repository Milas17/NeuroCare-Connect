import 'package:yourappname/model/patientlistgraphmodel.dart';
import 'package:yourappname/pages/blogdetails.dart';
import 'package:yourappname/pages/seeall.dart';
import 'package:yourappname/pages/appointmentdetails.dart';
import 'package:yourappname/pages/chatscreen.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/pages/notifications.dart';
import 'package:yourappname/pages/reschedule.dart';
import 'package:yourappname/pages/seereview.dart';
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/shimmerutils.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconify_flutter/icons/ci.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ep.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeF extends StatefulWidget {
  const HomeF({super.key});

  @override
  State<HomeF> createState() => _HomeFState();
}

class _HomeFState extends State<HomeF> {
  SharedPre sharePref = SharedPre();
  late HomeProvider homeProvider;
  ProgressDialog? prDialog;

  @override
  void initState() {
    printLog("Constant.accessToken ======>>> ${Constant.accessToken}");
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    prDialog = ProgressDialog(context);
    homeProvider.getDoctorDetails();
    // getOnesignalNotification();
    homeProvider.getPendingAppointment("1");
    homeProvider.getTodayAppointment("1");
    homeProvider.getPatientList();
    homeProvider.getBlog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Consumer<HomeProvider>(builder: (context, homeProvider, child) {
        return SafeArea(child: myHomePage());
      }),
    );
  }

  Widget myHomePage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            color: colorPrimary,
            child: Consumer<HomeProvider>(
              builder: (context, homeProvider, child) {
                if (homeProvider.loading) {
                  return const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomWidget.roundcorner(
                              height: 25,
                              width: 200,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            CustomWidget.roundcorner(
                              height: 12,
                              width: 150,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      CustomWidget.roundcorner(
                        height: 25,
                        width: 25,
                      ),
                    ],
                  );
                }
                if (homeProvider.doctorProfileModel.status == 200 &&
                    homeProvider.doctorProfileModel.result != null &&
                    (homeProvider.doctorProfileModel.result?.length ?? 0) > 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MyText(
                              text: ((homeProvider.doctorProfileModel.result?[0]
                                              .fullName
                                              .toString() ??
                                          "")
                                      .contains("null"))
                                  ? ("Hi, Guest User")
                                  : ("Hi, ${homeProvider.doctorProfileModel.result?[0].fullName ?? "-"}"),
                              multilanguage: false,
                              color: white,
                              textalign: TextAlign.start,
                              fontweight: FontWeight.w600,
                              fontsize: Dimens.text22Size,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Notifications()));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.only(right: 0),
                              decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Iconify(
                                Ci.notification_outline_dot,
                                size: 25,
                                color: colorPrimaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 10),
                      // MyText(
                      //   text: homeProvider.doctorProfileModel.result?[0].bio ??
                      //       "-",
                      //   multilanguage: false,
                      //   maxline: 1,
                      //   color: white,
                      //   textalign: TextAlign.start,
                      //   fontweight: FontWeight.w500,
                      //   fontsize: Dimens.text16Size,
                      // ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      Consumer<HomeProvider>(
                        builder: (context, homeProvider, child) {
                          if (!homeProvider.loading) {
                            if (homeProvider.todayAppointmentModel.status ==
                                    200 &&
                                homeProvider.todayAppointmentModel.result !=
                                    null) {
                              if ((homeProvider.todayAppointmentModel.result
                                          ?.length ??
                                      0) >
                                  0) {
                                return Stack(
                                  children: [
                                    MyImage(
                                        fit: BoxFit.fill,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 240,
                                        imagePath: "layer_bg.png"),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AppointmentDetails(homeProvider
                                                            .todayAppointmentModel
                                                            .result?[0]
                                                            .id
                                                            .toString() ??
                                                        ""))).then(
                                          (value) {
                                            homeProvider
                                                .getTodayAppointment('1');
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20.0, 15, 20, 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: <Widget>[
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                  child: MyNetworkImage(
                                                    imageUrl: homeProvider
                                                            .todayAppointmentModel
                                                            .result?[0]
                                                            .patientProfileImage ??
                                                        Constant
                                                            .userPlaceholder,
                                                    fit: BoxFit.cover,
                                                    imgHeight: 55,
                                                    imgWidth: 55,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: MyText(
                                                              text: homeProvider
                                                                      .todayAppointmentModel
                                                                      .result?[
                                                                          0]
                                                                      .patientName ??
                                                                  "",
                                                              fontsize: Dimens
                                                                  .text17Size,
                                                              maxline: 1,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w500,
                                                              textalign:
                                                                  TextAlign
                                                                      .start,
                                                              color:
                                                                  colorPrimaryDark,
                                                            ),
                                                          ),
                                                          InkWell(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const SeeAll(
                                                                      type:
                                                                          "today_appointments",
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              child: Utils()
                                                                  .seeallBtn()),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 4,
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          MyText(
                                                            text: homeProvider
                                                                        .todayAppointmentModel
                                                                        .result?[
                                                                            0]
                                                                        .appointmentType
                                                                        .toString() ==
                                                                    "1"
                                                                ? 'online_visit'
                                                                : "physical_visit",
                                                            fontsize: Dimens
                                                                .text13Size,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxline: 1,
                                                            fontweight:
                                                                FontWeight.w400,
                                                            multilanguage: true,
                                                            textalign:
                                                                TextAlign.start,
                                                            color:
                                                                otherLightColor,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Container(
                                                            width: 4,
                                                            height: 4,
                                                            decoration:
                                                                const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  otherLightColor,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Expanded(
                                                            child: MyText(
                                                              text: homeProvider
                                                                      .todayAppointmentModel
                                                                      .result?[
                                                                          0]
                                                                      .symptoms ??
                                                                  "",
                                                              fontsize: Dimens
                                                                  .text14Size,
                                                              maxline: 1,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w400,
                                                              textalign:
                                                                  TextAlign
                                                                      .start,
                                                              color:
                                                                  otherLightColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 10, 10, 10),
                                              alignment: Alignment.topLeft,
                                              decoration: BoxDecoration(
                                                  color: lightBlue,
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .calendar_month_rounded,
                                                    color: colorPrimary,
                                                    size: 25,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  MyText(
                                                    text: Utils.formateDate(
                                                        ((homeProvider
                                                                    .todayAppointmentModel
                                                                    .result?[0]
                                                                    .date ??
                                                                ""))
                                                            .toString()),
                                                    fontsize: Dimens.text14Size,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                                '  ${Utils.formateTime(((homeProvider.todayAppointmentModel.result?[0].startTime ?? "")))}-${Utils.formateTime(((homeProvider.todayAppointmentModel.result?[0].endTime ?? "")))}',
                                                            fontsize: Dimens
                                                                .text14Size,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxline: 1,
                                                            fontweight:
                                                                FontWeight.w500,
                                                            textalign:
                                                                TextAlign.start,
                                                            color:
                                                                colorPrimaryDark,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            homeProvider.todayAppointmentModel
                                                        .result?[0].status
                                                        .toString() ==
                                                    "1"
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            updateTodayAppointmentStatus(
                                                                "3", 0);
                                                          },
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(0,
                                                                    10, 0, 10),
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
                                                              multilanguage:
                                                                  true,
                                                              color:
                                                                  rejectedStatus,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w500,
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
                                                            updateTodayAppointmentStatus(
                                                                "2", 0);
                                                          },
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(0,
                                                                    10, 0, 10),
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
                                                              multilanguage:
                                                                  true,
                                                              color:
                                                                  approvedStatus,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : homeProvider
                                                            .todayAppointmentModel
                                                            .result?[0]
                                                            .status
                                                            .toString() ==
                                                        "3"
                                                    ? const SizedBox.shrink()
                                                    : homeProvider
                                                                .todayAppointmentModel
                                                                .result?[0]
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
                                                                            builder: (context) => Chatscreen(
                                                                                  toUserName: homeProvider.todayAppointmentModel.result?[0].patientName.toString() ?? "",
                                                                                  toChatId: homeProvider.todayAppointmentModel.result?[0].patientFirebaseId.toString() ?? "",
                                                                                  profileImg: homeProvider.todayAppointmentModel.result?[0].patientProfileImage.toString() ?? "",
                                                                                  bioData: "",
                                                                                )));
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
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        const Iconify(
                                                                          Ep.chat_line_round,
                                                                          color:
                                                                              colorPrimary,
                                                                          size:
                                                                              22,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        MyText(
                                                                          color:
                                                                              colorPrimary,
                                                                          text:
                                                                              "chat",
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
                                                                  onTap:
                                                                      () async {
                                                                    // await FlutterPhoneDirectCaller
                                                                    //     .callNumber(
                                                                    //   homeProvider
                                                                    //           .todayAppointmentModel
                                                                    //           .result?[0]
                                                                    //           .patientMobileNo
                                                                    //           .toString() ??
                                                                    //       "",
                                                                    // );
                                                                    Utils.showToast(
                                                                        videocallfeaturenotavailable);
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
                                                                            BorderRadius.circular(10)),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        const Iconify(
                                                                          Ph.phone_call_light,
                                                                          color:
                                                                              colorPrimary,
                                                                          size:
                                                                              22,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10,
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
                                                        : homeProvider
                                                                    .todayAppointmentModel
                                                                    .result?[0]
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
                                                                      padding: const EdgeInsets
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
                                                                            "view_details",
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
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => SeeReview(doctorId: int.parse(Constant.userID.toString()))));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        padding: const EdgeInsets
                                                                            .fromLTRB(
                                                                            20,
                                                                            10,
                                                                            20,
                                                                            10),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        decoration: BoxDecoration(
                                                                            border:
                                                                                Border.all(width: 1, color: colorPrimary),
                                                                            borderRadius: BorderRadius.circular(10)),
                                                                        child:
                                                                            MyText(
                                                                          color:
                                                                              colorPrimary,
                                                                          text:
                                                                              "see_review",
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
                                                                    ),
                                                                  )
                                                                ],
                                                              )
                                                            : homeProvider
                                                                        .todayAppointmentModel
                                                                        .result?[
                                                                            0]
                                                                        .status
                                                                        .toString() ==
                                                                    "6"
                                                                ? Row(
                                                                    children: <Widget>[
                                                                      Expanded(
                                                                          child:
                                                                              InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => Reschedule(
                                                                                        doctorID: homeProvider.todayAppointmentModel.result?[0].doctorId.toString(),
                                                                                        appointmentID: homeProvider.todayAppointmentModel.result?[0].id.toString(),
                                                                                      ))).then(
                                                                            (value) {
                                                                              homeProvider.getTodayAppointment("1");
                                                                            },
                                                                          );
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              50,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              20,
                                                                              15,
                                                                              20,
                                                                              15),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              border: Border.all(color: colorPrimaryDark, width: 1)),
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
                                                                        width:
                                                                            20,
                                                                      ),
                                                                      Expanded(
                                                                          child:
                                                                              InkWell(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => AppointmentDetails(homeProvider.todayAppointmentModel.result?[0].id.toString() ?? "")));
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              50,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              20,
                                                                              15,
                                                                              20,
                                                                              15),
                                                                          decoration: BoxDecoration(
                                                                              color: colorPrimaryDark,
                                                                              borderRadius: BorderRadius.circular(8),
                                                                              border: Border.all(color: colorPrimaryDark, width: 1)),
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
                                  ],
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          } else {
                            return Utils.pageLoader();
                          }
                        },
                      )
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          Container(
            // height: MediaQuery.sizeOf(context).height,
            decoration: const BoxDecoration(
                color: white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            child: Column(
              children: [
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      MyText(
                        text: "pending_appointments",
                        multilanguage: true,
                        fontsize: Dimens.text17Size,
                        fontweight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.start,
                        color: textTitleColor,
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SeeAll(
                                  type: "pending_appointments",
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(5),
                          child: Utils().seeallBtn()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                pendingAppointmentList(),
                const SizedBox(height: 16),
                chart(),
                const SizedBox(height: 16),
                blog()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget pendingAppointmentList() {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        if (!homeProvider.pendingLoading) {
          if (homeProvider.pendingAppointmentModel.status == 200 &&
              homeProvider.pendingAppointmentModel.result != null) {
            if ((homeProvider.pendingAppointmentModel.result?.length ?? 0) >
                0) {
              return SizedBox(
                height: 210,
                child: AlignedGridView.count(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  mainAxisSpacing: 14,
                  crossAxisCount: 1,
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      homeProvider.pendingAppointmentModel.result?.length ?? 0,
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
                                homeProvider.pendingAppointmentModel
                                        .result?[position].id
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
                                padding:
                                    const EdgeInsets.fromLTRB(10, 20, 10, 20),
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
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          clipBehavior: Clip.antiAlias,
                                          child: MyNetworkImage(
                                            imageUrl: homeProvider
                                                    .pendingAppointmentModel
                                                    .result?[position]
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
                                                text: homeProvider
                                                        .pendingAppointmentModel
                                                        .result?[position]
                                                        .patientName ??
                                                    "",
                                                fontsize: Dimens.text17Size,
                                                fontweight: FontWeight.w600,
                                                textalign: TextAlign.start,
                                                color: black,
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
                                                    text: homeProvider
                                                                .pendingAppointmentModel
                                                                .result?[
                                                                    position]
                                                                .appointmentType
                                                                .toString() ==
                                                            "1"
                                                        ? "online_visit"
                                                        : "physical_visit",
                                                    fontsize: Dimens.text13Size,
                                                    multilanguage: true,
                                                    fontweight: FontWeight.w600,
                                                    textalign: TextAlign.start,
                                                    color: grayDark.withValues(
                                                        alpha: 0.8),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Container(
                                                    width: 4,
                                                    height: 4,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: otherColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: MyText(
                                                      text: homeProvider
                                                              .pendingAppointmentModel
                                                              .result?[position]
                                                              .symptoms ??
                                                          "",
                                                      fontsize:
                                                          Dimens.text13Size,
                                                      maxline: 1,
                                                      fontweight:
                                                          FontWeight.w600,
                                                      textalign:
                                                          TextAlign.start,
                                                      color:
                                                          grayDark.withValues(
                                                              alpha: 0.8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 5, 10, 5),
                                                    decoration: BoxDecoration(
                                                        color: homeProvider
                                                                    .pendingAppointmentModel
                                                                    .result?[
                                                                        position]
                                                                    .status
                                                                    .toString() ==
                                                                "1"
                                                            ? pendingStatus
                                                                .withValues(
                                                                    alpha: 0.15)
                                                            : (homeProvider
                                                                        .pendingAppointmentModel
                                                                        .result?[
                                                                            position]
                                                                        .status
                                                                        .toString() ==
                                                                    "2"
                                                                ? completedStatus
                                                                    .withValues(
                                                                        alpha:
                                                                            0.2)
                                                                : (homeProvider
                                                                            .pendingAppointmentModel
                                                                            .result?[position]
                                                                            .status
                                                                            .toString() ==
                                                                        "3"
                                                                    ? rejectedStatus.withValues(alpha: 0.5)
                                                                    : homeProvider.pendingAppointmentModel.result?[position].status.toString() == "4"
                                                                        ? otherColor.withValues(alpha: 0.5)
                                                                        : (homeProvider.pendingAppointmentModel.result?[position].status.toString() == "5" ? completedStatus.withValues(alpha: 0.2) : black.withValues(alpha: 0.3)))),
                                                        borderRadius: BorderRadius.circular(8)),
                                                    child: MyText(
                                                      text: homeProvider
                                                                  .pendingAppointmentModel
                                                                  .result?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "1"
                                                          ? "pending"
                                                          : (homeProvider
                                                                      .pendingAppointmentModel
                                                                      .result?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "2"
                                                              ? "approved"
                                                              : (homeProvider
                                                                          .pendingAppointmentModel
                                                                          .result?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "3"
                                                                  ? "rejected"
                                                                  : homeProvider
                                                                              .pendingAppointmentModel
                                                                              .result?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "4"
                                                                      ? "absent"
                                                                      : (homeProvider.pendingAppointmentModel.result?[position].status.toString() ==
                                                                              "5"
                                                                          ? "completed"
                                                                          : "-"))),
                                                      multilanguage: true,
                                                      fontsize:
                                                          Dimens.text12Size,
                                                      fontweight:
                                                          FontWeight.w600,
                                                      textalign:
                                                          TextAlign.start,
                                                      color: homeProvider
                                                                  .pendingAppointmentModel
                                                                  .result?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "1"
                                                          ? pendingStatus
                                                          : (homeProvider
                                                                      .pendingAppointmentModel
                                                                      .result?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "2"
                                                              ? completedStatus
                                                              : (homeProvider
                                                                          .pendingAppointmentModel
                                                                          .result?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "3"
                                                                  ? rejectedStatus
                                                                  : homeProvider
                                                                              .pendingAppointmentModel
                                                                              .result?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "4"
                                                                      ? otherColor
                                                                      : (homeProvider.pendingAppointmentModel.result?[position].status.toString() ==
                                                                              "5"
                                                                          ? completedStatus
                                                                          : black))),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: MyText(
                                                      text:
                                                          '${Utils.formateTime(homeProvider.pendingAppointmentModel.result?[position].startTime ?? "")} - ${Utils.formateTime(homeProvider.pendingAppointmentModel.result?[position].endTime ?? "")}',
                                                      fontsize:
                                                          Dimens.text13Size,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              updateAppointmentStatus(
                                                  "3", position);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 0, 10),
                                              decoration: BoxDecoration(
                                                  color: rejectedStatus
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
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
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 0, 10),
                                              decoration: BoxDecoration(
                                                  color: approvedStatus
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
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
                                    ),
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
                                          text: Utils.formateDate((homeProvider
                                                      .pendingAppointmentModel
                                                      .result?[position]
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
              );
            } else {
              return const NoData(text: "");
            }
          } else {
            return const NoData(text: "");
          }
        } else {
          return apoointMentShimmer();
        }
      },
    );
  }

  Widget todayAppointmentList() {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        if (!homeProvider.todayLoading) {
          if (homeProvider.todayAppointmentModel.status == 200 &&
              homeProvider.todayAppointmentModel.result != null) {
            if ((homeProvider.todayAppointmentModel.result?.length ?? 0) > 0) {
              return Container(
                constraints: const BoxConstraints(
                  minHeight: 110,
                  maxHeight: 120,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 18, right: 18),
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => const SizedBox(
                    width: 3,
                  ),
                  itemCount:
                      homeProvider.todayAppointmentModel.result?.length ?? 0,
                  itemBuilder: (BuildContext context, int position) {
                    return Container(
                      padding: const EdgeInsets.only(top: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          printLog("Item Clicked!");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AppointmentDetails(
                                  homeProvider.todayAppointmentModel
                                          .result?[position].id
                                          .toString() ??
                                      ""),
                            ),
                          );
                        },
                        child: Stack(
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: 82,
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.5,
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.9,
                              ),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 3,
                                color: white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Flexible(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 60),
                                              alignment: Alignment.topLeft,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  MyText(
                                                    text: homeProvider
                                                            .todayAppointmentModel
                                                            .result?[position]
                                                            .patientName ??
                                                        "",
                                                    fontsize: Dimens.text14Size,
                                                    fontweight: FontWeight.bold,
                                                    textalign: TextAlign.start,
                                                    color: textTitleColor,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      MyText(
                                                        text: homeProvider
                                                                .todayAppointmentModel
                                                                .result?[
                                                                    position]
                                                                .patientMobileNo ??
                                                            "-",
                                                        fontsize:
                                                            Dimens.text12Size,
                                                        fontweight:
                                                            FontWeight.normal,
                                                        textalign:
                                                            TextAlign.start,
                                                        color: otherLightColor,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Container(
                                                        width: 4,
                                                        height: 4,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              otherLightColor,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      MyText(
                                                        text: homeProvider
                                                                    .todayAppointmentModel
                                                                    .result?[
                                                                        position]
                                                                    .status
                                                                    .toString() ==
                                                                "1"
                                                            ? "pending"
                                                            : (homeProvider
                                                                        .todayAppointmentModel
                                                                        .result?[
                                                                            position]
                                                                        .status
                                                                        .toString() ==
                                                                    "2"
                                                                ? "approved"
                                                                : (homeProvider
                                                                            .todayAppointmentModel
                                                                            .result?[
                                                                                position]
                                                                            .status
                                                                            .toString() ==
                                                                        "3"
                                                                    ? "rejected"
                                                                    : homeProvider.todayAppointmentModel.result?[position].status.toString() ==
                                                                            "4"
                                                                        ? "absent"
                                                                        : (homeProvider.todayAppointmentModel.result?[position].status.toString() ==
                                                                                "5"
                                                                            ? "completed"
                                                                            : "-"))),
                                                        fontsize:
                                                            Dimens.text12Size,
                                                        fontweight:
                                                            FontWeight.normal,
                                                        textalign:
                                                            TextAlign.start,
                                                        color: homeProvider
                                                                    .todayAppointmentModel
                                                                    .result
                                                                    ?.elementAt(
                                                                        position)
                                                                    .status
                                                                    .toString() ==
                                                                "1"
                                                            ? pendingStatus
                                                            : (homeProvider
                                                                        .todayAppointmentModel
                                                                        .result
                                                                        ?.elementAt(
                                                                            position)
                                                                        .status
                                                                        .toString() ==
                                                                    "2"
                                                                ? approvedStatus
                                                                : (homeProvider
                                                                            .todayAppointmentModel
                                                                            .result
                                                                            ?.elementAt(
                                                                                position)
                                                                            .status
                                                                            .toString() ==
                                                                        "3"
                                                                    ? rejectedStatus
                                                                    : homeProvider.todayAppointmentModel.result?[position].status.toString() ==
                                                                            "4"
                                                                        ? otherColor
                                                                        : (homeProvider.todayAppointmentModel.result?[position].status.toString() ==
                                                                                "5"
                                                                            ? completedStatus
                                                                            : black))),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 13),
                                            Container(
                                              alignment: Alignment.topLeft,
                                              child: MyText(
                                                text:
                                                    '${Utils.formateDate((homeProvider.todayAppointmentModel.result?[position].date ?? "").toString())} at ${Utils.formateTime((homeProvider.todayAppointmentModel.result?[position].startTime ?? ""))} - ${Utils.formateTime((homeProvider.todayAppointmentModel.result?[position].endTime ?? ""))}',
                                                fontsize: Dimens.text13Size,
                                                overflow: TextOverflow.ellipsis,
                                                maxline: 1,
                                                fontweight: FontWeight.normal,
                                                textalign: TextAlign.start,
                                                color: textTitleColor,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: <Widget>[
                                                const Icon(
                                                  Icons.description_rounded,
                                                  size: 15,
                                                  color: gray,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: MyText(
                                                    text: homeProvider
                                                            .todayAppointmentModel
                                                            .result?[position]
                                                            .symptoms ??
                                                        "-",
                                                    fontsize: Dimens.text12Size,
                                                    maxline: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontweight:
                                                        FontWeight.normal,
                                                    textalign: TextAlign.start,
                                                    color: otherColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              transform: Matrix4.translationValues(12, -10, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.0),
                                clipBehavior: Clip.antiAlias,
                                child: MyNetworkImage(
                                  imageUrl: homeProvider.todayAppointmentModel
                                          .result?[position].patientProfileImage
                                          .toString() ??
                                      Constant.userPlaceholder,
                                  fit: BoxFit.fill,
                                  imgHeight: 61,
                                  imgWidth: 54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return Utils.pageLoader();
        }
      },
    );
  }

  Widget chart() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: MyText(
                  text: "patients_visits",
                  multilanguage: true,
                  fontsize: Dimens.text17Size,
                  fontweight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Consumer<HomeProvider>(
          builder: (context, homeProvider, child) {
            // Show loading indicator when data is being fetched
            if (homeProvider.graphLoading) {
              return CustomWidget.roundcorner(
                height: 140,
                width: MediaQuery.of(context).size.width * 0.85,
              );
            } else {
              // Check if the response status is 200 and result is available
              if (homeProvider.patientListGraphModel.status == 200 &&
                  homeProvider.patientListGraphModel.result != null &&
                  (homeProvider.patientListGraphModel.result?.length ?? 0) >
                      0) {
                // Extract the result from the model (assuming only one result entry)
                Result result = homeProvider.patientListGraphModel.result![0];

                // Prepare the data for the Bar Chart
                List<Map<String, dynamic>> chartData = [
                  {'day': 'Mon', 'count': result.monday ?? 0},
                  {'day': 'Tue', 'count': result.tuesday ?? 0},
                  {'day': 'Wed', 'count': result.wednesday ?? 0},
                  {'day': 'Thu', 'count': result.thursday ?? 0},
                  {'day': 'Fri', 'count': result.friday ?? 0},
                  {'day': 'Sat', 'count': result.saturday ?? 0},
                  {'day': 'Sun', 'count': result.sunday ?? 0},
                ];

                // Render the bar chart with the prepared data
                return AspectRatio(
                  aspectRatio: 1.5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        barGroups: chartData.map((data) {
                          int xValue = chartData.indexOf(data);
                          return BarChartGroupData(
                            x: xValue,
                            barRods: [
                              BarChartRodData(
                                toY: data['count'].toDouble(),
                                color: colorPrimary,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                int index = value.toInt();
                                if (index < 0 || index >= chartData.length) {
                                  return const SizedBox.shrink();
                                }
                                return MyText(
                                  text: chartData[index]['day'],
                                  fontsize: 12,
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value == 0) {
                                  return const SizedBox.shrink();
                                }
                                return MyText(
                                  text: value.toInt().toString(),
                                  fontsize: 12,
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false, // Right axis titles are hidden
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox
                    .shrink(); // Return an empty space if data is unavailable
              }
            }
          },
        )
      ],
    );
  }

  Widget blog() {
    if (homeProvider.blogLoading) {
      return blogShimmer();
    } else {
      if (homeProvider.blogModel.status == 200 &&
          homeProvider.blogModel.result != null &&
          (homeProvider.blogModel.result?.length ?? 0) > 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: MyText(
                text: "healthblogs",
                multilanguage: true,
                fontsize: Dimens.text17Size,
                fontweight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.start,
                color: textTitleColor,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<HomeProvider>(
              builder: (context, homeProvider, child) {
                if (homeProvider.blogLoading) {
                  return CustomWidget.roundcorner(
                    height: 140,
                    width: MediaQuery.of(context).size.width * 0.85,
                  );
                } else {
                  return SizedBox(
                    height: 230, // Adjust height as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: homeProvider.blogModel.result?.length ?? 0,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemBuilder: (context, index) {
                        final blog = homeProvider.blogModel.result?[index];
                        return InkWell(
                          onTap: () {
                            printLog("Clicked blog: ${blog?.title}");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BlogDetails(blogList: blog)));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Card(
                                  elevation: 4,
                                  color: white,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.8, // card width
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: MyNetworkImage(
                                        // imgWidth: MediaQuery.of(context).size.width,
                                        imgHeight: 140,
                                        imageUrl: blog?.image?.toString() ?? "",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: MyText(
                                  text: blog?.title ?? "",
                                  multilanguage: false,
                                  fontsize: Dimens.text17Size,
                                  fontweight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  maxline: 2,
                                  textalign: TextAlign.start,
                                  color: textTitleColor,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            )
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget blogShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Blog title shimmer
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: CustomWidget.roundrectborder(
            height: 20,
            width: 120,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 230, // Same height as the blog list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image shimmer
                    CustomWidget.roundrectborder(
                      height: 130,
                      width: MediaQuery.of(context).size.width * 0.8,
                    ),
                    const SizedBox(height: 10),
                    // Title shimmer line 1
                    CustomWidget.roundrectborder(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.8,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget apoointMentShimmer() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 105,
        maxHeight: 210,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 18, right: 18),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 3),
        itemCount: 10,
        itemBuilder: (BuildContext context, int position) {
          return ShimmerUtils.appointmentList(context);
        },
      ),
    );
  }

  void updateAppointmentStatus(String status, index) async {
    printLog(
        'appointmentID ==>> ${homeProvider.pendingAppointmentModel.result?[index].id}');
    printLog('status ==>> $status');

    Utils.showProgress(context, prDialog);

    await homeProvider.updateAppoinmentStatus(
        homeProvider.pendingAppointmentModel.result?[index].id, status);
    printLog(
        'updateAppointmentStatus loadingUpdate ==>> ${homeProvider.loadingUpdate}');

    if (!homeProvider.loadingUpdate) {
      printLog(
          'updateAppointmentStatus status ==>> ${homeProvider.successModel.status}');
      if (homeProvider.successModel.status == 200) {
        prDialog?.hide();
        // Update Other Consumer
        await homeProvider.getPendingAppointment("1");

        if (!mounted) return;
        Utils.showSnackbar(
            context, homeProvider.successModel.message ?? "", false);
      } else {
        prDialog?.hide();
        if (!mounted) return;
        Utils.showSnackbar(
            context, homeProvider.successModel.message ?? "", false);
      }
    }
  }

  void updateTodayAppointmentStatus(String status, index) async {
    printLog(
        'appointmentID ==>> ${homeProvider.todayAppointmentModel.result?[index].id}');
    printLog('status ==>> $status');

    Utils.showProgress(context, prDialog);

    await homeProvider.updateAppoinmentStatus(
        homeProvider.todayAppointmentModel.result?[index].id, status);
    printLog(
        'updateAppointmentStatus loadingUpdate ==>> ${homeProvider.loadingUpdate}');

    if (!homeProvider.loadingUpdate) {
      printLog(
          'updateAppointmentStatus status ==>> ${homeProvider.successModel.status}');
      if (homeProvider.successModel.status == 200) {
        prDialog?.hide();
        // Update Other Consumer
        await homeProvider.getTodayAppointment("1");

        if (!mounted) return;
        Utils.showSnackbar(
            context, homeProvider.successModel.message ?? "", false);
      } else {
        prDialog?.hide();
        if (!mounted) return;
        Utils.showSnackbar(
            context, homeProvider.successModel.message ?? "", false);
      }
    }
  }
}
