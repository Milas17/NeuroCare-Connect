import 'package:yourappname/pages/appointmentdetails.dart';
import 'package:yourappname/pages/chatscreen.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/pages/reschedule.dart';
import 'package:yourappname/pages/seereview.dart';
import 'package:yourappname/pages/videocall/page/videocallscreen.dart';
import 'package:yourappname/provider/appointmentprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/navigation_manager.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/shimmerutils.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ep.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class AllAppointmentF extends StatefulWidget {
  const AllAppointmentF({super.key});

  @override
  State<AllAppointmentF> createState() => _AllAppointmentFState();
}

class _AllAppointmentFState extends State<AllAppointmentF>
    with SingleTickerProviderStateMixin {
  late AppointmentProvider appointmentProvider;
  SharedPre sharePref = SharedPre();
  final mSearchController = TextEditingController();
  int selectedIndex = 0;
  late bool isSearching;
  ProgressDialog? prDialog;
  late ScrollController _scrollController;
  late ScrollController _searchScrollController;

  @override
  void initState() {
    isSearching = false;
    prDialog = ProgressDialog(context);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _searchScrollController = ScrollController();
    _searchScrollController.addListener(_searchscrollListener);
    appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);
    appointmentProvider.setLoading(true);
    getStatus();
    // appointmentProvider.getAppointmentList();
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (appointmentProvider.currentPage ?? 0) <
            (appointmentProvider.totalPage ?? 0)) {
      await appointmentProvider.setLoadMore(true);
      await getData(
          appointmentProvider.lastTabIndex,
          appointmentProvider.lastTabValue,
          (appointmentProvider.currentPage ?? 0));
    }
  }

  _searchscrollListener() async {
    if (!_searchScrollController.hasClients) return;
    if (_searchScrollController.offset >=
            _searchScrollController.position.maxScrollExtent &&
        !_searchScrollController.position.outOfRange &&
        appointmentProvider.issearchMorePage) {
      // Use morePage flag
      await appointmentProvider.setLoadMore(true);
      await getSearchData(mSearchController.text.toString(),
          (appointmentProvider.searchcurrentPage ?? 0) + 1); // Fetch next page
    }
  }

  getSearchData(name, pageNo) async {
    await appointmentProvider.getSearchAppointment(
        name, (pageNo).toString());
  }

  getStatus() async {
    await appointmentProvider.getAppointmentStatus();
    await getData(
        0,
        appointmentProvider.appointmnetStatusModel.result?[0].value.toString(),
        0);
  }

  getData(position, value, pageNo) async {
    position ??= 0;
    await setSelectedTab(position);
    if (value == 0 || value == null) {
      value = appointmentProvider.appointmnetStatusModel.result?[0].value
          .toString();
    }
    await appointmentProvider.getAppointment(
      value,
      (pageNo + 1),
    );
  }

  Future<void> setSelectedTab(int tabPos) async {
    printLog("setSelectedTab tabPos ====> $tabPos");
    if (!mounted) return;
    await appointmentProvider.setSelectedTab(tabPos);
    printLog(
        "setSelectedTab selectedIndex ====> ${appointmentProvider.selectedIndex}");
    printLog(
        "setSelectedTab lastTabPosition ====> ${appointmentProvider.lastTabPosition}");
    if (appointmentProvider.lastTabPosition == tabPos) {
      return;
    } else {
      appointmentProvider.setTabPosition(tabPos);
    }
  }

  @override
  void dispose() {
    appointmentProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: transparent,
      body: SafeArea(
        child: Container(
          color: white,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          // decoration: Utils.topRoundBG(),
          child: Consumer<AppointmentProvider>(
            builder: (context, appointmentProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  search(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: MyText(
                      text: appointmentProvider.isShow == true
                          ? "search_aappoiintments"
                          : "appointments",
                      multilanguage: true,
                      fontsize: Dimens.text16Size,
                      fontweight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.start,
                      color: textTitleColor,
                    ),
                  ),
                  appointmentProvider.isShow == true
                      ? const SizedBox()
                      : _buildTabItem(),
                  Expanded(
                      child: appointmentProvider.isShow == true
                          ? searchappointmentList()
                          : upcomingAppintment())
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem() {
    if (appointmentProvider.statusLoading &&
        appointmentProvider.loadmore == false) {
      return statusShimmer();
    } else if ((appointmentProvider.appointmnetStatusModel.result?.length ??
                0) >
            0 &&
        appointmentProvider.appointmnetStatusModel.result != null) {
      return SizedBox(
        height: 60,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount:
              appointmentProvider.appointmnetStatusModel.result?.length ?? 0,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          separatorBuilder: (context, index) {
            return const SizedBox(
              width: 20,
            );
          },
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () async {
                appointmentProvider.setTabIndex(index);
                appointmentProvider.setTabValue(appointmentProvider
                    .appointmnetStatusModel.result?[index].value
                    .toString());
                appointmentProvider.appointmentList = [];
                await getData(
                    index,
                    appointmentProvider
                        .appointmnetStatusModel.result?[index].value
                        .toString(),
                    0);
              },
              child: Container(
                height: 30,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                decoration: BoxDecoration(
                    color: appointmentProvider.selectedIndex == index
                        ? colorAccent
                        : white,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: MyText(
                  text: appointmentProvider
                          .appointmnetStatusModel.result?[index].name
                          .toString() ??
                      "",
                  fontsize: Dimens.text15Size,
                  fontweight: FontWeight.w500,
                  color: appointmentProvider.selectedIndex == index
                      ? colorPrimary
                      : grayDark,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget search() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: mSearchController,
          builder: (context, value, child) {
            return TextFormField(
              controller: mSearchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              obscureText: false,
              maxLines: 1,
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              readOnly: false,
              onChanged: (text) async {
                if (text.isNotEmpty) {
                  await appointmentProvider.showsreachScreen(true);
                  appointmentProvider.searchAppointmentList = [];
                  await appointmentProvider.searchsetLoading(true);
                  await appointmentProvider.getSearchAppointment(
                      mSearchController.text.trim(), "1");
                } else {
                  await appointmentProvider.showsreachScreen(false);
                  appointmentProvider.searchAppointmentList = [];
                }
              },
              onFieldSubmitted: (searchedText) async {
                if (mSearchController.text.trim().isNotEmpty) {
                  await appointmentProvider.showsreachScreen(true);
                  appointmentProvider.searchAppointmentList = [];
                  await appointmentProvider.searchsetLoading(true);
                  await appointmentProvider.getSearchAppointment(
                      mSearchController.text.trim(), "1");
                } else {
                  await appointmentProvider.showsreachScreen(false);
                  appointmentProvider.searchAppointmentList = [];
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: gray.withValues(alpha: 0.1),
                hintText: Locales.string(context, "search_appointments"),
                hintStyle: GoogleFonts.roboto(
                  fontSize: 16,
                  color: grayDark,
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: gray),
                        onPressed: () {
                          mSearchController.clear();
                          appointmentProvider.showsreachScreen(false);
                          appointmentProvider.searchAppointmentList = [];
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : const Icon(Icons.search, color: gray),
              ),
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: textTitleColor,
                fontWeight: FontWeight.normal,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget upcomingAppintment() {
    if (appointmentProvider.loading && appointmentProvider.loadmore == false) {
      return apoointMentListShimmer();
    } else {
      if (appointmentProvider.appointmentByTypeModel.status == 200 &&
          appointmentProvider.appointmentList != null &&
          (appointmentProvider.appointmentList?.length ?? 0) > 0) {
        return RefreshIndicator(
          onRefresh: () async {
            await getData(
                appointmentProvider.lastTabIndex,
                appointmentProvider.appointmnetStatusModel
                    .result?[appointmentProvider.lastTabIndex ?? 0].value
                    .toString(),
                0);
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: appointmentProvider.appointmentList?.length ?? 0,
                  itemBuilder: (BuildContext context, int position) {
                    // return UpcomingAppointmentItem(
                    //   appointmentProvider.allAppointmentModel,
                    //   position,
                    // );
                    return Container(
                      padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          printLog("Item Clicked!");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => AppointmentDetails(
                                    appointmentProvider
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
                                padding:
                                    const EdgeInsets.fromLTRB(10, 15, 10, 15),
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
                                              imageUrl: appointmentProvider
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
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              MyText(
                                                text: appointmentProvider
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
                                                    text: appointmentProvider
                                                                .appointmentList?[
                                                                    position]
                                                                .appointmentType
                                                                .toString() ==
                                                            "Online"
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
                                                      text: appointmentProvider
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
                                                      color: appointmentProvider
                                                                  .appointmentList?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "1"
                                                          ? pendingStatus
                                                              .withValues(
                                                                  alpha: 0.2)
                                                          : (appointmentProvider
                                                                      .appointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "2"
                                                              ? approvedStatus
                                                                  .withValues(
                                                                      alpha:
                                                                          0.2)
                                                              : (appointmentProvider
                                                                          .appointmentList?[position]
                                                                          .status
                                                                          .toString() ==
                                                                      "3"
                                                                  ? rejectedStatus.withValues(alpha: 0.2)
                                                                  : appointmentProvider.appointmentList?[position].status.toString() == "4"
                                                                      ? otherColor.withValues(alpha: 0.2)
                                                                      : (appointmentProvider.appointmentList?[position].status.toString() == "5" ? approvedStatus.withValues(alpha: 0.2) : black))),
                                                    ),
                                                    child: MyText(
                                                      text: appointmentProvider
                                                                  .appointmentList?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "1"
                                                          ? "pending"
                                                          : (appointmentProvider
                                                                      .appointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "2"
                                                              ? "approved"
                                                              : (appointmentProvider
                                                                          .appointmentList?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "3"
                                                                  ? "rejected"
                                                                  : appointmentProvider
                                                                              .appointmentList?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "4"
                                                                      ? "absent"
                                                                      : (appointmentProvider.appointmentList?[position].status.toString() ==
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
                                                      color: appointmentProvider
                                                                  .appointmentList?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "1"
                                                          ? pendingStatus
                                                          : (appointmentProvider
                                                                      .appointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "2"
                                                              ? approvedStatus
                                                              : (appointmentProvider
                                                                          .appointmentList?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "3"
                                                                  ? rejectedStatus
                                                                  : appointmentProvider
                                                                              .appointmentList?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "4"
                                                                      ? otherColor
                                                                      : (appointmentProvider.appointmentList?[position].status.toString() ==
                                                                              "5"
                                                                          ? approvedStatus
                                                                          : black))),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: MyText(
                                                        text:
                                                            '${Utils.formateTime(appointmentProvider.appointmentList?[position].startTime ?? "")} - ${Utils.formateTime(appointmentProvider.appointmentList?[position].endTime ?? "")}',
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
                                                  (appointmentProvider
                                                                  .appointmentList?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "2" &&
                                                          appointmentProvider
                                                                  .appointmentList?[
                                                                      position]
                                                                  .appointmentType
                                                                  .toString() ==
                                                              "Online")
                                                      ? InkWell(
                                                          onTap: () {
                                                            _navigateToVideoCallScreen(
                                                                appointmentProvider
                                                                        .appointmentList?[
                                                                            position]
                                                                        .roomId ??
                                                                    "1",
                                                                appointmentProvider
                                                                        .appointmentList?[
                                                                            position]
                                                                        .id
                                                                        .toString() ??
                                                                    "1");
                                                          },
                                                          child: const Icon(
                                                            Icons.call,
                                                            color: colorPrimary,
                                                          ),
                                                        )
                                                      : const SizedBox.shrink()
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    // if (appointmentProvider
                                    //         .appointmentList?[position].type ==
                                    //     "all")
                                    appointmentProvider
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
                                                  // onTap: () {
                                                  //   Navigator.push(
                                                  //       context,
                                                  //       MaterialPageRoute(
                                                  //           builder: (context) => DownloadPrescription(
                                                  //               doctorName: allAppointmentProvider
                                                  //                       .appointmentModel
                                                  //                       .result?[
                                                  //                           position]
                                                  //                       .doctorName ??
                                                  //                   "",
                                                  //               image: allAppointmentProvider
                                                  //                       .appointmentModel
                                                  //                       .result?[
                                                  //                           position]
                                                  //                       .doctorImage ??
                                                  //                   "",
                                                  //               speciality: allAppointmentProvider
                                                  //                       .appointmentModel
                                                  //                       .result?[
                                                  //                           position]
                                                  //                       .specialitiesName ??
                                                  //                   "",
                                                  //               vistType: "1",
                                                  //               time:
                                                  //                   "${homeProvider.pendingAppointmentModel.result?[position].startTime ?? ""} - ${homeProvider.pendingAppointmentModel.result?[position].endTime ?? ""}")));
                                                  // },
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
                                                  // onTap: () {
                                                  //   Navigator.push(
                                                  //       context,
                                                  //       MaterialPageRoute(
                                                  //           builder: (context) => WriteReview(
                                                  //               doctorId: allAppointmentProvider
                                                  //                       .appointmentModel
                                                  //                       .result?[
                                                  //                           position]
                                                  //                       .doctorId
                                                  //                       .toString() ??
                                                  //                   "",
                                                  //               doctorName:
                                                  //                   homeProvider.pendingAppointmentModel.result?[position].doctorName ??
                                                  //                       "",
                                                  //               image: allAppointmentProvider
                                                  //                       .appointmentModel
                                                  //                       .result?[
                                                  //                           position]
                                                  //                       .doctorImage ??
                                                  //                   "",
                                                  //               speciality: allAppointmentProvider
                                                  //                       .appointmentModel
                                                  //                       .result?[position]
                                                  //                       .specialitiesName ??
                                                  //                   "",
                                                  //               vistType: "1",
                                                  //               time: "${homeProvider.pendingAppointmentModel.result?[position].startTime ?? ""} - ${homeProvider.pendingAppointmentModel.result?[position].endTime ?? ""}")));
                                                  // },
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
                                        : appointmentProvider
                                                    .appointmentList?[position]
                                                    .status
                                                    .toString() ==
                                                "3"
                                            ? const SizedBox.shrink()
                                            : appointmentProvider
                                                        .appointmentList?[
                                                            position]
                                                        .status
                                                        .toString() ==
                                                    "2"
                                                ? const SizedBox.shrink()
                                                : appointmentProvider
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
                                                    : appointmentProvider
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
                                                                                appointmentID: appointmentProvider.appointmentList?[position].id.toString(),
                                                                                doctorID: appointmentProvider.appointmentList?[position].doctorId.toString(),
                                                                              ))).then(
                                                                    (value) async {
                                                                      await getData(
                                                                          appointmentProvider
                                                                              .lastTabIndex,
                                                                          appointmentProvider
                                                                              .lastTabValue,
                                                                          ((appointmentProvider.currentPage) ??
                                                                              0));
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
                                                                  child:
                                                                      InkWell(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              AppointmentDetails(appointmentProvider.appointmentList?[position].id.toString() ?? "")));
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
                                                                      color:
                                                                          colorPrimaryDark,
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
                                                                        "join_session",
                                                                    multilanguage:
                                                                        true,
                                                                    color:
                                                                        white,
                                                                    fontsize: Dimens
                                                                        .text14Size,
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              )),
                                                            ],
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                    appointmentProvider
                                                .appointmentList?[position].type
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
                                        : appointmentProvider
                                                    .appointmentList?[position]
                                                    .type
                                                    .toString() ==
                                                "3"
                                            ? const SizedBox.shrink()
                                            : appointmentProvider
                                                        .appointmentList?[
                                                            position]
                                                        .type
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
                                                                              toUserName: appointmentProvider.appointmentList?[position].patientName.toString() ?? "",
                                                                              toChatId: appointmentProvider.appointmentList?[position].patientFirebaseId.toString() ?? "",
                                                                              profileImg: appointmentProvider.appointmentList?[position].patientProfileImage.toString() ?? "",
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
                                                : appointmentProvider
                                                            .appointmentList?[
                                                                position]
                                                            .type
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
                                                    : appointmentProvider
                                                                .appointmentList?[
                                                                    position]
                                                                .type
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
                                                                                appointmentID: appointmentProvider.appointmentList?[position].id.toString(),
                                                                                doctorID: appointmentProvider.appointmentList?[position].doctorId.toString(),
                                                                              ))).then(
                                                                    (value) async {
                                                                      await getData(
                                                                          appointmentProvider
                                                                              .lastTabIndex,
                                                                          appointmentProvider
                                                                              .lastTabValue,
                                                                          ((appointmentProvider.currentPage) ??
                                                                              0));
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
                                                                  child:
                                                                      InkWell(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              AppointmentDetails(appointmentProvider.appointmentList?[position].id.toString() ?? "")));
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
                                                                      color:
                                                                          colorPrimaryDark,
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
                                                                        "join_session",
                                                                    multilanguage:
                                                                        true,
                                                                    color:
                                                                        white,
                                                                    fontsize: Dimens
                                                                        .text14Size,
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w500,
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
                                ))
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Consumer<AppointmentProvider>(
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
          ),
        );
      } else {
        return const NoData(text: '');
      }
    }
  }

  Widget searchappointmentList() {
    if (appointmentProvider.searchloading &&
        appointmentProvider.loadmore == false) {
      return apoointMentListShimmer();
    } else {
      if (appointmentProvider.searchappointmentModel.status == 200 &&
          appointmentProvider.searchAppointmentList != null) {
        if ((appointmentProvider.searchAppointmentList?.length ?? 0) > 0) {
          return SingleChildScrollView(
            controller: _searchScrollController,
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      appointmentProvider.searchAppointmentList?.length ?? 0,
                  itemBuilder: (BuildContext context, int position) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          printLog("Item Clicked!");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AppointmentDetails(
                                appointmentProvider
                                        .searchAppointmentList?[position].id
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        tileMode: TileMode.clamp,
                                        colors: [
                                          colorPrimary.withValues(alpha: 0.1),
                                          white,
                                          white,
                                          white
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
                                            imageUrl: appointmentProvider
                                                    .searchAppointmentList?[
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
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              MyText(
                                                text: appointmentProvider
                                                        .searchAppointmentList?[
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
                                                    text: appointmentProvider
                                                                .searchAppointmentList?[
                                                                    position]
                                                                .appointmentType
                                                                .toString() ==
                                                            "Online"
                                                        ? "online_visit"
                                                        : "physical_visit",
                                                    fontsize: Dimens.text13Size,
                                                    fontweight: FontWeight.w600,
                                                    multilanguage: true,
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
                                                      text: appointmentProvider
                                                              .searchAppointmentList?[
                                                                  position]
                                                              .symptoms ??
                                                          "",
                                                      fontsize:
                                                          Dimens.text13Size,
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
                                                        color: appointmentProvider
                                                                    .searchAppointmentList?[
                                                                        position]
                                                                    .status
                                                                    .toString() ==
                                                                "1"
                                                            ? colorAccent
                                                            : (appointmentProvider
                                                                        .searchAppointmentList?[
                                                                            position]
                                                                        .status
                                                                        .toString() ==
                                                                    "2"
                                                                ? approvedStatus
                                                                    .withValues(
                                                                        alpha:
                                                                            0.2)
                                                                : (appointmentProvider.searchAppointmentList?[position].status
                                                                            .toString() ==
                                                                        "3"
                                                                    ? rejectedStatus
                                                                        .withValues(
                                                                            alpha:
                                                                                0.5)
                                                                    : appointmentProvider.searchAppointmentList?[position].status.toString() ==
                                                                            "4"
                                                                        ? otherColor.withValues(alpha: 0.5)
                                                                        : (appointmentProvider.searchAppointmentList?[position].status.toString() == "5" ? completedStatus.withValues(alpha: 0.2) : black.withValues(alpha: 0.3)))),
                                                        borderRadius: BorderRadius.circular(8)),
                                                    child: MyText(
                                                      text: appointmentProvider
                                                                  .searchAppointmentList?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "1"
                                                          ? "pending"
                                                          : (appointmentProvider
                                                                      .searchAppointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "2"
                                                              ? "approved"
                                                              : (appointmentProvider
                                                                          .searchAppointmentList?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "3"
                                                                  ? "rejected"
                                                                  : appointmentProvider
                                                                              .searchAppointmentList?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "4"
                                                                      ? "absent"
                                                                      : (appointmentProvider.searchAppointmentList?[position].status.toString() ==
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
                                                      color: appointmentProvider
                                                                  .searchAppointmentList?[
                                                                      position]
                                                                  .status
                                                                  .toString() ==
                                                              "1"
                                                          ? colorPrimary
                                                          : (appointmentProvider
                                                                      .searchAppointmentList?[
                                                                          position]
                                                                      .status
                                                                      .toString() ==
                                                                  "2"
                                                              ? approvedStatus
                                                              : (appointmentProvider
                                                                          .searchAppointmentList?[
                                                                              position]
                                                                          .status
                                                                          .toString() ==
                                                                      "3"
                                                                  ? rejectedStatus
                                                                  : appointmentProvider
                                                                              .searchAppointmentList?[
                                                                                  position]
                                                                              .status
                                                                              .toString() ==
                                                                          "4"
                                                                      ? otherColor
                                                                      : (appointmentProvider.searchAppointmentList?[position].status.toString() ==
                                                                              "5"
                                                                          ? approvedStatus
                                                                          : black))),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Flexible(
                                                    child: MyText(
                                                      text:
                                                          '${Utils.formateTime((appointmentProvider.searchAppointmentList?[position].startTime ?? ""))} - ${Utils.formateTime((appointmentProvider.searchAppointmentList?[position].endTime ?? ""))}',
                                                      fontsize:
                                                          Dimens.text13Size,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxline: 1,
                                                      fontweight:
                                                          FontWeight.normal,
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
                                    const SizedBox(height: 20),
                                    appointmentProvider
                                                .searchAppointmentList?[
                                                    position]
                                                .status
                                                .toString() ==
                                            "1"
                                        ? Row(
                                            children: [
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    updateSearchAppointmentStatus(
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
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    updateSearchAppointmentStatus(
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
                                        : appointmentProvider
                                                    .searchAppointmentList?[
                                                        position]
                                                    .status
                                                    .toString() ==
                                                "3"
                                            ? const SizedBox.shrink()
                                            : appointmentProvider
                                                        .searchAppointmentList?[
                                                            position]
                                                        .status
                                                        .toString() ==
                                                    "5"
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(20,
                                                                  10, 20, 10),
                                                          alignment:
                                                              Alignment.center,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  width: 1,
                                                                  color:
                                                                      colorPrimary),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: MyText(
                                                            color: colorPrimary,
                                                            text:
                                                                "view_details",
                                                            fontsize: Dimens
                                                                .text15Size,
                                                            multilanguage: true,
                                                            fontweight:
                                                                FontWeight.w500,
                                                            maxline: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textalign: TextAlign
                                                                .center,
                                                            fontstyle: FontStyle
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
                                                                    builder: (context) => SeeReview(
                                                                        doctorId: int.parse(Constant
                                                                            .userID
                                                                            .toString()))));
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
                                                : Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                          child: InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      Reschedule(
                                                                        appointmentID: appointmentProvider
                                                                            .searchAppointmentList?[position]
                                                                            .id
                                                                            .toString(),
                                                                        doctorID: appointmentProvider
                                                                            .searchAppointmentList?[position]
                                                                            .doctorId
                                                                            .toString(),
                                                                      ))).then(
                                                            (value) async {
                                                              await getSearchData(
                                                                  mSearchController
                                                                      .text
                                                                      .toString(),
                                                                  (appointmentProvider
                                                                          .searchcurrentPage ??
                                                                      0));
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          alignment:
                                                              Alignment.center,
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(20,
                                                                  10, 20, 10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color:
                                                                      colorPrimaryDark,
                                                                  width: 1)),
                                                          child: MyText(
                                                            text: "reschedule",
                                                            multilanguage: true,
                                                            color:
                                                                colorPrimaryDark,
                                                            fontsize: Dimens
                                                                .text14Size,
                                                            fontweight:
                                                                FontWeight.w500,
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
                                                                      AppointmentDetails(appointmentProvider
                                                                              .searchAppointmentList?[position]
                                                                              .id
                                                                              .toString() ??
                                                                          "")));
                                                        },
                                                        child: Container(
                                                          height: 40,
                                                          alignment:
                                                              Alignment.center,
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(20,
                                                                  10, 20, 10),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  colorPrimaryDark,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color:
                                                                      colorPrimaryDark,
                                                                  width: 1)),
                                                          child: MyText(
                                                            text:
                                                                "join_session",
                                                            multilanguage: true,
                                                            color: white,
                                                            fontsize: Dimens
                                                                .text14Size,
                                                            fontweight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      )),
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
                                          text: Utils.formateDate(
                                              (appointmentProvider
                                                          .searchAppointmentList?[
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
                Consumer<AppointmentProvider>(
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
          return const NoData(
            text: '',
          );
        }
      } else {
        return const NoData(
          text: '',
        );
      }
    }
  }

  Widget statusShimmer() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 20,
          );
        },
        itemBuilder: (context, index) {
          return const CustomWidget.roundcorner(
            height: 30,
            width: 80,
          );
        },
      ),
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

  void updateAppointmentStatus(String status, index) async {
    printLog(
        'appointmentID ==>> ${appointmentProvider.appointmentList?[index].id}');
    printLog('status ==>> $status');

    Utils.showProgress(context, prDialog);

    await appointmentProvider.updateAppoinmentStatus(
        appointmentProvider.appointmentList?[index].id, status);
    appointmentProvider.appointmentList?[index].status = int.parse(status);
    printLog(
        'updateAppointmentStatus loadingUpdate ==>> ${appointmentProvider.loadingUpdate}');

    if (!appointmentProvider.loadingUpdate) {
      printLog(
          'updateAppointmentStatus status ==>> ${appointmentProvider.successModel.status}');
      if (appointmentProvider.successModel.status == 200) {
        prDialog?.hide();

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

  void updateSearchAppointmentStatus(String status, index) async {
    printLog(
        'appointmentID ==>> ${appointmentProvider.searchAppointmentList?[index].id}');
    printLog('status ==>> $status');

    Utils.showProgress(context, prDialog);

    await appointmentProvider.updateAppoinmentStatus(
        appointmentProvider.searchAppointmentList?[index].id, status);
    appointmentProvider.searchAppointmentList?[index].status =
        int.parse(status);

    printLog(
        'updateAppointmentStatus loadingUpdate ==>> ${appointmentProvider.loadingUpdate}');

    if (!appointmentProvider.loadingUpdate) {
      printLog(
          'updateAppointmentStatus status ==>> ${appointmentProvider.successModel.status}');
      if (appointmentProvider.successModel.status == 200) {
        prDialog?.hide();

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
