import 'package:yourappname/model/notificationmodel.dart' as notification;
import 'package:yourappname/model/notificationmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservices.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationModel notificationModel = NotificationModel();
  List<notification.Result>? notificationList = [];
  SuccessModel successModel = SuccessModel();

  bool loading = false;
  SharedPre sharePref = SharedPre();

  Future<void> getDoctorNotification(pageNo) async {
    printLog("getDoctorNotification doctorID :==> ${Constant.userID}");
    loading = true;
    notificationModel = await ApiService().getDoctorNotification(pageNo);
    if (notificationModel.status == 200) {
      setPaginationData(
          notificationModel.totalRows,
          notificationModel.totalPage,
          notificationModel.currentPage,
          notificationModel.morePage);
      if (notificationModel.result != null &&
          (notificationModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (notificationModel.result?.length ?? 0); i++) {
          notificationList
              ?.add(notificationModel.result?[i] ?? notification.Result());
        }
        final Map<int, notification.Result> postMap = {};
        notificationList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        notificationList = postMap.values.toList();
        printLog("contentList length :==> ${(notificationList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

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
    this.isMorePage = isMorePage ?? false;

    notifyListeners();
  }

  clearProvider() {
    notificationList = [];
    notificationModel = NotificationModel();
    currentPage = 0;
    totalPage = 0;
  }
}
