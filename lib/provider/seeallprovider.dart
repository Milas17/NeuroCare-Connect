import 'package:yourappname/model/appointmentmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/model/appointmentmodel.dart' as pending;
import 'package:yourappname/model/appointmentmodel.dart' as today;
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class SeeallProvider extends ChangeNotifier {
  AppointmentModel todayAppointmentModel = AppointmentModel();
  AppointmentModel appointmentModel = AppointmentModel();
  List<pending.Result>? pendingAppointmentList = [];
  SuccessModel successModel = SuccessModel();
  List<today.Result>? todayAppointmentList = [];
  bool loadmore = false;
  bool loadingUpdate = false;
  bool loading = false, todayLoading = false;

  Future<void> getTodayAppointment(pageNo) async {
    todayLoading = true;
    printLog("getTodayAppointment userId :==> ${Constant.userID}");
    todayAppointmentModel =
        await ApiService().todayappointment(Constant.userID, pageNo);
    if (todayAppointmentModel.status == 200) {
      setPodcastPaginationData(
          todayAppointmentModel.totalRows,
          todayAppointmentModel.totalPage,
          todayAppointmentModel.currentPage,
          todayAppointmentModel.morePage);
      if (todayAppointmentModel.result != null &&
          (todayAppointmentModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (todayAppointmentModel.result?.length ?? 0); i++) {
          todayAppointmentList
              ?.add(todayAppointmentModel.result?[i] ?? today.Result());
        }
        final Map<int, today.Result> postMap = {};
        todayAppointmentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        todayAppointmentList = postMap.values.toList();
        printLog(
            "contentList length :==> ${(todayAppointmentList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    printLog("getTodayAppointment status :==> ${todayAppointmentModel.status}");
    printLog(
        "getTodayAppointment message :==> ${todayAppointmentModel.message}");
    todayLoading = false;
    notifyListeners();
  }

  int? pendingtotalRows, pendingtotalPage, pendingcurrentPage;
  bool pendingisMorePage = false;

  Future<void> getPendingAppointment(pageNo) async {
    loading = true;
    printLog("getPendingAppointment userId :==> ${Constant.userID}");
    appointmentModel =
        await ApiService().pendingappointment(Constant.userID, pageNo);
    if (appointmentModel.status == 200) {
      setPodcastPaginationData(
          appointmentModel.totalRows,
          appointmentModel.totalPage,
          appointmentModel.currentPage,
          appointmentModel.morePage);
      if (appointmentModel.result != null &&
          (appointmentModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (appointmentModel.result?.length ?? 0); i++) {
          pendingAppointmentList
              ?.add(appointmentModel.result?[i] ?? pending.Result());
        }
        final Map<int, pending.Result> postMap = {};
        pendingAppointmentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        pendingAppointmentList = postMap.values.toList();
        printLog(
            "contentList length :==> ${(pendingAppointmentList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPodcastPaginationData(int? pendingtotalRows, int? pendingtotalPage,
      int? pendingcurrentPage, bool? pendingisMorePage) {
    this.pendingcurrentPage = pendingcurrentPage;
    this.pendingtotalRows = pendingtotalRows;
    this.pendingtotalPage = pendingtotalPage;
    this.pendingisMorePage = pendingisMorePage!;

    notifyListeners();
  }

  clearProvider() {
    todayLoading = false;
    loading = false;
    appointmentModel = AppointmentModel();
    todayAppointmentModel = AppointmentModel();
    todayAppointmentList = [];
    pendingAppointmentList = [];
  }

  Future<void> updateAppoinmentStatus(appointmentID, status) async {
    printLog("updateAppoinmentStatus appointmentID :==> $appointmentID");
    printLog("updateAppoinmentStatus status :=========> $status");
    loadingUpdate = true;
    successModel =
        await ApiService().appoinmentStatusUpdate(appointmentID, status);
    printLog("updateAppoinmentStatus status :===> ${successModel.status}");
    printLog("updateAppoinmentStatus message :==> ${successModel.message}");
    loadingUpdate = false;
    notifyListeners();
  }
}
