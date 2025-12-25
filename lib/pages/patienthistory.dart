import 'package:yourappname/pages/appointmentdetails.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/pages/pdfviewpage.dart';
import 'package:yourappname/provider/patienthistoryprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:provider/provider.dart';

class PatientHistory extends StatefulWidget {
  const PatientHistory({super.key});

  @override
  State<PatientHistory> createState() => _PatientHistoryState();
}

class _PatientHistoryState extends State<PatientHistory> {
  late ScrollController _scrollController;
  late PatientHistoryProvider patientHistoryProvider;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    patientHistoryProvider =
        Provider.of<PatientHistoryProvider>(context, listen: false);
    getData(0);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (patientHistoryProvider.currentPage ?? 0) <
            (patientHistoryProvider.totalPage ?? 0)) {
      await patientHistoryProvider.setLoadMore(true);
      await getData((patientHistoryProvider.currentPage ?? 0));
    }
  }

  @override
  void dispose() {
    patientHistoryProvider.clearProvider();
    super.dispose();
  }

  getData(pageNo) async {
    await patientHistoryProvider.getPatientHistory((pageNo + 1).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      resizeToAvoidBottomInset: false,
      appBar: Utils.myAppBarWithBack(context, "patient_history", true, true),
      body: Consumer<PatientHistoryProvider>(
        builder: (context, patientHistoryProvider, child) {
          if (patientHistoryProvider.loading &&
              patientHistoryProvider.loadmore == false) {
            return historyShimmer();
          }
          if (patientHistoryProvider.pateintHistoryModel.status == 200 &&
              (patientHistoryProvider.appointmentList?.length ?? 0) > 0 &&
              patientHistoryProvider.appointmentList != null) {
            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        patientHistoryProvider.appointmentList?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AppointmentDetails(
                                        patientHistoryProvider
                                                .appointmentList?[index].id
                                                .toString() ??
                                            "")));
                          },
                          child: Card(
                            color: white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: MyNetworkImage(
                                            imageUrl: patientHistoryProvider
                                                    .appointmentList?[index]
                                                    .patientProfileImage
                                                    .toString() ??
                                                "",
                                            imgHeight: 70,
                                            imgWidth: 70,
                                            fit: BoxFit.cover),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: MyText(
                                                  text: patientHistoryProvider
                                                          .appointmentList?[
                                                              index]
                                                          .patientName
                                                          .toString() ??
                                                      "",
                                                  color: colorPrimaryDark,
                                                  fontsize: Dimens.text16Size,
                                                  maxline: 1,
                                                  multilanguage: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontweight: FontWeight.w500,
                                                  textalign: TextAlign.start,
                                                  fontstyle: FontStyle.normal,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 5, 10, 5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: patientHistoryProvider
                                                              .appointmentList?[
                                                                  index]
                                                              .status
                                                              .toString() ==
                                                          "1"
                                                      ? pendingStatus.withValues(
                                                          alpha: 0.2)
                                                      : (patientHistoryProvider
                                                                  .appointmentList?[
                                                                      index]
                                                                  .status
                                                                  .toString() ==
                                                              "2"
                                                          ? approvedStatus.withValues(
                                                              alpha: 0.2)
                                                          : (patientHistoryProvider.appointmentList?[index].status
                                                                      .toString() ==
                                                                  "3"
                                                              ? rejectedStatus.withValues(
                                                                  alpha: 0.2)
                                                              : patientHistoryProvider
                                                                          .appointmentList?[index]
                                                                          .status
                                                                          .toString() ==
                                                                      "4"
                                                                  ? otherColor.withValues(alpha: 0.2)
                                                                  : (patientHistoryProvider.appointmentList?[index].status.toString() == "5" ? approvedStatus.withValues(alpha: 0.2) : black))),
                                                ),
                                                child: MyText(
                                                  text: patientHistoryProvider
                                                              .appointmentList?[
                                                                  index]
                                                              .status
                                                              .toString() ==
                                                          "1"
                                                      ? "pending"
                                                      : (patientHistoryProvider
                                                                  .appointmentList?[
                                                                      index]
                                                                  .status
                                                                  .toString() ==
                                                              "2"
                                                          ? "approved"
                                                          : (patientHistoryProvider
                                                                      .appointmentList?[
                                                                          index]
                                                                      .status
                                                                      .toString() ==
                                                                  "3"
                                                              ? "rejected"
                                                              : patientHistoryProvider
                                                                          .appointmentList?[
                                                                              index]
                                                                          .status
                                                                          .toString() ==
                                                                      "4"
                                                                  ? "absent"
                                                                  : (patientHistoryProvider
                                                                              .appointmentList?[index]
                                                                              .status
                                                                              .toString() ==
                                                                          "5"
                                                                      ? "completed"
                                                                      : "-"))),
                                                  multilanguage: true,
                                                  fontsize: Dimens.text13Size,
                                                  fontweight: FontWeight.w600,
                                                  textalign: TextAlign.start,
                                                  color: patientHistoryProvider
                                                              .appointmentList?[
                                                                  index]
                                                              .status
                                                              .toString() ==
                                                          "1"
                                                      ? pendingStatus
                                                      : (patientHistoryProvider
                                                                  .appointmentList?[
                                                                      index]
                                                                  .status
                                                                  .toString() ==
                                                              "2"
                                                          ? approvedStatus
                                                          : (patientHistoryProvider
                                                                      .appointmentList?[
                                                                          index]
                                                                      .status
                                                                      .toString() ==
                                                                  "3"
                                                              ? rejectedStatus
                                                              : patientHistoryProvider
                                                                          .appointmentList?[
                                                                              index]
                                                                          .status
                                                                          .toString() ==
                                                                      "4"
                                                                  ? otherColor
                                                                  : (patientHistoryProvider
                                                                              .appointmentList?[index]
                                                                              .status
                                                                              .toString() ==
                                                                          "5"
                                                                      ? approvedStatus
                                                                      : black))),
                                                ),
                                              ),
                                            ],
                                          ),
                                          MyText(
                                            text: patientHistoryProvider
                                                    .appointmentList?[index]
                                                    .symptoms
                                                    .toString() ??
                                                "",
                                            color: grayDark,
                                            fontsize: Dimens.text14Size,
                                            maxline: 1,
                                            multilanguage: false,
                                            overflow: TextOverflow.ellipsis,
                                            fontweight: FontWeight.w500,
                                            textalign: TextAlign.start,
                                            fontstyle: FontStyle.normal,
                                          )
                                        ],
                                      )),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 10, 10, 10),
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
                                              ((patientHistoryProvider
                                                          .appointmentList?[
                                                              index]
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
                                        const Spacer(),
                                        const Icon(
                                          Icons.access_time,
                                          color: colorPrimary,
                                          size: 25,
                                        ),
                                        Expanded(
                                          child: MyText(
                                            text:
                                                '  ${Utils.formateTime(((patientHistoryProvider.appointmentList?[index].startTime ?? "")))} ',
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
                                  ),
                                  patientHistoryProvider
                                              .appointmentList?[index].status
                                              .toString() ==
                                          "5"
                                      ? ExpansionTile(
                                          title: MyText(
                                            text: "prescription",
                                            fontsize: Dimens.text14Size,
                                            multilanguage: true,
                                            fontweight: FontWeight.w500,
                                            color: black,
                                          ),
                                          children: [
                                            SizedBox(
                                              height: 245,
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: MyImage(
                                                      imagePath:
                                                          'download_prescription_darkbg.png',
                                                      height: 180,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                      top: 15,
                                                      left: 20,
                                                      child: SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            MyText(
                                                              text: "download",
                                                              fontsize: Dimens
                                                                  .text24Size,
                                                              multilanguage:
                                                                  true,
                                                              color:
                                                                  colorPrimary,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                            MyText(
                                                              text:
                                                                  "prescription",
                                                              fontsize: Dimens
                                                                  .text24Size,
                                                              multilanguage:
                                                                  true,
                                                              color:
                                                                  colorPrimary,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                            MyText(
                                                              maxline: 3,
                                                              text:
                                                                  "${Locales.string(context, "sentyouby")} ${patientHistoryProvider.appointmentList?[index].doctorName.toString() ?? ""}, ${Locales.string(context, "lastcheckupprescription")}",
                                                              fontsize: Dimens
                                                                  .text12Size,
                                                              color: white,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w500,
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                  Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          PdfViewPage(
                                                                            title:
                                                                                patientHistoryProvider.appointmentList?[index].patientName.toString(),
                                                                            id: patientHistoryProvider.appointmentList?[index].id.toString(),
                                                                          )));
                                                        },
                                                        child: Stack(children: [
                                                          MyImage(
                                                            imagePath:
                                                                "download_darkbg.png",
                                                            height: 80,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                          ),
                                                          Positioned(
                                                            top: 20,
                                                            left: 80,
                                                            child: MyText(
                                                              maxline: 1,
                                                              text:
                                                                  "downloadprescription",
                                                                  multilanguage: true,
                                                              fontsize: Dimens
                                                                  .text14Size,
                                                              color: white,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          )
                                                        ]),
                                                      ))
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      : const SizedBox.shrink()
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 20,
                      );
                    },
                  ),
                  Consumer<PatientHistoryProvider>(
                    builder: (context, viewallprovider, child) {
                      if (viewallprovider.loadmore) {
                        return Utils.pageLoader();
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
            );
          } else {
            return const NoData(text: "");
          }
        },
      ),
    );
  }

  Widget historyShimmer() {
    return ListView.builder(
      itemCount: 10,
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index) {
        return CustomWidget.roundcorner(
          height: 180,
          width: MediaQuery.of(context).size.width,
        );
      },
    );
  }
}
