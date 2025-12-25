import 'package:yourappname/model/appointmentmodel.dart' as appointment;
import 'package:yourappname/model/appointmentmodel.dart';
import 'package:yourappname/model/downloadprescriptionmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class PatientHistoryProvider extends ChangeNotifier {
  AppointmentModel pateintHistoryModel = AppointmentModel();
  DownloadPrescriptionModel downloadPrescriptionModel =
      DownloadPrescriptionModel();
  List<appointment.Result>? appointmentList = [];

  bool loading = false;
  bool prescLoading = false;

  Future<void> getPatientHistory(pageNo) async {
    loading = true;
    printLog("pateintHistoryModel userId :==> ${Constant.userID}");
    pateintHistoryModel =
        await ApiService().patientHistory(Constant.userID, pageNo);
    if (pateintHistoryModel.status == 200) {
      setPaginationData(
          pateintHistoryModel.totalRows,
          pateintHistoryModel.totalPage,
          pateintHistoryModel.currentPage,
          pateintHistoryModel.morePage);
      if (pateintHistoryModel.result != null &&
          (pateintHistoryModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (pateintHistoryModel.result?.length ?? 0); i++) {
          appointmentList
              ?.add(pateintHistoryModel.result?[i] ?? appointment.Result());
        }
        final Map<int, appointment.Result> postMap = {};
        appointmentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        appointmentList = postMap.values.toList();
        printLog("contentList length :==> ${(appointmentList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  // AppointMent pagination
  bool loadmore = false;
  int? totalRows, totalPage, currentPage;
  bool isMorePage = false;
  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage!;

    notifyListeners();
  }

  Future<void> getDownloadPrescription(appointmentId) async {
    prescLoading = true;
    downloadPrescriptionModel =
        await ApiService().downloadPrescription(appointmentId);
    printLog(
        "downloadPrescriptionModel status :==> ${downloadPrescriptionModel.status}");
    printLog(
        "downloadPrescriptionModel message :==> ${downloadPrescriptionModel.message}");
    prescLoading = false;
    notifyListeners();
  }

   notifyListener(){
    notifyListeners();
  }


  clearProvider() {
    appointmentList = [];
  }
}
