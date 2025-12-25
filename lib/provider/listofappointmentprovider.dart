import 'package:yourappname/model/appointmentmodel.dart';
import 'package:yourappname/model/appointmentmodel.dart' as appointment;
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class ListOfAppointmentProvider extends ChangeNotifier {
  AppointmentModel listOfAppointmentModel = AppointmentModel();
  SuccessModel successModel = SuccessModel();
  List<appointment.Result>? appointmentList = [];
  bool loading = false, searchloading = false, isShow = false;

  SharedPre sharePref = SharedPre();

  Future<void> getPatientAppointment(patientID, String pageNo) async {
    loading = true;
    printLog("getPatientAppointment patientID :==> $patientID");
    listOfAppointmentModel =
        await ApiService().patientAppoinment(patientID, pageNo);
    setPodcastPaginationData(
        listOfAppointmentModel.totalRows,
        listOfAppointmentModel.totalPage,
        listOfAppointmentModel.currentPage,
        listOfAppointmentModel.morePage);
    if (listOfAppointmentModel.result != null &&
        (listOfAppointmentModel.result?.length ?? 0) > 0) {
      for (var i = 0; i < (listOfAppointmentModel.result?.length ?? 0); i++) {
        appointmentList
            ?.add(listOfAppointmentModel.result?[i] ?? appointment.Result());
      }
      final Map<int, appointment.Result> postMap = {};
      appointmentList?.forEach((item) {
        postMap[item.id ?? 0] = item;
      });
      appointmentList = postMap.values.toList();
      printLog("contentList length :==> ${(appointmentList?.length ?? 0)}");
      setLoadMore(false);
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

  setPodcastPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage ?? false;

    notifyListeners();
  }

  Future<void> updateAppoinmentStatus(appointmentID, status) async {
    printLog("updateAppoinmentStatus appointmentID :==> $appointmentID");
    printLog("updateAppoinmentStatus status :==> $status");
    loading = true;
    successModel =
        await ApiService().appoinmentStatusUpdate(appointmentID, status);
    printLog("appoinment_status_update status :==> ${successModel.status}");
    printLog("appoinment_status_update message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }
}
