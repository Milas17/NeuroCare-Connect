import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/report_model.dart';
import 'package:kivicare_flutter/network/report_repository.dart';
import 'package:kivicare_flutter/screens/doctor/screens/add_report_screen.dart';
import 'package:kivicare_flutter/screens/encounter/component/report_component.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/report_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:nb_utils/nb_utils.dart';

class MyReportsScreen extends StatefulWidget {
  final bool enableSelection; // New parameter to control selection mode

  MyReportsScreen({this.enableSelection = false});

  @override
  _MyReportsScreenState createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  Future<List<ReportData>>? future;
  List<ReportData> reportList = [];
  List<ReportData> selectedReports = [];
  int total = 0;
  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init({showLoader = false}) async {
    if (showLoader) appStore.setLoading(true);
    future = getPatientReportListApi(
      patientId: userStore.userId,
      page: page,
      getTotalReport: (b) => total = b,
      lastPageCallback: (b) => isLastPage = b,
      reportList: reportList,
    ).then((value) {
      appStore.setLoading(false);
      setState(() {});
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  Future<void> deleteReportData(String? id) async {
    appStore.setLoading(true);
    Map<String, dynamic> res = {"id": "$id"};
    await deleteReportAPI(res).then((value) {
      toast(value.reportResponse?.message.validate());
      init(showLoader: true);
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  void toggleSelection(ReportData report) {
    setState(() {
      if (selectedReports.contains(report)) {
        selectedReports.remove(report);
      } else {
        selectedReports.add(report);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    getDisposeStatusBarColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.enableSelection, // Allow normal back when not in selection mode
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && widget.enableSelection) {
          Navigator.pop(context, []); // Return empty list on back
        }
      },
      child: Scaffold(
        appBar: appBarWidget(
          locale.lblMyReports,
          textColor: Colors.white,
          systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
          elevation: 0,
          color: appPrimaryColor,
          actions: [
            if (selectedReports.isNotEmpty)
              TextButton(
                onPressed: selectedReports.isNotEmpty
                    ? () {
                        Navigator.pop(context, selectedReports);
                      }
                    : null,
                child: Text(
                  locale.lblSave,
                  style: boldTextStyle(color: Colors.white),
                ),
              ).paddingRight(16),
          ],
        ),
        body: InternetConnectivityWidget(
          child: Stack(
            children: [
              SnapHelperWidget<List<ReportData>>(
                future: future,
                loadingWidget: ReportShimmerScreen(),
                errorWidget: ErrorStateWidget().center(),
                onSuccess: (snap) {
                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: 60, top: 16, left: 16, right: 16),
                    itemCount: snap.length,
                    itemBuilder: (context, index) {
                      ReportData reportData = snap[index];
                      bool isSelected = selectedReports.contains(reportData);

                      return GestureDetector(
                        onTap: widget.enableSelection ? () => toggleSelection(reportData) : null,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ReportComponent(
                                reportData: reportData,
                                isForMyReportScreen: true,
                                showDelete: true,
                                refreshReportData: () => init(),
                                deleteReportData: () {
                                  showConfirmDialogCustom(
                                    context,
                                    onAccept: (p0) {
                                      deleteReportData(reportData.id.validate().toString());
                                    },
                                    dialogType: DialogType.DELETE,
                                    title: locale.lblDoYouWantToDeleteReport,
                                  );
                                },
                              ),
                            ),
                            8.width,
                            if (widget.enableSelection)
                              Padding(
                                padding: EdgeInsets.only(right: 8, top: 8),
                                child: Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected ? appPrimaryColor : Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      );
                    },

                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(), // ensure scrolling
                  ).visible(
                    snap.isNotEmpty,
                    defaultWidget: NoDataFoundWidget(text: locale.lblNoReportsFound).center(),
                  );
                },
              ),
              Observer(
                builder: (context) => LoaderWidget().center().visible(appStore.isLoading),
              ),
            ],
          ),
          retryCallback: () => setState(() {}),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            AddReportScreen().launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration).then((v) async {
              if (v == true) {
                await init();
              }
            });
          },
          child: Icon(Icons.add),
        ).visible(isVisible(SharedPreferenceKey.kiviCarePatientReportAddKey)),
      ),
    );
  }
}
